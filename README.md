# \# AWS SaaS Platform

# 

# A reusable AWS environment for a growing SaaS company, built with Terraform and GitHub Actions.

# 

# The point of this repository is that onboarding a second customer, or a fiftieth, is a configuration change rather than a new project. The same code deploys:

# 

# ```

# customers/customer-a/dev.tfvars   ->  eu-west-2, small profile

# customers/customer-b/dev.tfvars   ->  eu-west-1, medium profile

# ```

# 

# Different region, different sizing, different network range. No module is edited, no resource is renamed by hand.

# 

# \## The problem this solves

# 

# A small engineering team with a production web application ends up spending its week on infrastructure instead of the product. They need an environment that is secure by default, deploys itself, scales without anyone watching it, is backed up, and tells someone when it breaks. They do not need a platform team to run it.

# 

# That is what this builds, and it builds the same thing every time.

# 

# \## What gets deployed

# 

# Traffic arrives at an Application Load Balancer sitting in front of AWS WAF, and is served by ECS Fargate tasks spread across two availability zones. The tasks store data in DynamoDB and read their runtime secret from Secrets Manager. Images come from ECR, built and pushed by the pipeline.

# 

# Around that sit the parts a customer would otherwise have to assemble themselves: a customer-managed KMS key with rotation encrypting everything that supports it, CloudTrail, VPC flow logs, GuardDuty, a CloudWatch dashboard with eight alarms wired to an SNS topic, and AWS Backup running a tag-driven daily plan.

# 

# Sizing is a profile, not a rewrite. `small` runs a single Spot task with no NAT gateway. `medium` runs two on-demand tasks in private subnets behind NAT, with Container Insights and longer retention. `large` adds a third AZ. The profiles live in `stack/locals.tf` and are the only place capacity decisions are made.

# 

# Design reasoning is in \[ARCHITECTURE.md](ARCHITECTURE.md), costs in \[COSTS.md](COSTS.md), operations in \[docs/runbooks](docs/runbooks/README.md).

# 

# \## How it is put together

# 

# ```

# bootstrap/      Run once per AWS account: state bucket and the CI IAM role

# stack/          The root module. Composes everything. Deployed per customer/env

# modules/        network, security, data, ecr, compute, edge, observability, backup

# customers/      One tfvars and one state key per customer environment

# app/            Reference container: /, /healthz, /api/items

# .github/        CI, deploy and destroy workflows

# docs/runbooks/  What to do at 3am

# ```

# 

# No account ID, customer name or region appears anywhere in `modules/` or `stack/`. The account ID comes from `aws\_caller\_identity` at plan time; everything else is a variable with a validated value.

# 

# \## Running it

# 

# \*\*Once per AWS account\*\*, create the shared state bucket and the role GitHub assumes:

# 

# ```bash

# cd bootstrap

# cp terraform.tfvars.example terraform.tfvars   # org prefix, state region, GitHub owner/repo

# terraform init \&\& terraform apply

# ```

# 

# Put the three outputs into GitHub under Settings, Secrets and variables, Actions: the role ARN as a secret, and the state bucket and region as variables.

# 

# \*\*Per customer environment\*\*, either run the Deploy workflow and pick the customer and environment, or locally:

# 

# ```bash

# cd stack

# terraform init -reconfigure \\

# &#x20; -backend-config="bucket=<state-bucket>" \\

# &#x20; -backend-config="region=<state-region>" \\

# &#x20; -backend-config="key=customer-a/dev/terraform.tfstate" \\

# &#x20; -backend-config="encrypt=true" -backend-config="use\_lockfile=true"

# 

# terraform apply -var-file=../customers/customer-a/dev.tfvars

# terraform output application\_url

# ```

# 

# The first apply runs a public placeholder image on the application port, so the network path, load balancer, health checks and task placement are proven healthy before any application code exists. The pipeline then builds `app/`, pushes it to ECR and releases it through Terraform, so state always matches what is actually running.

# 

