output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.default.status[0].url
}

output "matomo_url" {
  description = "The URL of the Matomo service"
  value       = google_cloud_run_v2_service.matomo.uri
}

output "matomo_db_connection_name" {
  description = "The connection name of the Matomo Cloud SQL instance"
  value       = google_sql_database_instance.matomo_db_instance.connection_name
}
