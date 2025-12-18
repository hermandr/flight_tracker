# Testing Private Services (Dev Environment)

When the service is in the **Dev** environment, public access is restricted (IAM: "Require authentication"). You can still access it using your authenticated credentials.

### 1. Deploying to Dev
```bash
terraform apply -var="environment=dev"
```
This command will:
1. Configure the Cloud Run service.
2. Apply the private IAM policy (removing `allUsers` if present).
3. Ensure the service returns HTTP 403 (Private).

## Option 1: Browser Access (Recommended)
You can use the `gcloud run services proxy` command to create a secure tunnel. This allows you to view the authenticated app in your local browser.

1.  **Run the proxy command**:
    ```bash
    gcloud run services proxy flight-tracker --project flight-tracker-rcsg-01 --region us-central1
    ```
    *This starts a local proxy on `http://localhost:8080`.*

2.  **Open in Browser**:
    Navigate to [http://localhost:8080](http://localhost:8080).

## Option 2: CLI Access (curl)
To test the endpoint from the terminal, include an identity token in the header.

```bash
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     https://flight-tracker-5ums4ujnoa-uc.a.run.app
```
