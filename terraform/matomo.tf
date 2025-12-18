# Service Account for Matomo
resource "google_service_account" "matomo_sa" {
  account_id   = "matomo-sa"
  display_name = "Matomo Service Account"
}

# Grant Cloud SQL Client role to Matomo SA
resource "google_project_iam_member" "matomo_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.matomo_sa.email}"
}

# Random Password for Matomo Database User
resource "random_password" "matomo_db_password" {
  length  = 16
  special = false
}

# Cloud SQL Instance (MariaDB) - Private IP Only
# Safe from "sql.restrictPublicIp" policy
resource "google_sql_database_instance" "matomo_db_instance" {
  name             = "matomo-db-${random_id.db_suffix.hex}"
  database_version = "MYSQL_8_0"
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled    = false # Private IP Only
      private_network = "projects/${var.project_id}/global/networks/default"
    }
  }

  deletion_protection = false
}

resource "random_id" "db_suffix" {
  byte_length = 4
  keepers = {
     # Force recreation if we change networking drastically, though random_id usually handles suffix
     # We change the suffix logic slightly or just rely on the new name to trigger recreation
     version = "v2" 
  }
}

# Matomo Database
resource "google_sql_database" "matomo_database" {
  name     = "matomo"
  instance = google_sql_database_instance.matomo_db_instance.name
}

# Matomo Database User
resource "google_sql_user" "matomo_user" {
  name     = "matomo"
  instance = google_sql_database_instance.matomo_db_instance.name
  password = random_password.matomo_db_password.result
}

# Cloud Run v2 Service for Matomo (Supports Direct VPC Egress)
resource "google_cloud_run_v2_service" "matomo" {
  name     = "matomo"
  location = var.region
  ingress = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.matomo_sa.email
    
    containers {
      image = "matomo:latest"
      
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
      
      ports {
        container_port = 80
      }

      # Connect to Cloud SQL via Private IP
      env {
        name  = "MATOMO_DATABASE_HOST"
        value = google_sql_database_instance.matomo_db_instance.private_ip_address
      }
      # Removing explicit adapter to allow auto-detection
      # env {
      #    name = "MATOMO_DATABASE_ADAPTER"
      #    value = "mysql"
      # }
      env {
          name = "MATOMO_DATABASE_TABLES_PREFIX"
          value = "matomo_"
      }
      env {
          name = "MATOMO_DATABASE_USERNAME"
          value = google_sql_user.matomo_user.name
      }
      env {
          name = "MATOMO_DATABASE_PASSWORD"
          value = random_password.matomo_db_password.result
      }
      env {
          name = "MATOMO_DATABASE_DBNAME"
          value = google_sql_database.matomo_database.name
      }
    }
    
    # Direct VPC Egress Configuration
    vpc_access {
      network_interfaces {
        network = "default"
        subnetwork = "default"
      }
      egress = "PRIVATE_RANGES_ONLY" # Route private IP traffic (DB) through VPC
    }
  }

  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Allow public access to Matomo Interface
resource "google_cloud_run_service_iam_binding" "matomo_invoker" {
  location = google_cloud_run_v2_service.matomo.location
  service  = google_cloud_run_v2_service.matomo.name
  role     = "roles/run.invoker"
  
  depends_on = [google_project_organization_policy.public_access]

  members = [
    "allUsers"
  ]
}
