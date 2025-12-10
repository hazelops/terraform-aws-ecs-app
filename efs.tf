module "efs" {
  source  = "registry.terraform.io/terraform-aws-modules/efs/aws"
  version = "~> 1.0"

  create = var.efs_enabled && var.efs_share_create ? true : false

  name = var.name
#   tags = {
#     Environment = var.env
#   }

  # Создаем security group для EFS
  create_security_group = true
  security_group_vpc_id = var.vpc_id

  # Разрешаем доступ из существующих security groups
  security_group_ingress_rules = {
    for idx, sg_id in var.security_groups :
    "from_sg_${idx}" => {
      referenced_security_group_id = sg_id
      description                  = "NFS from application security group"
    }
  }

  # Mount targets
  mount_targets = {
    for idx, subnet_id in (
      length(regexall("legacy", var.env)) > 0 ? [
      var.private_subnets[0],
      var.private_subnets[1]
    ] : var.private_subnets
    ) : "mount-${idx}" => {
      subnet_id = subnet_id
    }
  }

  # Access points
  access_points = var.efs_access_points
}
