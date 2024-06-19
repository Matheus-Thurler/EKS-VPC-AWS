variable "applications" {
  description = "Map of application configurations."
  type = map(object({
    project_name            = string
    github_owner            = string
    github_repo             = string
    codestar_connection_arn = string
    artifact_bucket         = string
  }))
}

variable "region" {
  
}