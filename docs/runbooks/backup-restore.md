# Runbook: backup restore

**Protection in place**

| Layer | Mechanism | Recovery point |
|---|---|---|
| DynamoDB | Point-in-time recovery | Any second in the last 35 days |
| DynamoDB | AWS Backup daily snapshot, tag driven | Daily, retained per size profile |
| Terraform state | S3 versioning | Any previous version |
| Container images | ECR, immutable commit tags | Any retained image |
| Infrastructure | Terraform in Git | Any commit |

Target RPO 24 hours (PITR reduces this to seconds), target RTO 1 hour for data, 15 minutes for application rollback.

## A. Point-in-time restore (preferred for accidental data change)

```
aws dynamodb restore-table-to-point-in-time \
  --source-table-name $PREFIX-items \
  --target-table-name $PREFIX-items-restore \
  --restore-date-time 2026-01-01T12:00:00Z \
  --region $REGION
```

The restore creates a **new** table. Validate it, then cut over by pointing `TABLE_NAME` at the restored table via a Terraform change, or copy the corrected items back.

## B. Restore from an AWS Backup recovery point

```
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name $PREFIX-vault --region $REGION

aws backup start-restore-job \
  --recovery-point-arn <arn> \
  --iam-role-arn <backup role arn from terraform output> \
  --metadata '{"targetTableName":"'$PREFIX'-items-restore"}' \
  --region $REGION

aws backup describe-restore-job --restore-job-id <id> --region $REGION
```

## C. Terraform state recovery

List and restore a previous version of the state object:

```
aws s3api list-object-versions --bucket <state-bucket> --prefix $CUSTOMER/$ENV/terraform.tfstate
aws s3api get-object --bucket <state-bucket> --key $CUSTOMER/$ENV/terraform.tfstate \
  --version-id <version> restored.tfstate
```

## D. Full environment rebuild

The environment is reproducible from the repository:

```
terraform init -backend-config=... && terraform apply -var-file=customers/$CUSTOMER/$ENV.tfvars
```

then restore data with A or B.

## Verification

Restore drills are run quarterly into a scratch table and the result is recorded. A backup that has never been restored is an assumption, not a control.
