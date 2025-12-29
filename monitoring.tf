# Datadog Logging/Monitoring Module (can be enabled/disabled via datadog_enabled)
module "datadog" {
  source  = "registry.terraform.io/hazelops/ecs-datadog-agent/aws"
  version = "~> 4.0"

  app_name             = var.name
  env                  = var.env
  cloudwatch_log_group = module.service.cloudwatch_log_group
  ecs_launch_type      = var.ecs_launch_type
  enabled              = var.datadog_enabled
  docker_image_tag     = var.datadog_jmx_enabled ? "latest-jmx" : "latest"
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
