# Keeping the demo close to zero cost

## What this platform deliberately does NOT create in the `small` profile

| Expensive service | Monthly cost if used | Status here |
|---|---|---|
| NAT gateway | ~32 USD + data | **Off.** `enable_nat_gateway = false` in the small profile. Tasks run in public subnets with no inbound path; the task security group only accepts the ALB security group. |
| RDS instance | ~15-200 USD | **Never created.** DynamoDB on-demand is used instead. |
| CloudFront | usage based | **Off.** `enable_cloudfront = false` for dev. |
| Container Insights | ~10-25 USD | **Off** below the medium profile. |
| Security Hub | ~10-40 USD | **Off** for dev. |
| EC2 / EKS / ElastiCache / Route 53 zone | varies | Not part of the design. |
| Interface VPC endpoints | ~7 USD each | Not used. Only the **free** S3 gateway endpoint. |

## What does cost something, and how much per hour

| Service | Rate | 3 hours |
|---|---|---|
| Application Load Balancer | ~0.024 USD/h (free tier covers 750 h/month in the first 12 months) | 0.00 - 0.08 USD |
| Fargate Spot, 0.25 vCPU / 0.5 GB, 1 task | ~0.004 USD/h | ~0.01 USD |
| AWS WAF web ACL + 3 rules | 8 USD/month billed hourly, ~0.011 USD/h | ~0.03 USD |
| KMS customer managed key | 1 USD/month billed hourly | ~0.004 USD |
| Secrets Manager | 0.40 USD/month | ~0.002 USD |
| DynamoDB, ECR, S3, CloudWatch, CloudTrail, GuardDuty | free tier / free trial | ~0.00 USD |
| **Total** | | **under 0.20 USD** |

## Absolute minimum mode

For the build and test phase, set `enable_waf = false` in `customers/customer-a/dev.tfvars`. That removes the largest remaining line. Set it back to `true` about thirty minutes before the interview so WAF is live and demonstrable when it matters. Everything else is fractions of a cent per hour.

Cost per hour in minimum mode is roughly 0.005 USD. Leaving it running for a full week would cost under 1 USD.

## Rules that keep it at zero

1. Run `scripts\destroy.cmd customer-a dev` the moment you finish a session.
2. Run `scripts\whats-running.cmd eu-west-2` afterwards. Empty tables mean an empty bill.
3. Never `apply` a `medium`, `large` or `prod` configuration. Those exist to be **planned**, which is free and is what proves repeatability.
4. Keep a zero-spend AWS Budget alert on the account.
5. Never leave an Elastic IP allocated without a NAT gateway attached to it.
