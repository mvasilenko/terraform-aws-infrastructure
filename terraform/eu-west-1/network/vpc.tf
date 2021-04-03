module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name = "demo-vpc"
  cidr = "172.20.0.0/20"

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["172.20.0.0/24", "172.20.1.0/24", "172.20.2.0/24"]

  enable_nat_gateway = false

  tags = {
    Owner       = "demo"
    Environment = "dev"
    Terraform   = "true"
  }

  vpc_tags = {
    Name = "demo-vpc"
  }
}
