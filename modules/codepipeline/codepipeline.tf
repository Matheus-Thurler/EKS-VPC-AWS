resource "aws_codepipeline" "pipeline" {
  for_each = var.applications

  name     = "${each.value.project_name}-prod-pipeline"
  role_arn = aws_iam_role.codepipeline_role[each.key].arn

  artifact_store {
    type     = "S3"
    location = each.value.artifact_bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn  = each.value.codestar_connection_arn
        FullRepositoryId = "${each.value.github_owner}/${each.value.github_repo}"
        BranchName    = " feature/eks"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build[each.key].name
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  for_each = var.applications

  name = "${each.value.project_name}-prod-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  for_each = var.applications

  role = aws_iam_role.codepipeline_role[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:PutBucketAcl"
        ]
        Resource = [
          "arn:aws:s3:::${each.value.artifact_bucket}",
          "arn:aws:s3:::${each.value.artifact_bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      }
    ]
  })
}