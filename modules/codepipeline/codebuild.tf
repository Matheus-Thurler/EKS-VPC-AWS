provider "aws" {
  region = var.region  # Assumindo que você tenha definido a variável 'region' em algum lugar
}

data "aws_caller_identity" "current" {}

resource "aws_codebuild_project" "build" {
  for_each = var.applications

  name          = "${each.value.project_name}-prod-build"
  build_timeout = 25
  description   = "CodeBuild project for ${each.value.project_name}"
  service_role  = aws_iam_role.codebuild_role[each.key].arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }
  cache {
    type = "LOCAL"
  }
}

resource "aws_iam_role" "codebuild_role" {
  for_each = var.applications

  name = "${each.value.project_name}-prod-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  for_each = var.applications

  role = aws_iam_role.codebuild_role[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${each.value.artifact_bucket}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/env/test/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}
