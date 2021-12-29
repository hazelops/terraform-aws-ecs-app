module "task" {
  source = "../ecs-task"

  env                         = var.env
  name                        = var.name

  ecs_task_family_name        = var.ecs_service_name != "" ? var.ecs_service_name : ""
  ecs_launch_type             = var.ecs_launch_type
  ecs_network_mode            = var.ecs_network_mode
  ecs_volumes_from            = var.ecs_volumes_from
  ecs_exec_enabled            = var.ecs_exec_enabled

  docker_image_name           = var.docker_image_name
  docker_image_tag            = var.docker_image_tag
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)
  docker_container_command    = (var.docker_container_command == [] ? [] : var.docker_container_command)
  docker_container_depends_on = var.docker_container_depends_on
  
  docker_container_links      = var.docker_container_links

  environment                 = var.environment                 # Non-secret Environment variables
  service_secrets             = local.service_secrets
  global_secrets              = local.global_secrets

  cpu                           = var.cpu
  memory                        = var.memory
  volumes                       = var.volumes
  resource_requirements         = var.resource_requirements
  iam_role_policy_statement     = var.iam_role_policy_statement
  sidecar_container_definitions = var.sidecar_container_definitions
  firelens_ecs_log_enabled      = var.firelens_ecs_log_enabled

  port_mappings = var.web_proxy_enabled ? [] : var.port_mappings # We don't forward ports from the container if we are using proxy (proxy reaches out to container via internal network)
}


resource "aws_service_discovery_service" "this" {
  count = var.ecs_service_discovery_enabled ? 1 : 0

  name = var.name

  dns_config {
    namespace_id   = var.ecs_service_discovery_enabled ? var.aws_service_discovery_private_dns_namespace.id : ""
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
  health_check_custom_config {
    failure_threshold = 5
  }
}

# This service resource has task definition lifecycle policy, so terraform is NOT used to deploy it (ecs cli used instead)
resource "aws_ecs_service" "this" {
  count                              = var.ecs_service_deployed ? 0 : 1
  name                               = var.ecs_service_name != "" ? var.ecs_service_name : "${var.env}-${var.name}"
  platform_version                   = var.ecs_platform_version
  cluster                            = var.ecs_cluster_name
  task_definition                    = module.task.task_definition_arn
  desired_count                      = var.service_desired_count
  launch_type                        = var.ecs_launch_type
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_execute_command             = var.ecs_exec_enabled


  dynamic "service_registries" {
    for_each = (var.ecs_launch_type == "FARGATE" && var.ecs_service_discovery_enabled) ? [1] : []
    content {
      registry_arn = var.ecs_service_discovery_enabled ? aws_service_discovery_service.this.arn : ""
      port         = var.docker_container_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.ecs_launch_type == "FARGATE" ? [1] : []
    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = [for p in var.port_mappings : {
      container_name   = p.container_name
      target_group_arn = p.target_group_arn
      container_port   = p.container_port

    }]

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "placement_constraints" {
    for_each = var.ecs_launch_type == "EC2" ? [1] : []
    content {
      type       = "memberOf"
      expression = "attribute:service-group == ${var.ec2_service_group}"
    }
  }

  #   Do not overwite external updates back to Terraform value
  #   This means we only set that value once - during creation.
  lifecycle {
    ignore_changes = [
      # Ignore as we use SCALE to change the settings.
      //desired_count,
      # Ignore Task Definition ARN changes.
      # Every time we deploy via ecs-deploy and then run Terraform
      # we will keep the Task Definition deployed with via ecs-delploy
      task_definition
    ]
  }
}

# This service resource doesn't have task definition lifecycle policy, so terraform is used to deploy it (instead of ecs cli)
resource "aws_ecs_service" "this_deployed" {
  count                              = var.ecs_service_deployed ? 1 : 0
  name                               = var.ecs_service_name != "" ? var.ecs_service_name : "${var.env}-${var.name}"
  platform_version                   = var.ecs_platform_version
  cluster                            = var.ecs_cluster_name
  task_definition                    = module.task.task_definition_arn
  desired_count                      = var.service_desired_count
  launch_type                        = var.ecs_launch_type
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_execute_command             = var.ecs_exec_enabled

  dynamic "service_registries" {
    for_each = (var.ecs_launch_type == "FARGATE" && var.ecs_service_discovery_enabled) ? [1] : []
    content {
      registry_arn = var.ecs_service_discovery_enabled ? aws_service_discovery_service.this.arn : ""
      port         = var.docker_container_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.ecs_launch_type == "FARGATE" ? [1] : []
    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = [for p in var.port_mappings : {
      container_name   = p.container_name
      container_port   = p.container_port
      target_group_arn = p.target_group_arn
    }]

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "placement_constraints" {
    for_each = var.ecs_launch_type == "EC2" ? [1] : []
    content {
      type       = "memberOf"
      expression = "attribute:service-group == ${var.ec2_service_group}"
    }
  }

  lifecycle {
    ignore_changes = []
  }
}

# CloudWatch Event rules for worker mode
resource "aws_cloudwatch_event_rule" "this" {
  count = length(var.cloudwatch_schedule_expressions)

  name                = var.ecs_service_name != "" ? "${var.ecs_service_name}-${count.index}" : "${var.env}-${var.name}-${count.index}"
  description         = "Cloudwatch event rule for ECS Scheduled Task"
  schedule_expression = var.cloudwatch_schedule_expressions[count.index]
}

resource "aws_cloudwatch_event_target" "this" {
  count = length(var.cloudwatch_schedule_expressions)

  target_id = var.ecs_service_name != "" ? "${var.ecs_service_name}-${count.index}" : "${var.env}-${var.name}-${count.index}"
  arn       = data.aws_ecs_cluster.current.arn
  rule      = aws_cloudwatch_event_rule.this[count.index].name
  role_arn  = aws_iam_role.ecs_events[0].arn

  ecs_target {
    launch_type         = var.ecs_launch_type
    task_count          = var.ecs_target_task_count
    task_definition_arn = module.task.task_definition_arn
    platform_version    = var.ecs_platform_version

    network_configuration {
      assign_public_ip = var.assign_public_ip
      security_groups  = var.security_groups
      subnets          = var.subnets
    }
  }
}
