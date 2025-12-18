# IAM Permissions for GitHub Actions CI/CD Service Account
# This Service Account is used by the GitHub Actions workflow to deploy resources.

locals {
  github_actions_sa_email = "github-actions-sa@${var.project_id}.iam.gserviceaccount.com"
}

# Grant Project IAM Admin to allow setting policies and bindings
resource "google_project_iam_member" "github_sa_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${local.github_actions_sa_email}"
}

# Grant Network Admin to allow VPC Peering and Network management
resource "google_project_iam_member" "github_sa_network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${local.github_actions_sa_email}"
}

# Grant Cloud SQL Admin to allow creating/managing DB instances
resource "google_project_iam_member" "github_sa_sql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${local.github_actions_sa_email}"
}

# Grant Service Account User to allow deploying Cloud Run services as other service accounts
resource "google_project_iam_member" "github_sa_act_as" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${local.github_actions_sa_email}"
}
