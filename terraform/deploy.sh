#!/bin/bash
set -e

# Default to dev if no argument provided
ENV=${1:-dev}
IMAGE_URI=$2

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
if [ -n "$IMAGE_URI" ]; then
    echo "Using custom image: $IMAGE_URI"
    terraform apply -var="environment=$ENV" -var="image_uri=$IMAGE_URI" -auto-approve
else
    terraform apply -var="environment=$ENV" -auto-approve
fi

# 4. Verification
echo "[4/4] Verifying Access..."
SERVICE_URL=$(terraform output -raw service_url)
echo "Service URL: $SERVICE_URL"

# Wait a moment for propagation if needed, though usually Cloud Run is fast
# Polling loop to check for propagation
MAX_RETRIES=18 # 18 * 5s = 90s
COUNTER=0

if [ "$ENV" == "prod" ]; then
    EXPECTED_CODE="200"
else
    EXPECTED_CODE="403"
fi

echo "Waiting for service to return HTTP $EXPECTED_CODE..."

while [ $COUNTER -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$SERVICE_URL")
    
    if [ "$HTTP_CODE" == "$EXPECTED_CODE" ]; then
        echo "✅ SUCCESS: Service returned $HTTP_CODE (Expected)"
        if [ "$EXPECTED_CODE" == "403" ]; then
             echo "Service is correctly PRIVATE."
        else
             echo "Service is correctly PUBLIC."
        fi
        exit 0
    fi

    echo "Current Status: $HTTP_CODE. Retrying in 5s... ($((COUNTER+1))/$MAX_RETRIES)"
    sleep 5
    let COUNTER=COUNTER+1
done

echo "=================================================="
echo "❌ FAILURE: Timed out waiting for HTTP $EXPECTED_CODE."
echo "Last Status: $HTTP_CODE"
echo "=================================================="
exit 1
echo "=================================================="
