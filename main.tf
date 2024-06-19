module "vpc" {
  source              = "./modules/vpc"
  aws_region          = var.aws_region
  cluster_name        = var.cluster_name
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_public_subnets  = var.vpc_public_subnets
  vpc_private_subnets = var.vpc_private_subnets
  vpc_intra_subnets   = var.vpc_intra_subnets
  environment         = var.environment
  vpc_name            = var.vpc_name
}

module "eks" {
  source        = "./modules/eks"
  environment   = var.environment
  cluster_name  = var.cluster_name
  subnet_ids    = module.vpc.private_subnets
  intra_subnets = module.vpc.intra_subnets
  vpc_id        = module.vpc.vpc_id
}

module "codepipelines" {
  source = "./modules/codepipeline"
  applications = var.applications
  region = var.aws_region
}
