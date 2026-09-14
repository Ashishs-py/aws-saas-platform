# bucket is supplied at init time (-backend-config="bucket=...") so no account
# specific value is committed to the repository.
key          = "customer-b/dev/terraform.tfstate"
region       = "REPLACE_WITH_STATE_REGION"
encrypt      = true
use_lockfile = true
