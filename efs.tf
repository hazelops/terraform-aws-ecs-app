module "efs" {
  source  = "registry.terraform.io/cloudposse/efs/aws"
  version = "~> 0.31"

  enabled         = var.efs_enabled && var.efs_share_create ? true : false
  stage           = var.env
  name            = var.name
  region          = data.aws_region.current.name
  vpc_id          = var.vpc_id
  security_groups = var.security_groups

  # This is a workaround for 2-zone legacy setups
  subnets = length(regexall("legacy", var.env)) > 0 ? [
    var.private_subnets[0],
    var.private_subnets[1]
  ] : var.private_subnets

}
