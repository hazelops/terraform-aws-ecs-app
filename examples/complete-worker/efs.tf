# Standard EFS Example from https://github.com/terraform-aws-modules/terraform-aws-efs/blob/v1.6.4/examples/complete/main.tf
module "efs_data" {
  source  = "registry.terraform.io/terraform-aws-modules/efs/aws"
  version = "~> 1.6.0"

  # File system
  name           = "${var.env}-${var.namespace}-data"
  creation_token = "${var.env}-${var.namespace}-data"
  encrypted      = false # disabled for simplicity. Prod must be enabled.

  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  # File system policy
  attach_policy                      = false
  bypass_policy_lockout_safety_check = false

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap(["${var.aws_region}"], module.vpc.private_subnets) : k => { subnet_id = v } }
  security_group_description = "Example EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
  }
}
