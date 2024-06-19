module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "19.15.1"
  cluster_name                   = var.cluster_name
  cluster_endpoint_public_access = true


  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                      = var.vpc_id
  subnet_ids                  = var.subnet_ids
  control_plane_subnet_ids    = var.intra_subnets
  create_cloudwatch_log_group = true
  iam_role_additional_policies = {
    additional = aws_iam_policy.ecr_policy.arn
  }
  cluster_version = "1.30"

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    instance_types                        = ["t3a.large"]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 3
      max_size     = 5
      desired_size = 3

      instance_types = ["t3a.large"]
      capacity_type  = "ON_DEMAND"
    }
  }
  tags = {
    Environment = var.environment
    Name        = "custer-myapp"
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.1.1" #ensure to update this to the latest/desired version

  cluster_name                        = module.eks.cluster_name
  cluster_endpoint                    = module.eks.cluster_endpoint
  cluster_version                     = module.eks.cluster_version
  oidc_provider_arn                   = module.eks.oidc_provider_arn
  enable_aws_load_balancer_controller = true
  enable_cert_manager                 = true
  enable_metrics_server               = true
  cert_manager = {
    installCRDs = true
  }
  depends_on = [ module.eks ]
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ECRAccessPolicy"
  description = "Policy to allow EKS to access ECR"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "null_resource" "cert_manager_issuer" {
  triggers = {
    manifest_content = file("${path.module}/cert-manager-issuer.yml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/cert-manager-issuer.yml"
  }
}

