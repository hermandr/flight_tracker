# Deployment Notes & Known Issues

## 1. Sticky IAM State (Public vs Private Access)

### Issue
We observed a "sticky state" issue with Cloud Run public access configuration.
-   When deploying to `prod` (public), the `allUsers` IAM binding is created correctly.
-   When switching back to `dev` (private) by merely applying the Terraform configuration changes (which removes the IAM binding), the Cloud Run service sometimes **remains publicly accessible** despite the Project IAM policy showing no public grants.

### Root Cause
This appears to be a synchronization issue or caching behavior within the Cloud Run control plane where the removal of the IAM policy does not immediately or consistently propagate to the serving infrastructure when done via an update operation.

### Solution: Force Recreation
To guarantee the security of the Development environment, we must ensure a clean state.
**The safe deployment strategy is to DESTROY the Cloud Run service resource before applying the new configuration.**

This forces Cloud Run to provision a fresh service instance, ensuring that:
1.  No stale IAM policies persist.
2.  The service starts with the exact configuration defined in Terraform.

## 2. Organization Policy
Public access (unauthenticated invocations) is blocked by default in this organization via the `constraints/iam.allowedPolicyMemberDomains` constraint.
-   The `org_policy.tf` file manages an exemption for this specific project.
-   This exemption allows `allUsers` to be added to the IAM policy in Production.
