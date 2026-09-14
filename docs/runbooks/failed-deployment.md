# Runbook: failed deployment

**Impact:** no customer impact on its own. The previous version keeps serving traffic; ECS only shifts traffic to healthy tasks.

## 1. Identify where it failed

Open the failed GitHub Actions run. Failures fall into three buckets:

| Stage | Typical cause |
|---|---|
| plan / apply | Terraform error, drift, expired approval, state lock |
| build and push | Dockerfile or dependency error, ECR permissions |
| wait / smoke test | The new revision is unhealthy |

## 2. Terraform stage

- `Error acquiring the state lock`: another run is in progress. Wait for it, then re-run. Only if a run was killed mid-apply, remove the lock file object reported in the error from the state bucket.
- Resource errors: read the last 30 lines of the plan output in the job summary. Fix the configuration, open a PR, merge, re-run.
- Never edit resources by hand to make an apply pass. That creates drift the next apply will fight.

## 3. Build stage

Reproduce locally: `docker build ./app`. If it builds locally, check the ECR login step and that the deploy role still has ECR permissions.

## 4. Unhealthy new revision

```
aws ecs describe-services --cluster $PREFIX-cluster --services $PREFIX-app --region $REGION \
  --query 'services[0].events[0:10]'

aws logs tail /aws/ecs/$PREFIX/app --since 15m --region $REGION
```

The deployment circuit breaker is enabled, so ECS rolls back to the last healthy task definition automatically. Confirm with:

```
aws ecs describe-services --cluster $PREFIX-cluster --services $PREFIX-app --region $REGION \
  --query 'services[0].deployments'
```

Common causes: the container does not listen on the configured port, the health check path returns a non-2xx/3xx status, or a missing environment variable or secret.

## 5. Close out

Record the cause in the pull request or incident note, and add a check to CI if it could have been caught earlier.
