variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "flight-tracker-rcsg-01"
}

variable "region" {
  description = "The GCP region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
  default     = "flight-tracker"
}

variable "image_image" {
  description = "The Docker image URL to deploy"
  type        = string
  default     = "us-central1-docker.pkg.dev/flight-tracker-rcsg-01/flight-repo/flight-tracker"
}
