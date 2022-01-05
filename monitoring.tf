# Datadog Logging\Monitoring Module (can be enabled/disabled via datadog_enabled)
module "datadog" {
  source  = "hazelops/ecs-datadog-agent/aws"
  version = "~> 3.0"

  app_name             = var.name
  env                  = var.env
  cloudwatch_log_group = module.service.cloudwatch_log_group
  ecs_launch_type      = var.ecs_launch_type
  enabled              = var.datadog_enabled
}

# Route53-healthcheck Monitoring Module (can be enabled/disabled via route53_health_check_enabled)
module "route_53_health_check" {
  source  = "hazelops/route53-healthcheck/aws"
  version = "~> 1.0"

  enabled                        = var.route53_health_check_enabled
  env                            = var.env
  fqdn                           = var.app_type == "web" ? aws_route53_record.this[0].name : null
  domain_name                    = var.root_domain_name
  name                           = var.name
  subscription_endpoint_protocol = var.sns_service_subscription_endpoint_protocol
  subscription_endpoint          = var.sns_service_subscription_endpoint
}
