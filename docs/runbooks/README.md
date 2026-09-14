# Runbooks

| Situation | Runbook |
|---|---|
| A deployment failed in the pipeline | [failed-deployment.md](failed-deployment.md) |
| The application is not reachable | [application-unavailable.md](application-unavailable.md) |
| A release needs to be rolled back | [rollback.md](rollback.md) |
| A GuardDuty or Security Hub alert fired | [security-alert.md](security-alert.md) |
| Data needs to be restored | [backup-restore.md](backup-restore.md) |
| An environment needs to be removed | [decommission.md](decommission.md) |

Conventions used below:

```
CUSTOMER=customer-a
ENV=dev
REGION=<from customers/$CUSTOMER/$ENV.tfvars>
PREFIX=<customer_code>-$ENV
```
