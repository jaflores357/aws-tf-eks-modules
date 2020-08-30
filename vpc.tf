module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                                 = "${local.cluster_name}-vpc"
  cidr                                 = "10.0.0.0/16"
  azs                                  = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets                      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets                       = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway                   = true
  single_nat_gateway                   = false
  enable_dns_hostnames                 = true
  //enable_ecr_dkr_endpoint              = true
  //ecr_dkr_endpoint_private_dns_enabled = true
  //ecr_dkr_endpoint_security_group_ids  = [aws_security_group.vpc_endpoint.id]
  enable_s3_endpoint                   = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "Environment" = local.environment
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}
