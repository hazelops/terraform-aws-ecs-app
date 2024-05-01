# TODO: This should probably be encapsulated into aicm "app" module
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2.0"
  count = var.ecr_repo_create ? 1 : 0

  repository_name = local.ecr_repo_name

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  create_lifecycle_policy           = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = var.ecr_force_delete
}
