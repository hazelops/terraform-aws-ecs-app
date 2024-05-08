module "ecr" {
  source  = "registry.terraform.io/hazelops/ecr/aws"
  version = "~> 1.1"

  name         = local.ecr_repo_name
  enabled      = var.ecr_repo_create
  force_delete = var.ecr_force_delete
}
