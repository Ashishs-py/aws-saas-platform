# Customer configuration

Adding a customer is a configuration change, not a code change.

1. Create `customers/customer-x/<env>.tfvars` with the customer code, region and size profile.
2. Create `customers/customer-x/<env>.backend.hcl` with a unique state key.
3. Run the pipeline with `customer=customer-x` and `environment=<env>`.

Nothing in `stack/` or `modules/` changes. Account IDs, regions and customer
names never appear in the module code.

| Customer | Env | Region | Size | CIDR |
|---|---|---|---|---|
| customer-a | dev | eu-west-2 | small | 10.20.0.0/16 |
| customer-a | prod | eu-west-2 | medium | 10.21.0.0/16 |
| customer-b | dev | eu-west-1 | medium | 10.30.0.0/16 |
| customer-b | prod | eu-west-1 | large | 10.31.0.0/16 |
