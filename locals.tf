locals {
  name             = "${var.env}-${var.name}"
  ecs_service_name = var.ecs_service_name != "" ? var.ecs_service_name : "${var.env}-${var.name}"
  ecs_cluster_name = var.ecs_cluster_name
  ecs_cluster_arn  = length(var.ecs_cluster_arn) != "" ? var.ecs_cluster_arn : "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${local.ecs_cluster_name}"
  ecr_repo_name    = var.ecr_repo_name != "" ? var.ecr_repo_name : var.name
  name_prefix      = "${substr(var.name, 0, 5)}-"
  domain_names     = var.root_domain_name != "" ? concat([
    "${var.name}.${var.env}.${var.root_domain_name}"
  ], var.domain_names) : []

  # EFS access points - default configuration in terraform-aws-modules/efs format
  efs_access_points_default = {
    "data" = {
      name = "data"
      posix_user = {
        gid            = 1001
        uid            = 5000
        secondary_gids = [1002, 1003]
      }
      root_directory = {
        path = "/"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 5000
          permissions = "0755"
        }
      }
    }
  }

  # Use provided var.efs_access_points or fall back to default
  efs_access_points = length(var.efs_access_points) > 0 ? var.efs_access_points : local.efs_access_points_default

  # Datadog Environment Variables: https://docs.datadoghq.com/agent/guide/environment-variables/
  #                                https://docs.datadoghq.com/agent/docker/apm/?tab=linux#docker-apm-agent-environment-variables
  datadog_env_vars = var.datadog_enabled ? {
    DD_PROFILING_ENABLED        = "true"
    DD_TRACE_ENABLED            = "true"
    DD_RUNTIME_METRICS_ENABLED  = "true"
    DD_APM_ENABLED              = "true"
    DD_SERVICE                  = var.name
    DD_SERVICE_NAME             = var.name
    DD_ENV                      = var.env
    DD_AGENT_HOST               = local.datadog_agent_host
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://${local.datadog_agent_host}:4318"
    OTEL_TRACES_EXPORTER        = "otlp"
    OTEL_RESOURCE_ATTRIBUTES    = "service.name=${var.name}"
  } : {}

  datadog_agent_host = (var.ecs_network_mode != "host" && var.ecs_network_mode != "awsvpc") ? "datadog-agent" : "localhost"

  ecs_exec_env_vars = var.ecs_exec_custom_prompt_enabled ? {
    PS1 = var.ecs_exec_prompt_string
  } : {}

  fluentbit_container_definition = [
    {
      essential         = true
      image             = "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest"
      name              = "log_router"
      memoryReservation = 75
      firelensConfiguration = {
        "type" = "fluentbit"
        "options" = {
          "enable-ecs-log-metadata" = "true"
        }
      }
    }
  ]

  volumes = concat(var.web_proxy_enabled ? [
    {
      name = "nginx-templates",
      mount_point = {
        "sourceVolume"  = "nginx-templates"
        "containerPath" = "/etc/nginx/templates/"
        "readOnly"      = null
      }

      docker_volume_configuration = [
        {
          "scope" : "task",
          "driver" : "local",
          "labels" : {
            "scratch" : "space"
          }
        }
      ]
    },
    {
      name = "nginx-app",
      mount_point = {
        "sourceVolume"  = "nginx-app"
        "containerPath" = "/etc/nginx/app/"
        "readOnly"      = null
      }

      docker_volume_configuration = [
        {
          "scope" : "task",
          "driver" : "local",
          "labels" : {
            "scratch" : "space"
          }
        }
      ]
    },
  ] : [],
      var.efs_enabled ? [
      {
        name = "efs",
        mount_point = {
          "sourceVolume"  = "efs"
          "containerPath" = var.efs_mount_point,
          "readOnly"      = null
        }

        # We are passing the config only if we are not creating the share via the module.
        efs_volume_configuration = [
          {
            file_system_id : var.efs_share_create ? module.efs.id : var.efs_file_system_id
            root_directory : var.efs_root_directory
            transit_encryption : "ENABLED"
            transit_encryption_port : 2999
            authorization_config : var.efs_share_create && length(module.efs.access_points) > 0 ? {
              access_point_id = try(values(module.efs.access_points)[0].id, null)
              iam             = "ENABLED"
            } : (var.efs_share_create ? {} : var.efs_authorization_config)
          }
        ]
      }
    ] : [],
      (var.datadog_enabled && var.ecs_launch_type == "EC2") ? module.datadog.volumes : []
  )

  # ALB v10+ now uses a listeners map instead of separate http_tcp_listeners and https_listeners arrays
  # Locals used to avoid conditional type inconsistency
  _http_listener = {
    http = {
      port     = var.http_port
      protocol = "HTTP"
      forward = {
        target_group_key = "tg-0"
      }
    }
  }

  _https_listener = var.https_enabled ? {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.tls_cert_arn
      forward = {
        target_group_key = "tg-0"
      }
    }
  } : {}

  _tcp_listeners = {
    for index, port_mapping in var.port_mappings :
    "tcp-${port_mapping["host_port"]}" => {
      port     = port_mapping["host_port"]
      protocol = "TCP"
      forward = {
        target_group_key = "tg-${index}"
      }
    } if !lookup(port_mapping, "tls", false)
  }

  _tls_listeners = var.https_enabled ? {
    for index, port_mapping in var.port_mappings :
    "tls-${port_mapping["host_port"]}" => {
      port            = port_mapping["host_port"]
      protocol        = "TLS"
      certificate_arn = var.tls_cert_arn
      forward = {
        target_group_key = "tg-${index}"
      }
    } if lookup(port_mapping, "tls", false)
  } : {}

  alb_listeners = merge(
      var.app_type == "tcp-app" ? local._tcp_listeners : local._http_listener,
      var.app_type == "tcp-app" ? local._tls_listeners : local._https_listener
  )

  ecs_service_tcp_port_mappings = [
    for index, port_mapping in var.port_mappings :
    {
      container_name = var.name
      container_port = port_mapping["container_port"]
      host_port      = port_mapping["host_port"]
      # ALB v10+ target_groups is a map, not an array
      target_group_arn = length(module.alb) >= 1 ? module.alb[0].target_groups["tg-${index}"].arn : ""
    }
  ]

  # ALB v10+ uses a target_groups map with named keys instead of arrays
  target_groups_web = {
    "tg-0" = {
      name_prefix          = local.name_prefix
      protocol             = "HTTP"
      port                 = var.web_proxy_enabled ? var.web_proxy_docker_container_port : var.docker_container_port
      target_type          = var.ecs_launch_type == "EC2" ? "instance" : "ip"
      deregistration_delay = var.alb_deregistration_delay
      preserve_client_ip   = null
      create_attachment    = false # ECS service handles target registration automatically

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
    }
  }

  target_groups_tcp = {
    for index, port_mapping in var.port_mappings :
    "tg-${index}" => {
      name_prefix          = local.name_prefix
      protocol             = "TCP"
      port                 = port_mapping["container_port"]
      target_type          = var.ecs_launch_type == "EC2" ? "instance" : "ip"
      deregistration_delay = var.alb_deregistration_delay
      preserve_client_ip   = true
      create_attachment    = false # ECS service handles target registration automatically

      health_check = {
        enabled             = true
        protocol            = "TCP"
        port                = port_mapping["host_port"]
        interval            = var.alb_health_check_interval
        healthy_threshold   = var.alb_health_check_healthy_threshold
        unhealthy_threshold = var.alb_health_check_unhealthy_threshold
      }
    }
  }

  asg_ecs_ec2_user_data = templatefile(
    "${path.module}/templates/ecs_ec2_user_data.sh.tpl",
    {
      ecs_cluster_name  = local.ecs_cluster_name
      service           = local.name
      env               = var.env
      ec2_service_group = var.ec2_service_group
      ec2_eip_enabled   = tostring(var.ec2_eip_enabled)
    }, )
}
