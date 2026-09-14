# Customer B - production
customer_code = "custb"
environment   = "prod"
aws_region    = "eu-west-1"
size_profile  = "large"

vpc_cidr = "10.31.0.0/16"

enable_account_baseline = false
enable_guardduty        = true
enable_security_hub     = true

enable_waf        = true
enable_cloudfront = true
enable_backup     = true

alarm_email = ""
