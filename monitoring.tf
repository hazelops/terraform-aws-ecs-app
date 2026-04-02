# Datadog Monitoring Module - Fargate (can be enabled/disabled via datadog_enabled)
module "datadog_fargate" {
  count  = var.datadog_enabled && var.ecs_launch_type == "FARGATE" ? 1 : 0
  source = "github.com/hazelops/terraform-aws-ecs-datadog//modules/ecs_fargate?ref=feature/core-1560-datadog-module-created-based-on-theirs-and-our-modules"

  create_task_definition = false
  create_task_role       = false

  family            = "${var.env}-${var.name}"
  dd_api_key_secret = { arn = local.dd_api_key_secret_arn }
  dd_image_version  = var.datadog_jmx_enabled ? "latest-jmx" : "latest"
  dd_env            = var.env
  dd_service        = var.name
  dd_environment    = []
  dd_log_collection = {
    enabled = true
  }
}

# Datadog Monitoring Module - EC2 (can be enabled/disabled via datadog_enabled)
module "datadog_ec2" {
  count  = var.datadog_enabled && var.ecs_launch_type == "EC2" ? 1 : 0
  source = "github.com/hazelops/terraform-aws-ecs-datadog//modules/ecs_ec2?ref=feature/core-1560-datadog-module-created-based-on-theirs-and-our-modules"

  create_task_definition = false
  create_task_role       = false
  create_service         = false

  family            = "${var.env}-${var.name}"
  dd_api_key_secret = { arn = local.dd_api_key_secret_arn }
  dd_image_version  = var.datadog_jmx_enabled ? "latest-jmx" : "latest"
  dd_environment    = []
  dd_log_collection = {
    enabled = true
  }
  network_mode      = var.ecs_network_mode
}

# Route53-healthcheck Monitoring Module (can be enabled/disabled via route53_health_check_enabled)
module "route_53_health_check" {
  count = var.route53_health_check_enabled ? 1 : 0

  source  = "registry.terraform.io/hazelops/route53-healthcheck/aws"
  version = "~> 3.0"

  enabled                        = var.route53_health_check_enabled
  env                            = var.env
  fqdn                           = var.app_type == "web" ? aws_route53_record.alb[0].name : null
  domain_name                    = var.root_domain_name
  name                           = var.name
  subscription_endpoint_protocol = var.sns_service_subscription_endpoint_protocol
  subscription_endpoint          = var.sns_service_subscription_endpoint
}
