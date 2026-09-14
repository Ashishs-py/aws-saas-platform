# Runbook: application unavailable

**Trigger:** `*-unhealthy-targets`, `*-target-5xx` or `*-alb-5xx` alarm, or a customer report.

## 1. Confirm the symptom

```
curl -i http://<alb-dns-name>/healthz
```

| Observation | Likely layer |
|---|---|
| Connection refused / timeout | DNS, CloudFront, ALB, security group |
| HTTP 503 | No healthy targets |
| HTTP 403 with the origin message | Request bypassed CloudFront |
| HTTP 5xx from the app | Application or dependency |

## 2. Check targets

```
aws elbv2 describe-target-health --target-group-arn <arn> --region $REGION
aws ecs describe-services --cluster $PREFIX-cluster --services $PREFIX-app --region $REGION \
  --query 'services[0].{desired:desiredCount,running:runningCount,pending:pendingCount}'
```

Running count of zero means tasks cannot start: look at the last service events for capacity, image pull or secret access errors.

## 3. Check application logs

```
aws logs tail /aws/ecs/$PREFIX/app --since 30m --follow --region $REGION
```

Open the CloudWatch dashboard `$PREFIX-overview` for request rate, 5xx and p95 latency to see whether this is load related.

## 4. Common causes and actions

| Cause | Action |
|---|---|
| Bad release | Follow the rollback runbook |
| Load beyond current capacity | Raise `max_capacity` in the size profile, or temporarily `aws ecs update-service --desired-count` |
| Dependency failure (DynamoDB throttling, expired secret) | Check the dashboard and Secrets Manager; DynamoDB is on-demand so throttling is rare and short |
| WAF blocking legitimate traffic | Inspect sampled requests in the WAF console; if a managed rule is the cause, move it to count mode and deploy the change |
| Single AZ impairment | Both subnets are in use; confirm the second AZ is serving and raise desired count |

## 5. Communicate

Post status at 15 minute intervals until healthy. After recovery, confirm the alarm returns to OK; the topic sends OK notifications for the availability alarms.
