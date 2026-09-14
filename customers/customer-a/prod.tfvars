# Customer A - production
customer_code = "custa"
environment   = "prod"
aws_region    = "eu-west-2"
size_profile  = "medium"

vpc_cidr = "10.21.0.0/16"

enable_account_baseline = false
enable_guardduty        = true
enable_security_hub     = true

enable_waf        = true
enable_cloudfront = true
enable_backup     = true

alarm_email = ""
