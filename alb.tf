module "alb" {
  count = var.app_type == "web" || var.app_type == "tcp-app" ? 1 : 0

  source  = "registry.terraform.io/terraform-aws-modules/alb/aws"
  version = "~> 10.2"

  name               = var.public ? local.name : "${local.name}-private"
  load_balancer_type = var.app_type == "web" ? "application" : "network"
  internal           = var.public ? false : true
  vpc_id             = var.vpc_id
  security_groups    = var.alb_security_groups
  subnets            = var.public ? var.public_subnets : var.private_subnets
  idle_timeout       = var.alb_idle_timeout

  enable_deletion_protection = var.alb_enable_deletion_protection



  # ALB v10+ uses listeners map and target_groups map
  listeners = local.alb_listeners

  target_groups = var.app_type == "web" ? local.target_groups_web : local.target_groups_tcp

  # ALB v10+ requires access_logs to be null (not {}) if disabled
  access_logs = var.alb_access_logs_enabled && var.alb_access_logs_s3bucket_name != "" ? {
    bucket = var.alb_access_logs_s3bucket_name
    prefix = var.alb_access_logs_s3prefix
  } : null

  tags = {
    env = var.env
    Env = var.env
  }
}
