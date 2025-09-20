# AtonixCorp Platform - AWS Infrastructure
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }

  backend "s3" {
    bucket = "atonixcorp-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
    
    dynamodb_table = "atonixcorp-terraform-locks"
    encrypt        = true
  }
}

# Provider Configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "AtonixCorp Platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
    }
  }
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local Values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  name_prefix         = local.name_prefix
  cidr_block         = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  
  tags = local.common_tags
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"
  
  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  
  cluster_version = var.eks_cluster_version
  node_groups     = var.eks_node_groups
  
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  name_prefix       = local.name_prefix
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  
  engine_version   = var.rds_engine_version
  instance_class   = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  
  db_name  = var.db_name
  username = var.db_username
  
  tags = local.common_tags
}

# ElastiCache Module
module "elasticache" {
  source = "./modules/elasticache"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
  
  node_type          = var.elasticache_node_type
  num_cache_clusters = var.elasticache_num_clusters
  
  tags = local.common_tags
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  name_prefix = local.name_prefix
  
  tags = local.common_tags
}

# CloudFront Module
module "cloudfront" {
  source = "./modules/cloudfront"
  
  name_prefix = local.name_prefix
  s3_bucket   = module.s3.static_bucket_domain_name
  alb_domain  = module.eks.load_balancer_dns_name
  
  tags = local.common_tags
}

# Route53 Module
module "route53" {
  source = "./modules/route53"
  
  domain_name        = var.domain_name
  cloudfront_domain  = module.cloudfront.domain_name
  alb_domain        = module.eks.load_balancer_dns_name
  
  tags = local.common_tags
}

# ACM Module
module "acm" {
  source = "./modules/acm"
  
  domain_name = var.domain_name
  zone_id     = module.route53.zone_id
  
  tags = local.common_tags
}