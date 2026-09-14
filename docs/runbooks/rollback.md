# Runbook: rollback

**Objective:** return to the last known good release in minutes.

## Automatic rollback

The ECS service runs with the deployment circuit breaker and rollback enabled. A revision that never becomes healthy is rolled back by ECS without human action. Verify:

```
aws ecs describe-services --cluster $PREFIX-cluster --services $PREFIX-app --region $REGION \
  --query 'services[0].deployments[].{status:status,taskDef:taskDefinition,rollout:rolloutState}'
```

## Fast manual rollback (application only)

Re-point the service at the previous task definition revision:

```
aws ecs update-service --cluster $PREFIX-cluster --service $PREFIX-app \
  --task-definition $PREFIX-app:<previous-revision> --region $REGION
aws ecs wait services-stable --cluster $PREFIX-cluster --services $PREFIX-app --region $REGION
```

This is an out-of-band change. Follow it immediately with a pipeline run that pins the same image, so Terraform state matches reality:

```
Deploy workflow -> customer, environment, apply
(with container_image set to the previous image tag)
```

## Infrastructure rollback

Revert the commit that introduced the change and re-run the Deploy workflow. Review the plan carefully: reverting a change that deleted a stateful resource does not bring the data back.

## Guard rails

- Image tags are immutable per commit SHA, so the previous image always exists in ECR (the lifecycle policy keeps the most recent 10-30 images).
- DynamoDB has point-in-time recovery; a rollback of code does not undo a bad data migration. See the backup restore runbook.
- Production deployments require approval in the GitHub Environment, so a rollback deployment is also reviewed.
