# Customer A - development
customer_code = "custa"
environment   = "dev"
aws_region    = "eu-west-2"
size_profile  = "small"

vpc_cidr = "10.20.0.0/16"

# Account level baseline is created once per AWS account. In the target model
# each customer has its own account and this is true for every customer.
enable_account_baseline = true
enable_guardduty        = false
enable_security_hub     = false

enable_waf        = true
enable_cloudfront = false
enable_backup     = true

alarm_email = ""
