module "alb" {
  count = var.app_type == "web" || var.app_type == "tcp-app" ? 1 : 0

  source  = "registry.terraform.io/terraform-aws-modules/alb/aws"
  version = "~> 7.0"

  name               = var.public ? local.name : "${local.name}-private"
  load_balancer_type = var.app_type == "web" ? "application" : "network" 
  internal           = var.public ? false : true
  vpc_id             = var.vpc_id
  security_groups    = var.alb_security_groups
  subnets            = var.public ? var.public_subnets : var.private_subnets
  idle_timeout       = var.alb_idle_timeout

  http_tcp_listeners = local.http_tcp_listeners
  https_listeners    = var.https_enabled ? concat(local.https_tls_listeners) : []

  target_groups      = concat(var.app_type == "web" ? local.target_groups_web : local.target_groups_tcp)

  tags = {
    env = var.env
    Env = var.env
  }
}

module "ecr" {
  source  = "registry.terraform.io/hazelops/ecr/aws"
  version = "~> 1.0"

  name         = local.ecr_repo_name
  enabled      = var.ecr_repo_create
  force_delete = var.ecr_force_delete
}

module "efs" {
  source  = "registry.terraform.io/cloudposse/efs/aws"
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
  app_type         = var.app_type
  ecs_cluster_name = local.ecs_cluster_name
  ecs_cluster_arn  = local.ecs_cluster_arn
  ecs_service_name = local.ecs_service_name

  ecs_platform_version          = var.ecs_launch_type == "FARGATE" ? var.ecs_platform_version : null
  ecs_launch_type               = var.ecs_launch_type
  ecs_task_health_check_command = var.ecs_task_health_check_command
  ec2_service_group             = var.ec2_service_group
  docker_container_port         = var.docker_container_port
  ecs_network_mode              = var.ecs_network_mode
  ecs_volumes_from              = var.ecs_volumes_from
  cpu                           = var.cpu
  memory                        = var.memory
  memory_reservation            = var.memory_reservation
  volumes                       = local.volumes
  assign_public_ip              = var.assign_public_ip
  security_groups               = var.security_groups
  operating_system_family       = var.operating_system_family
  cpu_architecture              = var.cpu_architecture

  web_proxy_enabled = var.web_proxy_enabled
  ecs_exec_enabled  = var.ecs_exec_enabled
  subnets           = var.public_ecs_service ? var.public_subnets : var.private_subnets

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
  autoscale_scheduled_timezone  = var.autoscale_scheduled_timezone
  autoscaling_min_size          = var.autoscaling_min_size
  autoscaling_max_size          = var.autoscaling_max_size

  docker_container_entrypoint                = var.docker_container_entrypoint
  docker_container_command                   = var.docker_container_command
  docker_image_name                          = var.docker_image_name != "" ? var.docker_image_name : "${var.docker_registry}/${var.namespace}-${var.name}"
  docker_image_tag                           = var.docker_image_tag
  iam_role_policy_statement                  = var.iam_role_policy_statement
  additional_container_definition_parameters = var.additional_container_definition_parameters

  app_secrets    = var.app_secrets
  global_secrets = var.global_secrets

  ecs_service_deployed                        = (var.cloudwatch_schedule_expressions == [] || !var.ecs_service_deployed) ? false : true
  deployment_minimum_healthy_percent          = var.deployment_minimum_healthy_percent
  aws_service_discovery_private_dns_namespace = var.aws_service_discovery_private_dns_namespace
  firelens_ecs_log_enabled                    = var.firelens_ecs_log_enabled
  tmpfs_enabled                               = var.tmpfs_enabled
  tmpfs_size                                  = var.tmpfs_size
  tmpfs_container_path                        = var.tmpfs_container_path
  tmpfs_mount_options                         = var.tmpfs_mount_options
  shared_memory_size                          = var.shared_memory_size
  # TODO: This should be expanded to read some standard labels from datadog module to configure JMX, http and other checks. per https://docs.datadoghq.com/agent/docker/integrations/?tab=docker#configuration
  docker_labels                               = var.docker_labels

  resource_requirements = var.gpu > 0 ? [
    {
      type  = "GPU"
      value = tostring(var.gpu)
    }
  ] : []


  sidecar_container_definitions = concat(
    var.sidecar_container_definitions,
    var.web_proxy_enabled ? [
      module.nginx.container_definition
    ] : [],
    var.datadog_enabled ? [
      module.datadog.container_definition
    ] : [],
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
      },
    ] : []
  )


  # TODO: instead of hardcoding the index, better use dynamic lookup by a canonical name
  target_group_arn = var.app_type == "web" && length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[0] : null

  port_mappings = jsondecode(var.app_type == "web" ? jsonencode([
    {
      container_name   = var.web_proxy_enabled ? "nginx" : var.name
      container_port   = var.web_proxy_enabled ? var.web_proxy_docker_container_port : var.docker_container_port
      host_port        = var.ecs_network_mode == "awsvpc" ? (var.web_proxy_enabled ? var.web_proxy_docker_container_port : var.docker_container_port) : var.docker_host_port
      target_group_arn = length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[0] : ""
    }
  ]) : ( var.app_type == "tcp-app" ? jsonencode(local.ecs_service_tcp_port_mappings) : jsonencode(var.port_mappings)))

  environment = merge(var.environment, local.datadog_env_vars, local.ecs_exec_env_vars, {
    APP_NAME      = var.name
    ENV           = var.env
    PROXY_ENABLED = var.web_proxy_enabled ? "true" : "false"
  }
  )
}

resource "aws_route53_record" "alb" {
  count   = var.app_type == "web" || var.app_type == "tcp-app" ? length(local.domain_names) : 0
  zone_id = var.zone_id
  name    = local.domain_names[count.index]
  type    = "A"

  alias {
    name                   = module.alb[0].lb_dns_name
    zone_id                = module.alb[0].lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2" {
  count   = (var.ecs_launch_type == "EC2" && var.ec2_eip_enabled && var.ec2_eip_dns_enabled) ? length(local.domain_names) : 0
  zone_id = var.zone_id
  name    = local.domain_names[count.index]
  type    = "A"

  records = var.ec2_eip_enabled ? aws_eip.autoscaling.*.public_ip : []
}

