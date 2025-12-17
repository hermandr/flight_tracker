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

We provide a `deploy.sh` script to automate the safe deployment process. This script **forces the recreation** of the Cloud Run service to ensure security settings (IAM) are correctly applied.

### Deploy to Development (Private)
Deploys with private access only (authenticated users).
```bash
./deploy.sh dev
```

### Deploy to Production (Public)
Deploys with public access enabled (`allUsers`).
```bash
./deploy.sh prod
```

### Manual Deployment (Not Recommended)
If you run `terraform apply` manually, beware of the "Sticky IAM" issue when switching environments. See [Known Issues](deployment_notes.md).

## Testing Private Services
For instructions on how to access the private development service via Browser or Curl, see [testing_guide.md](testing_guide.md).

## Outputs
After a successful deployment, the script will output the `service_url`.

## Known Issues
Please refer to [deployment_notes.md](deployment_notes.md) for details on:
-   Sticky IAM State (Public vs Private persistence).
-   Organization Policy overrides.

## Notes
- The default configuration allows **public access** (`allUsers`). To restrict this, edit `main.tf` and remove/comment out the `google_cloud_run_service_iam_member` resource.
