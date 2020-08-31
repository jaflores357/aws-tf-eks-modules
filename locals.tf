locals {
  environment              = terraform.workspace
  cluster_name             = "${terraform.workspace}-${var.cluster-name}"
  workers_instance_type    = "${var.workers_instance_type[terraform.workspace]}"
  workers_desired_size     = "${var.workers_desired_size[terraform.workspace]}"
  workers_min_size         = "${var.workers_min_size[terraform.workspace]}"
  workers_max_size         = "${var.workers_max_size[terraform.workspace]}"
  workers_role_name        = "${terraform.workspace}-${var.cluster-name}-workers-role"
  region                   = var.region
  private_subnets          = module.vpc.private_subnets
  private_cidr_blocks      = module.vpc.private_subnets_cidr_blocks
  public_subnets           = module.vpc.public_subnets
  elasticache_subnets      = module.vpc.elasticache_subnets
  vpc_id                   = module.vpc.vpc_id
  allow_ssh_ips            = ["${chomp(data.http.my-public-ip.body)}/32"]
}
