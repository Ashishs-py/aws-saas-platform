# Runbook: decommission an environment

Used at the end of a demo, a trial, or a customer offboarding. Also the way to guarantee spend returns to zero.

## 1. Destroy the stack

Either run the Destroy workflow (type `DESTROY` to confirm), or locally:

```
cd stack
terraform init -backend-config=... (as for deploy)
terraform destroy -var-file=../customers/$CUSTOMER/$ENV.tfvars
```

If `deletion_protection` is enabled on the DynamoDB table (medium and large profiles), set `deletion_protection_enabled=false` through a Terraform change first. That friction is intentional.

## 2. Disable per-region security services if they are no longer needed

These are account-level services and are not always removed by destroy in every configuration:

```
aws guardduty list-detectors --region $REGION
aws guardduty delete-detector --detector-id <id> --region $REGION
aws securityhub disable-security-hub --region $REGION
```

## 3. Remove the shared bootstrap (only when the whole platform is retired)

```
aws s3 rm s3://<state-bucket> --recursive
cd bootstrap && terraform destroy
```

## 4. Confirm

- Cost Explorer, filtered by the `Customer` tag, should trend to zero within 24 hours.
- No ALBs, NAT gateways, Fargate tasks or EIPs remain in the region.
