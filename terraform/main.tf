resource "google_service_account" "flight_tracker_sa" {
  account_id   = "flight-tracker-sa"
  display_name = "Flight Tracker Service Account"
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.flight_tracker_sa.email
      containers {
        image = var.image_uri
        ports {
          container_port = 3000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow unauthenticated invocations (Public access)
# Comment this out if you want to restrict access to authenticated users only
# Authoritative binding for the invoker role
# Ensures strict access control by overwriting any existing members with the list defined below.
resource "google_cloud_run_service_iam_binding" "invoker" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"

  members = var.environment == "prod" ? ["allUsers"] : []
}
