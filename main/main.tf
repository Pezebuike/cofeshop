terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Updated to match your desired version 5.8
    }
  }
  backend "s3" {
    # Don't specify actual values here - they will be provided via -backend-config
    # during terraform init
    
    # Explicitly disable profile usage
    profile = ""
    
    # Skip validations that might try to use profiles
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
  }
}


provider "aws" {
  region = var.aws_region
  # Explicitly disable profile usage
  shared_credentials_files = []
  shared_config_files = []
}

# Add the S3 backend configuration here


# create vpc
module "vpc" {
  source                  = "../modules/vpc"
  region                  = var.aws_region
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_az1_cidr  = var.public_subnet_az1_cidr
  public_subnet_az2_cidr  = var.public_subnet_az2_cidr
 
}

# create security group
module "security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# create alb
module "application_load_balancer" {
  source                = "../modules/alb"
  project_name          = module.vpc.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
}


# create ASG
module "asg" {
  source                    = "../modules/asg"
  project_name              = module.vpc.project_name
  public_subnet_az1_id     = module.vpc.public_subnet_az1_id
  public_subnet_az2_id     = module.vpc.public_subnet_az2_id
  application_load_balancer = module.application_load_balancer.application_load_balancer
  alb_target_group_arn      = module.application_load_balancer.alb_target_group_arn
  alb_security_group_id     = module.security_group.alb_security_group_id 
}
