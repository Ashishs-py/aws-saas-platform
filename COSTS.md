# Cost assumptions

Figures are indicative monthly on-demand prices for a London/Ireland region, excluding tax and data transfer beyond the stated assumptions. They are planning numbers, not a quote.

## Small profile (dev / early production, ~1-3 tasks)

| Component | Assumption | Est. USD/month |
|---|---|---|
| ECS Fargate (Spot, 0.25 vCPU / 0.5 GB, 1 task) | 730 h | 4 - 6 |
| Application Load Balancer | 1 ALB, low LCU | 18 - 22 |
| AWS WAF | 1 web ACL, 3 rules, <1M requests | 8 - 10 |
| DynamoDB on-demand | <1M requests, 1 GB | 1 - 3 |
| CloudWatch logs, alarms, dashboard | 1 GB ingest, 8 alarms | 2 - 4 |
| Secrets Manager | 1 secret | 0.40 |
| KMS | 1 CMK + requests | 1 - 2 |
| ECR | <1 GB storage | 0.10 |
| AWS Backup | small DynamoDB snapshots | 1 - 2 |
| GuardDuty | small event volume | 3 - 8 |
| S3 (state, CloudTrail) | minimal | 1 - 2 |
| **Total** | | **~40 - 60** |

## Medium profile (production, 2-6 tasks)

| Component | Assumption | Est. USD/month |
|---|---|---|
| ECS Fargate (on-demand, 0.5 vCPU / 1 GB, avg 3 tasks) | 730 h | 45 - 60 |
| NAT gateway | 1 gateway + 50 GB | 35 - 45 |
| Application Load Balancer | moderate LCU | 22 - 30 |
| CloudFront | 100 GB out, 5M requests | 10 - 15 |
| AWS WAF | 1 web ACL, 3 rules, 5M requests | 12 - 18 |
| DynamoDB on-demand + PITR | 10M requests, 10 GB | 15 - 30 |
| CloudWatch + Container Insights | 10 GB ingest | 15 - 25 |
| GuardDuty + Security Hub | moderate volume | 25 - 45 |
| AWS Backup | 120 day retention | 5 - 10 |
| Other (KMS, ECR, Secrets, S3) | | 5 - 8 |
| **Total** | | **~190 - 280** |

## Main cost drivers

1. NAT gateway - fixed hourly charge plus per-GB processing. The largest avoidable line in small environments.
2. Always-on Fargate capacity - driven by minimum task count, not by traffic.
3. Load balancer hours - one ALB per environment; shared ALBs with host-based routing are an option for very small tenants.
4. Observability ingest - Container Insights and verbose logs grow quietly.
5. Threat detection - GuardDuty and Security Hub scale with account activity.

## Optimisation opportunities already implemented

- Fargate Spot for non-production (`use_fargate_spot` in the small profile).
- No NAT gateway in the small profile; S3 gateway endpoint is free and keeps S3 traffic off the internet path.
- DynamoDB on-demand: no idle capacity charge.
- Log retention by profile (7 / 30 / 90 days) and ECR lifecycle policies.
- Container Insights disabled below the medium profile.
- Autoscaling scales in on a 300 second cooldown so capacity is returned promptly.
- VPC flow logs capture rejected traffic only.

## Further optimisation available

- Compute Savings Plans once baseline Fargate usage is steady (up to ~20% for a 1 year commitment).
- Shared ALB across small tenants using host-based routing.
- CloudFront caching policies on static paths to cut origin requests.
- Scheduled scale-to-zero for dev environments outside working hours.
- S3 lifecycle transitions for CloudTrail archives; AWS Backup cold storage after 30 days for long retention.
- AWS Budgets with an alert at 80% of the expected monthly spend per customer.
