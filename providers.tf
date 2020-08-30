provider "aws" {
  version = ">= 3.4.0"
  region  = local.region
}

provider "kubernetes" {
  version = ">= 1.12.0"
  load_config_file       = false
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  
}

# provider "helm" {
#   kubernetes {
#     load_config_file       = "false"
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   }
# }

provider "random" {
  version = ">= 2.3.0"
}

provider "http" {
  version = ">= 1.2.0"
}

provider "local" {
  version = ">= 1.4.0"
}

provider "null" {
  version = ">= 2.1.2"
}

provider "template" {
  version = ">= 2.1.2"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "http" "my-public-ip" {
  url = "http://ipv4.icanhazip.com"
}
