output "vpc_id" { value = aws_vpc.this.id }
output "vpc_cidr" { value = aws_vpc.this.cidr_block }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }

# Tasks run in private subnets when a NAT gateway exists, otherwise in public
# subnets with a public IP so images can be pulled. Ingress is still restricted
# to the ALB security group in both cases.
output "app_subnet_ids" {
  value = var.enable_nat_gateway ? aws_subnet.private[*].id : aws_subnet.public[*].id
}

output "app_assign_public_ip" {
  value = !var.enable_nat_gateway
}
