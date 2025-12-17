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
resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.environment == "prod" ? 1 : 0
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
