# Runbook: security alert

**Trigger:** GuardDuty finding of severity 4 or above routed to the alert topic by EventBridge, or a Security Hub control failure.

## 1. Triage (first 15 minutes)

```
aws guardduty list-findings --detector-id <id> --region $REGION \
  --finding-criteria '{"Criterion":{"severity":{"Gte":4}}}'
aws guardduty get-findings --detector-id <id> --finding-ids <id> --region $REGION
```

Record: finding type, affected resource, first and last seen, severity.

| Severity | Response |
|---|---|
| 7.0 - 8.9 (high) | Treat as an incident now. Engage the customer's security contact. |
| 4.0 - 6.9 (medium) | Investigate within one business day. |
| Below 4.0 | Review in the weekly security review. |

## 2. Contain

| Finding type | Containment |
|---|---|
| Compromised task / unusual outbound traffic | Isolate by replacing the task security group with a deny-all group, then stop the task. ECS starts a replacement, so capture evidence first. |
| Credential exfiltration (`UnauthorizedAccess:IAMUser/*`) | The platform uses no static keys. Revoke active sessions on the affected role and rotate any secret it could read. |
| Suspicious API activity | Query CloudTrail for the principal and the time window; disable the principal if it is not expected. |
| Public exposure finding | Confirm against Terraform; correct in code, never only in the console. |

## 3. Investigate

- CloudTrail for the API calls made by the principal.
- VPC flow logs (rejected traffic) for the affected ENI.
- Application logs in `/aws/ecs/$PREFIX/app`.

## 4. Recover and close

- Rotate the application secret in Secrets Manager and redeploy so tasks pick it up.
- Apply the permanent fix through Terraform and a pull request.
- Archive the finding with a note. If the finding is a known false positive, add a suppression rule rather than ignoring the alert.

## 5. Standing controls

CloudTrail with log file validation, GuardDuty, Security Hub FSBP, KMS with rotation, least-privilege task roles, OIDC instead of static keys, WAF managed rules, and IaC-only change control.
