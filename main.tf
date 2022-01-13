module "alb" {
  count = var.app_type == "web" ? 1 : 0

  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = var.public ? local.name : "${local.name}-private"
  load_balancer_type = "application"
  internal           = var.public ? false : true
  vpc_id             = var.vpc_id
  security_groups    = var.alb_security_groups
  subnets            = var.public ? var.public_subnets : var.private_subnets
  idle_timeout       = var.alb_idle_timeout

  http_tcp_listeners = [
    {
      port               = var.http_port
      protocol           = "HTTP"
      target_group_index = 0
  }, ]

  https_listeners = var.tls_cert_arn != null ? concat(
    [
      {
        port               = 443
        protocol           = "HTTPS"
        certificate_arn    = var.tls_cert_arn
        target_group_index = 0
      }
    ]) : []

  target_groups = concat([
    {
      name_prefix          = local.name_prefix
      backend_protocol     = "HTTP"
      backend_port         = var.web_proxy_enabled ? var.web_proxy_docker_container_port : var.docker_container_port
      target_type          = var.ecs_launch_type == "EC2" ? "instance" : "ip"
      deregistration_delay = var.alb_deregistration_delay

      health_check = {
        enabled             = true
        interval            = var.alb_health_check_interval
        path                = var.alb_health_check_path
        healthy_threshold   = var.alb_health_check_healthy_threshold
        unhealthy_threshold = var.alb_health_check_unhealthy_threshold
        timeout             = var.alb_health_check_timeout
        matcher             = var.alb_health_check_valid_response_codes
        port                = "traffic-port"
        protocol            = "HTTP"
      }

      tags = {
        Name = var.name
        env  = var.env
        app  = local.name
      }
    }
  ])

  tags = {
    env = var.env
    Env = var.env
  }
}

module "ecr" {
  source  = "hazelops/ecr/aws"
  version = "~> 1.0"

  name    = local.ecr_repo_name
  enabled = var.ecr_repo_create
}

module "efs" {
  source  = "cloudposse/efs/aws"
  version = "~> 0.31"

  enabled         = var.efs_enabled
  namespace       = var.namespace
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

module "service" {
  source = "./ecs-modules/ecs-service"

  env              = var.env
  name             = var.name
  namespace        = var.namespace
  ecs_cluster_name = local.ecs_cluster_name
  ecs_service_name = local.ecs_service_name

  ecs_platform_version  = var.ecs_launch_type == "FARGATE" ? var.ecs_platform_version : null
  ecs_launch_type       = var.ecs_launch_type
  ec2_service_group     = var.ec2_service_group
  docker_container_port = var.docker_container_port
  ecs_network_mode      = var.ecs_network_mode
  ecs_volumes_from      = var.ecs_volumes_from
  cpu                   = var.cpu
  memory                = var.memory
  volumes               = local.volumes
  assign_public_ip      = var.assign_public_ip
  security_groups       = var.security_groups

  web_proxy_enabled     = var.web_proxy_enabled
  ecs_exec_enabled      = var.ecs_exec_enabled
  subnets               = var.public_service ? var.public_subnets : var.private_subnets

  # length(var.cloudwatch_schedule_expressions) > 1 means that it is cron task and desired_count should be 0
  cloudwatch_schedule_expressions = var.cloudwatch_schedule_expressions

  service_desired_count         = length(var.cloudwatch_schedule_expressions) > 1 ? 0 : var.desired_capacity
  max_size                      = var.max_size
  min_size                      = var.min_size
  autoscale_enabled             = var.autoscale_enabled
  autoscale_scheduled_up        = var.autoscale_scheduled_up
  autoscale_scheduled_down      = var.autoscale_scheduled_down
  autoscale_target_value_cpu    = var.autoscale_target_value_cpu
  autoscale_target_value_memory = var.autoscale_target_value_memory

  docker_container_entrypoint = var.docker_container_entrypoint
  docker_container_command    = var.docker_container_command
  docker_image_name           = var.docker_image_name != "" ? var.docker_image_name : "${var.docker_registry}/${var.namespace}-${var.name}"
  docker_image_tag            = var.docker_image_tag
  iam_role_policy_statement   = var.iam_role_policy_statement

  app_secrets    = var.app_secrets
  global_secrets = var.global_secrets

  ecs_service_deployed                        = var.cloudwatch_schedule_expressions == [] ? false : true
  deployment_minimum_healthy_percent          = var.deployment_minimum_healthy_percent
  aws_service_discovery_private_dns_namespace = var.aws_service_discovery_private_dns_namespace
  firelens_ecs_log_enabled                    = var.firelens_ecs_log_enabled

  resource_requirements = var.gpu > 0 ? [
    {
      type  = "GPU"
      value = tostring(var.gpu)
  }] : []


  sidecar_container_definitions = concat(
    var.web_proxy_enabled ? [module.nginx.container_definition] : [],
    var.datadog_enabled ? [module.datadog.container_definition] : [],
    var.firelens_ecs_log_enabled ? local.fluentbit_container_definition : []
  )

  docker_container_links = concat(
    var.datadog_enabled && var.ecs_network_mode == "bridge" ? [
      "datadog-agent:datadog-agent"
  ] : [])

  docker_container_depends_on = concat(
    # TODO: This needs to be pulled from datadog agent module output
    var.datadog_enabled ? [
      {
        containerName = "datadog-agent",
        condition     = "START"
    }, ] : []
  )

  # TODO: instead of hardcoding the index, better use dynamic lookup by a canonical name
  target_group_arn = var.app_type == "web" && length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[0] : null

  port_mappings = var.app_type == "web" ? [
    {
      container_name   = var.web_proxy_enabled ? "nginx" : var.name
      container_port   = var.web_proxy_enabled ? var.web_proxy_docker_container_port : var.docker_container_port
      host_port        = var.ecs_network_mode == "awsvpc" ? (var.web_proxy_enabled ? var.web_proxy_docker_container_port : var.docker_container_port) : 0
      target_group_arn = length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[0] : ""
    }
  ] : []

  environment = merge(var.environment, local.datadog_env_vars, {
    APP_NAME      = var.name
    ENV           = var.env
    PROXY_ENABLED = var.web_proxy_enabled ? "true" : "false"
    },
    var.ecs_launch_type == "EC2" ? {
      DD_AGENT_HOST = "datadog-agent"
    } : {}
  )
}

resource "aws_route53_record" "this" {
  count   = var.app_type == "web" ? length(local.domain_names) : 0
  zone_id = var.zone_id
  name    = local.domain_names[count.index]
  type    = "A"

  alias {
    name                   = module.alb[0].this_lb_dns_name
    zone_id                = module.alb[0].this_lb_zone_id
    evaluate_target_health = true
  }
}

