module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = local.cluster_name
  subnets           = local.private_subnets
  enable_irsa       = true
  workers_role_name = local.workers_role_name

  tags = {
    Environment = local.environment
  }

  vpc_id = local.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = local.workers_instance_type
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = local.workers_desired_size
      asg_max_size                  = local.workers_max_size
      asg_min_size                  = local.workers_min_size
      additional_security_group_ids = [aws_security_group.workers_mgmt.id]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
      ]    
    },
  ]
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  providers = {
    kubernetes = kubernetes
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = local.region
  k8s_cluster_name = local.cluster_name

  depends_on = [
      module.eks
  ]  

}

module "cluster_autoscaler_aws" {
  source = "cookielab/cluster-autoscaler-aws/kubernetes"
  version = "0.9.0"

  aws_iam_role_for_policy = local.workers_role_name

  asg_tags = [
    "k8s.io/cluster-autoscaler/enabled",
    "k8s.io/cluster-autoscaler/${local.cluster_name}",
  ]
  depends_on = [
      module.eks
  ]  

}

module "external_dns_aws" {
  source = "cookielab/external-dns-aws/kubernetes"
  version = "0.9.0"

  domains = [
    "brazil.syntonic.com"
  ]

  sources = [
    "ingress"
  ]

  owner_id = "kube-clb-main"
  aws_iam_role_for_policy = local.workers_role_name

  depends_on = [
      module.eks
  ]  

}

# resource "helm_release" "jenkins" {
#   name  = "cicd"
#   chart = "stable/jenkins"

#   set {
#       name  = "rbac.create"
#       value = "true"
#   }

#   set {
#       name  = "master.servicePort"
#       value = "80"
#   }

#   set {
#       name  = "master.serviceType"
#       value = "LoadBalancer"
#   }

#   set {
#       name  = "master.additionalPlugins"
#       value = "{kubernetes-cd:2.3.0}"
#   }

#   depends_on = [
#       module.eks
#   ]  


# }
