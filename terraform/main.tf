# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC (Network) Module ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
data "aws_availability_zones" "available" {}

# --- EKS Cluster Module ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets 
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    fastapi_nodes = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
  enable_cluster_creator_admin_permissions = true
}

# --- Kubernetes and Helm Provider Configuration ---
data "aws_eks_cluster" "cluster" {
  name = "${var.project_name}-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${var.project_name}-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# --- Helm Release (Application Deployment) ---
resource "helm_release" "fastapi_app" {
  depends_on = [module.eks.eks_managed_node_groups]

  name       = lower(var.project_name)
  chart      = "../helm/fastapi-app" 
  namespace  = "default"
  timeout    = 600

  # Pass image and tag from Terraform variables to the Helm chart
  set {
    name  = "image.repository"
    value = split(":", var.app_image_path)[0]
  }
  set {
    name  = "image.tag"
    value = split(":", var.app_image_path)[1]
  }
}

# --- Data Source to fetch the Load Balancer DNS ---
data "kubernetes_service" "fastapi_service" {
  depends_on = [helm_release.fastapi_app]
  
  metadata {
    name = "fastapi-service"
  }
}