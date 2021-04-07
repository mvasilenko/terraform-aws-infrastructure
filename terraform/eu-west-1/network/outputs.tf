output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "sg_http_https" {
  value = aws_security_group.http_https.id
}

output "sg_local" {
  value = aws_security_group.local.id
}

output "sg_ssh" {
  value = aws_security_group.ssh.id
}
