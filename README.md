# AWS SaaS Platform — reusable landing zone and application platform

A production-shaped AWS environment for a small SaaS company, delivered as Terraform modules and a GitHub Actions pipeline. The same code deploys Customer A in `eu-west-2` at `small` size and Customer B in `eu-west-1` at `medium` size. **Only configuration changes.**

```
customers/customer-a/dev.tfvars    ->  custa-dev  eu-west-2  small
customers/customer-b/dev.tfvars    ->  custb-dev  eu-west-1  medium
```

## What it gives the customer

| Requirement | Delivered by |
|---|---|
| Secure AWS environment | Per-environment VPC, private-by-design security groups, KMS CMK with rotation, IAM roles only, CloudTrail, VPC flow logs |
| Reliable application hosting | ECS Fargate across two AZs behind an ALB, health checks, rolling deploys with automatic rollback |
| Automated deployments | GitHub Actions with OIDC federation, no AWS keys stored anywhere |
| Scaling | Target-tracking autoscaling on CPU, min/max per size profile |
| Monitoring | CloudWatch dashboard, eight alarms, log-based error alerting, SNS to on-call |
| Backups | AWS Backup vault and tag-driven plan, DynamoDB PITR |
| Threat detection | GuardDuty with findings routed to the on-call topic, Security Hub FSBP |
| Reduced operational overhead | No servers, no patching, runbooks for the five situations that actually page someone |

Architecture and design rationale: [ARCHITECTURE.md](ARCHITECTURE.md). Cost model: [COSTS.md](COSTS.md). Runbooks: [docs/runbooks](docs/runbooks/README.md).

## Repository layout

```
bootstrap/            One-time per AWS account: state bucket + GitHub OIDC role
stack/                The root module. Composes every module. Deployed per customer/env
modules/
  network/            VPC, subnets, routing, optional NAT, S3 endpoint, flow logs
  security/           KMS CMK, CloudTrail, GuardDuty, Security Hub
  data/               DynamoDB with KMS and PITR
  ecr/                Image repository, scan on push, lifecycle policy
  compute/            ALB, ECS cluster/service/task, IAM roles, autoscaling
  edge/               WAF managed rules and rate limiting, optional CloudFront
  observability/      SNS, alarms, dashboard, GuardDuty event routing
  backup/             Backup vault, plan and tag-based selection
customers/            One tfvars + one backend config per customer environment
app/                  Reference container: /, /healthz, /api/items
.github/workflows/    ci.yml, deploy.yml, destroy.yml
docs/runbooks/        Operational runbooks
```

## Prerequisites

- An AWS account and a local profile with permission to create IAM, S3, VPC and ECS resources
- Terraform >= 1.10, AWS CLI v2, Docker, Git
- A GitHub repository. Make it **public** (or Team/Enterprise) if you want required reviewers on the production environment

## 1. Bootstrap (once per AWS account)

Creates the Terraform state bucket and the IAM role GitHub Actions assumes through OIDC.

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # set org_prefix, state_region, github owner/repo
terraform init
terraform apply
```

Record the outputs and set them in GitHub (**Settings → Secrets and variables → Actions**):

| GitHub setting | Value |
|---|---|
| Secret `AWS_ROLE_ARN` | `github_deploy_role_arn` output |
| Variable `TF_STATE_BUCKET` | `state_bucket` output |
| Variable `TF_STATE_REGION` | `state_region` output |

## 2. Deploy a customer environment

From the pipeline (**Actions → Deploy → Run workflow**), choose the customer and environment. Or locally:

```bash
cd stack
terraform init -reconfigure \
  -backend-config="bucket=<state-bucket>" \
  -backend-config="region=<state-region>" \
  -backend-config="key=customer-a/dev/terraform.tfstate" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform apply -var-file=../customers/customer-a/dev.tfvars
terraform output application_url
```

The first apply runs a public placeholder image so the environment is provably healthy before any application code exists. The pipeline then builds `app/`, pushes it to ECR and releases it through Terraform.

## 3. Deploy a second customer

```bash
terraform init -reconfigure -backend-config="key=customer-b/dev/terraform.tfstate" ...
terraform plan -var-file=../customers/customer-b/dev.tfvars
```

Different region, different size, different CIDR, same code. Onboarding customer 10 or customer 50 is two files in `customers/`.

## Pipeline

| Stage | Workflow | What it does |
|---|---|---|
| Format and lint | `ci.yml` | `terraform fmt -check -recursive` |
| Validate | `ci.yml` | `terraform validate`, customer config sanity checks |
| Security scan | `ci.yml` | Trivy IaC scan and Checkov policy scan |
| Image build | `ci.yml` | Docker build on every pull request |
| Plan | `deploy.yml` | Plan written to the job summary as the change record |
| Approval | `deploy.yml` | GitHub Environment `prod` with required reviewers |
| Deploy | `deploy.yml` | Terraform apply, build and push image, release through Terraform |
| Smoke test | `deploy.yml` | Polls `/healthz` until 200 or fails the run |
| Evidence | `deploy.yml` | Customer, environment, region, image, URL, commit and outputs in the summary |

## Security posture

- **No static AWS credentials.** GitHub Actions authenticates with OIDC; the trust policy is scoped to this repository, the `main` branch, its environments and pull requests.
- **Encryption everywhere.** Customer-managed KMS key with rotation for DynamoDB, ECR, CloudWatch Logs, SNS, Secrets Manager and the backup vault. TLS-only bucket policies.
- **Least privilege at runtime.** The task role can touch one DynamoDB table; the execution role can read one secret and decrypt with one key.
- **Network.** The ALB is the only public entry point. Tasks accept traffic from the ALB security group alone. Flow logs capture rejected traffic.
- **Detection.** GuardDuty findings of severity 4 and above reach on-call through EventBridge and SNS within minutes.
- **No customer names, account IDs or regions in code.** Account ID comes from `aws_caller_identity`; everything else is a variable.

## Tear down

```bash
cd stack && terraform destroy -var-file=../customers/customer-a/dev.tfvars
```

Full checklist, including the per-region security services: [docs/runbooks/decommission.md](docs/runbooks/decommission.md).

## Roadmap toward AWS Marketplace

1. Package the stack behind a thin `customer` wrapper module published to a private Terraform registry, versioned with semantic tags.
2. Add a Service Catalog product and CloudFormation launch wrapper so a buyer can subscribe and launch into their own account.
3. Move from one account with many stacks to one account per customer under AWS Organizations and Control Tower, with this stack as the workload baseline.
4. Add per-customer metering tags and a cost allocation report as the basis for a Marketplace SaaS listing.
