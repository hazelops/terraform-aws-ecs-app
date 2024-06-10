module "alb" {
  count = var.app_type == "web" || var.app_type == "tcp-app" ? 1 : 0

  source  = "registry.terraform.io/terraform-aws-modules/alb/aws"
  version = "~> 7.0"

  name               = var.public ? local.name : "${local.name}-private"
  load_balancer_type = var.app_type == "web" ? "application" : "network"
  internal           = var.public ? false : true
  vpc_id             = var.vpc_id
  security_groups    = len(var.alb_security_groups) > 0 ? var.alb_security_groups : var.security_groups
  subnets            = var.public ? var.public_subnets : var.private_subnets
  idle_timeout       = var.alb_idle_timeout



  http_tcp_listeners = local.alb_http_tcp_listeners
  https_listeners    = var.https_enabled ? concat(local.alb_https_listeners) : []

  target_groups = concat(var.app_type == "web" ? local.target_groups_web : local.target_groups_tcp)

  access_logs = var.alb_access_logs_enabled && var.alb_access_logs_s3bucket_name != "" ? {
    bucket = var.alb_access_logs_s3bucket_name
    prefix = var.alb_access_logs_s3prefix
  } : {}

  tags = {
    env = var.env
    Env = var.env
  }
}
