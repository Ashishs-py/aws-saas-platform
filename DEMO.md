# 15-minute walkthrough

**Before the call:** `customer-a/dev` deployed and healthy, browser tabs open on the repo, the Actions run summary, the CloudWatch dashboard and the application URL. A terminal in `stack/`.

| Time | Section | What to show | What to say |
|---|---|---|---|
| 0:00 | The problem | README table | "A small team, no platform capacity. They need a secure, monitored, backed-up environment that we can stand up for the next customer without redesigning it." |
| 1:30 | Architecture | ARCHITECTURE.md diagrams | Request path first, then the platform services. Name the AWS patterns: app hosting, secure landing zone, threat detection, cloud backup. |
| 3:30 | The reuse model | `customers/` tree, then `stack/locals.tf` | "One root module. A customer is a tfvars file and a state key. Size is a profile, not a rewrite." |
| 5:00 | **Proof** | `terraform plan -var-file=../customers/customer-b/dev.tfvars` | Show the second customer planning in a different region at a different size with no code change. This is the answer to their main question. |
| 7:00 | Security | Trust policy in `bootstrap/main.tf`, task IAM policy, KMS key | "No AWS keys anywhere. OIDC scoped to this repo. Task role reaches one table." |
| 8:30 | Pipeline | The deploy run summary | Plan as the change record, approval gate on prod, apply, image build, smoke test, evidence table. |
| 10:00 | It runs | The application URL, then the CloudWatch dashboard | Show `/healthz`, then requests, latency, task count. Mention alarms and the SNS topic. |
| 11:30 | Operations | `docs/runbooks/` | Open the rollback runbook. Mention the circuit breaker rolls back automatically. |
| 13:00 | Cost | COSTS.md | Small ~40-60 USD, medium ~190-280 USD. Main drivers: NAT, always-on tasks, ALB hours. Optimisations already in the code: Spot in dev, no NAT in small, retention by profile. |
| 14:00 | Where it goes next | README roadmap | Account per customer under Control Tower, private registry, Service Catalog, Marketplace listing. |

## Questions to expect, and short answers

**Why Fargate and not EKS?** The customer has no platform team. Fargate removes nodes and patching. EKS is justified once they need multi-tenant scheduling or a service mesh.

**Why DynamoDB and not RDS?** The reference workload is key-value, and on-demand removes idle cost and failover operations. Swapping in an RDS module changes one module call; nothing else in the stack moves.

**Tasks in public subnets in the small profile?** Deliberate cost decision. No inbound path exists: the task security group only accepts the ALB security group. Medium and large enable NAT and move tasks to private subnets — one flag in the size profile.

**How do you stop one customer affecting another?** Separate state key, separate VPC, separate KMS key and tags today; separate AWS accounts under Organizations in the target model.

**How would you handle secrets rotation?** Secrets Manager holds the value, the task reads it at start-up, and rotation is a Lambda rotation function plus a service redeploy. The pipeline never sees the value.

**What is missing that you would add next?** Custom domains with Route 53 and ACM, ALB access logs to S3, AWS Config conformance packs, per-customer budgets, and a canary or blue/green release with CodeDeploy.
