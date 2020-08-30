# module "ssh-bastion-service" {
#   source = "joshuamkite/ssh-bastion-service/aws"
#   aws_region                    = local.region
#   environment_name              = local.environment
#   vpc                           = local.vpc_id
#   subnets_asg                   = local.private_subnets
#   subnets_lb                    = local.public_subnets
#   cidr_blocks_whitelist_service = local.allowssh_ips
#   public_ip                     = true
#   depends_on = [
#       module.vpc
#   ]
# }