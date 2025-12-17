# Flight Tracker Terraform Deployment

This directory contains the Terraform configuration for deploying the Flight Tracker application to Google Cloud Run.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed (v4.0+ provider support).
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated.
- A GCP project with Billing and Cloud Run API enabled.

## Configuration

The following variables can be configured in `variables.tf` or via `-var` flags:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | `flight-tracker-rcsg-01` |
| `region` | GCP Region | `us-central1` |
| `service_name` | Cloud Run Service Name | `flight-tracker` |
| `image_image` | Docker Image URL | `us-central1-docker.pkg.dev/flight-tracker-rcsg-01/flight-repo/flight-tracker` |

## Usage

1.  **Initialize Terraform** (only needed once):
    ```bash
    terraform init
    ```

2.  **Plan the deployment**:
    Preview the changes Terraform will make.
    ```bash
    terraform plan
    ```

3.  **Deploy**:
    Apply the configuration to create or update resources.
    ```bash
    terraform apply
    ```

4.  **Access**:
    After a successful apply, Terraform will output the `service_url`.

## Notes
- The default configuration allows **public access** (`allUsers`). To restrict this, edit `main.tf` and remove/comment out the `google_cloud_run_service_iam_member` resource.