# On Windows there are wrappers in `scripts/`: `deploy.cmd customer-a dev`, `plan.cmd customer-b dev`, `destroy.cmd customer-a dev`, and `whats-running.cmd eu-west-2` to confirm nothing billable is left behind.

# 

# \## The pipeline

# 

# A pull request runs format checks, `terraform validate`, a Trivy IaC scan, a Checkov policy scan and a Docker build.

# 

# A deployment runs a plan first and writes it to the job summary as the change record. Production deployments then stop at a GitHub Environment with a required reviewer. After approval it applies the infrastructure, builds and pushes the image, applies again to release it, waits for the ECS service to stabilise, polls `/healthz` until it answers, and finally writes an evidence table with the customer, environment, region, image tag, URL and commit.

# 

# If a release never becomes healthy, the ECS deployment circuit breaker rolls it back without anyone intervening.

# 

# \## Security decisions worth calling out

# 

# \*\*No static AWS credentials in the target design.\*\* The bootstrap stack provisions a GitHub OIDC provider and a role whose trust policy is scoped to this repository, so the pipeline exchanges a short-lived GitHub token for AWS credentials with nothing stored.

# 

# \*\*The blast radius of a task is one table.\*\* The task role can read and write a single DynamoDB table and decrypt with a single key. The execution role can read one secret. Nothing has wildcard resource access.

# 

# \*\*The ALB is the only way in.\*\* The task security group accepts traffic from the ALB security group and nothing else. Where CloudFront is enabled, the ALB rejects any request that does not carry a secret origin header, so the edge cannot be bypassed by hitting the load balancer directly.

# 

# \*\*Separate state per customer.\*\* One key per customer environment, in a versioned, encrypted, TLS-only bucket with native locking. A mistake in one customer cannot touch another's state.

# 

# \## Trade-offs I made deliberately

# 

# \*\*No NAT gateway in the small profile.\*\* A NAT gateway costs about as much per month as the rest of a small environment combined. Tasks run in public subnets with a public IP for image pulls, but no inbound path exists because the security group only admits the ALB. The medium and large profiles flip one flag and move the tasks into private subnets.

# 

# \*\*DynamoDB rather than RDS.\*\* The reference workload is key-value, and on-demand billing removes idle instance cost, failover operations and patching. Where a customer needs relational features, the `data` module is swapped for an RDS module and nothing else in the stack moves.

# 

# \*\*Fargate rather than EKS.\*\* A team with no platform capacity should not be running nodes or a control plane. EKS earns its complexity once there is multi-tenant scheduling or a service mesh to justify it; at this customer size it is overhead.

# 

# \*\*Fargate Spot in non-production.\*\* Roughly seventy percent cheaper, and an interrupted dev task is not an incident.

# 

# \*\*Regional WAF on the ALB rather than only at CloudFront.\*\* The origin stays protected whether or not a given customer has CloudFront turned on.

# 

# \## What is not here yet

# 

# Custom domains with Route 53 and ACM, which need a domain to exist first. ALB access logs to S3. AWS Config conformance packs. Per-customer AWS Budgets. Blue/green releases through CodeDeploy.

# 

# The larger one: in production each customer would get their own AWS account under Organizations and Control Tower, with this stack as the workload baseline. This repository deploys multiple isolated stacks into a single account, which is the right shape for a demonstration and the wrong shape for a real multi-customer business. The change is to the account model, not to this code.

# 

# \## Tearing it down

# 

# ```bash

# cd stack \&\& terraform destroy -var-file=../customers/customer-a/dev.tfvars

# ```

# 

# Full checklist including the per-region security services: \[docs/runbooks/decommission.md](docs/runbooks/decommission.md).

# 

# \## Toward a Marketplace listing

# 

# Package the stack behind a thin per-customer wrapper module in a private Terraform registry, versioned with semantic tags. Add a Service Catalog product and a CloudFormation launch wrapper so a buyer can subscribe and launch into their own account. Move to one account per customer under Control Tower. Add per-customer metering tags and cost allocation reporting as the basis for a SaaS listing.

