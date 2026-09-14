# Customer B - development. Same code, different region and size.
customer_code = "custb"
environment   = "dev"
aws_region    = "eu-west-1"
size_profile  = "medium"

vpc_cidr = "10.30.0.0/16"

enable_account_baseline = false
enable_guardduty        = true
enable_security_hub     = false

enable_waf        = true
enable_cloudfront = false
enable_backup     = true

alarm_email = ""
