@echo off
REM Usage: scripts\whats-running.cmd eu-west-2
REM Lists the resources that actually cost money per hour, so you can prove
REM the account is clean after a destroy. All of these API calls are free.
setlocal
set REGION=%~1
if "%REGION%"=="" set REGION=eu-west-2

echo.
echo === Load balancers (billed per hour) ===
aws elbv2 describe-load-balancers --region %REGION% --query "LoadBalancers[].LoadBalancerName" --output table

echo === NAT gateways (the expensive one - should be empty) ===
aws ec2 describe-nat-gateways --region %REGION% --filter Name=state,Values=available --query "NatGateways[].NatGatewayId" --output table

echo === Elastic IPs (billed when unattached) ===
aws ec2 describe-addresses --region %REGION% --query "Addresses[].PublicIp" --output table

echo === Running ECS services ===
aws ecs list-clusters --region %REGION% --query "clusterArns" --output table

echo === EC2 instances (there should never be any) ===
aws ec2 describe-instances --region %REGION% --filters Name=instance-state-name,Values=running --query "Reservations[].Instances[].InstanceId" --output table

echo === RDS instances (there should never be any) ===
aws rds describe-db-instances --region %REGION% --query "DBInstances[].DBInstanceIdentifier" --output table

echo === WAF web ACLs (5 USD/month each, billed hourly) ===
aws wafv2 list-web-acls --scope REGIONAL --region %REGION% --query "WebACLs[].Name" --output table

echo === GuardDuty detectors (free for 30 days, then charged) ===
aws guardduty list-detectors --region %REGION% --query "DetectorIds" --output table

echo.
echo If every table above is empty, nothing in %REGION% is costing you money.
