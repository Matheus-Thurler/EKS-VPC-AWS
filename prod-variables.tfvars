aws_region = "us-east-1"

# VPC VARIABLES
vpc_name            = "my-vpc"
vpc_cidr_block      = "10.10.0.0/16"
vpc_public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]
vpc_private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
vpc_intra_subnets   = ["10.10.3.0/24", "10.10.4.0/24"]
environment         = "prod"

# EKS VARIABLES

cluster_name = "eks-myapp"


applications = {
  app1 = {
    project_name            = "app1"
    github_owner            = "owner1"
    github_repo             = "repo1"
    codestar_connection_arn = "arn:aws:codestar-connections:region:account-id:connection/connection-id1"
    artifact_bucket         = "bucket1"
  },
  app2 = {
    project_name            = "app2"
    github_owner            = "owner2"
    github_repo             = "repo2"
    codestar_connection_arn = "arn:aws:codestar-connections:region:account-id:connection/connection-id2"
    artifact_bucket         = "bucket2"
  }
}
