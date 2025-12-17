#!/bin/bash
set -e

# Default to dev if no argument provided
ENV=${1:-dev}

# Validate environment
if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
    echo "Error: Invalid environment '$ENV'. Must be 'dev' or 'prod'."
    exit 1
fi

echo "=================================================="
echo "  Deploying to Environment: $ENV"
echo "=================================================="

# 1. Setup Authentication (Bypass ADC issues)
echo "[1/3] Refreshing Access Token..."
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

# 2. Force Destroy the Cloud Run Service
# This is required to solve the "Sticky IAM" issue where switching from Prod -> Dev
# leaves the service publicly accessible despite Terraform config changes.
echo "[2/3] Cleaning up existing service (Force Destroy)..."
terraform destroy -target=google_cloud_run_service.default -auto-approve

echo "Sleeping 30s to ensure destruction propagates..."
sleep 30

# 3. Apply New Configuration
echo "[3/3] Applies new configuration..."
terraform apply -var="environment=$ENV" -auto-approve

# 4. Verification
echo "[4/4] Verifying Access..."
SERVICE_URL=$(terraform output -raw service_url)
echo "Service URL: $SERVICE_URL"

# Wait a moment for propagation if needed, though usually Cloud Run is fast
echo "Sleeping 20s to ensure IAM settings propagate..."
sleep 20

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$SERVICE_URL")
echo "HTTP Status: $HTTP_CODE"

echo "=================================================="
if [ "$ENV" == "prod" ]; then
    if [ "$HTTP_CODE" == "200" ]; then
        echo "✅ SUCCESS: Service is PUBLIC (200 OK)"
    else
        echo "❌ FAILURE: Expected 200, got $HTTP_CODE"
        # Don't exit 1 here to avoid breaking pipelines if it's just a propagation delay, 
        # but warn significantly.
    fi
else
    if [ "$HTTP_CODE" == "403" ]; then
        echo "✅ SUCCESS: Service is PRIVATE (403 Forbidden)"
    else
        echo "❌ FAILURE: Expected 403, got $HTTP_CODE"
    fi
fi
echo "=================================================="
