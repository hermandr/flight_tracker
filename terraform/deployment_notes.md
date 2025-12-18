# Deployment Notes & Known Issues

## 1. Organization Policy
Public access (unauthenticated invocations) is blocked by default in this organization via the `constraints/iam.allowedPolicyMemberDomains` constraint.
-   The `org_policy.tf` file manages an exemption for this specific project.
-   This exemption allows `allUsers` to be added to the IAM policy in Production.
