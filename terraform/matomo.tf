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

# Cloud SQL Instance (MariaDB)
# Using Public IP with Authorized Networks restricted to empty list (secure pattern)
resource "google_sql_database_instance" "matomo_db_instance" {
  name             = "matomo-db-${random_id.db_suffix.hex}"
  database_version = "MARIADB_10_6"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled    = true
      
      # Implicitly denies all external access by having no authorized networks
      authorized_networks {
        name  = "none"
        value = "0.0.0.0/32" # Effectively nowhere
      }
    }
  }

  deletion_protection = false # Set to true for production to prevent accidental deletion
}

resource "random_id" "db_suffix" {
  byte_length = 4
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

# Cloud Run Service for Matomo
resource "google_cloud_run_service" "matomo" {
  name     = "matomo"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.matomo_sa.email
      
      containers {
        image = "matomo:latest"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        # Connect to Cloud SQL
        env {
          name  = "MATOMO_DATABASE_HOST"
          value = "127.0.0.1" # Proxy exposes it locally
        }
        env {
           name = "MATOMO_DATABASE_ADAPTER"
           value = "mysql"
        }
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
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.matomo_db_instance.connection_name
        "autoscaling.knative.dev/maxScale"      = "2" # Keep usage low
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
}

# Allow public access to Matomo Interface (tracker needs to be public)
resource "google_cloud_run_service_iam_binding" "matomo_invoker" {
  location = google_cloud_run_service.matomo.location
  service  = google_cloud_run_service.matomo.name
  role     = "roles/run.invoker"

  members = [
    "allUsers"
  ]
}
