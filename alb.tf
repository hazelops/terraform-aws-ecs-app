module "alb" {
  count = var.app_type == "web" || var.app_type == "tcp-app" ? 1 : 0

  source  = "registry.terraform.io/terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = var.public ? local.name : "${local.name}-private"
  load_balancer_type = var.app_type == "web" ? "application" : "network"
  internal           = var.public ? false : true
  vpc_id             = var.vpc_id
  security_groups    = var.alb_security_groups
  subnets            = var.public ? var.public_subnets : var.private_subnets
  idle_timeout       = var.alb_idle_timeout

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }
#   http_tcp_listeners = local.alb_http_tcp_listeners
#   https_listeners    = var.https_enabled ? concat(local.alb_https_listeners) : []

  target_groups = concat(var.app_type == "web" ? local.target_groups_web : local.target_groups_tcp)

  access_logs = var.alb_access_logs_enabled && var.alb_access_logs_s3bucket_name != "" ? {
    bucket = var.alb_access_logs_s3bucket_name
  } : {}

  tags = {
    env = var.env
    Env = var.env
  }
}
