locals {
  name             = var.app_type == "tcp-app" ? "${var.env}-${var.name}-tcp" : "${var.env}-${var.name}"
  ecs_service_name = var.ecs_service_name != "" ? var.ecs_service_name : "${var.env}-${var.name}"
  ecs_cluster_name = var.ecs_cluster_name != "" ? var.ecs_cluster_name : "${var.env}-${var.namespace}"
  ecs_cluster_arn  = length(var.ecs_cluster_arn) != "" ? var.ecs_cluster_arn : "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${local.ecs_cluster_name}"
  ecr_repo_name    = var.ecr_repo_name != "" ? var.ecr_repo_name : "${var.namespace}-${var.name}"
  name_prefix      = "${substr(var.name, 0, 5)}-"
  domain_names     = var.root_domain_name != "example.com" ? concat(["${var.name}.${var.env}.${var.root_domain_name}"], var.domain_names) : []

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

      docker_volume_configuration = [{
        "scope" : "task",
        "driver" : "local",
        "labels" : {
          "scratch" : "space"
        }
      }]
    },
    {
      name = "nginx-app",
      mount_point = {
        "sourceVolume"  = "nginx-app"
        "containerPath" = "/etc/nginx/app/"
        "readOnly"      = null
      }

      docker_volume_configuration = [{
        "scope" : "task",
        "driver" : "local",
        "labels" : {
          "scratch" : "space"
        }
      }]
    },
  ]
  : [],

    var.efs_enabled ? [
      {
        name = "efs",
        mount_point = {
          "sourceVolume"  = "efs"
          "containerPath" = var.efs_mount_point,
          "readOnly"      = null
        }

        efs_volume_configuration = [
          {
            file_system_id : module.efs.id
            root_directory : var.efs_root_directory
            transit_encryption : "ENABLED"
            transit_encryption_port : 2999
            authorization_config = {}
          }
        ]
      }
    ] : [],
    (var.datadog_enabled && var.ecs_launch_type == "EC2") ? module.datadog.volumes : []
  )

  http_tcp_listeners = var.app_type == "tcp-app" ? [
    for index, port_mapping in var.port_mappings :
      {
        port               = port_mapping.host_port
        protocol           = "TCP"
        target_group_index = index
      } if port_mapping.https_listener == false
    ] : [
      {
        port               = var.http_port
        protocol           = "HTTP"
        target_group_index = 0
      },]

  https_tls_listeners = var.app_type == "tcp-app" ? [
    for index, port_mapping in var.port_mappings :
      {
        port               = port_mapping.host_port
        protocol           = "TLS"
        certificate_arn    = var.tls_cert_arn
        target_group_index = index
      } if port_mapping.https_listener == true
    ] : [
      {
        port               = 443
        protocol           = "HTTPS"
        certificate_arn    = var.tls_cert_arn
        target_group_index = 0
      },]

  ecs_service_tcp_port_mappings = [
    for index, port_mapping in var.port_mappings :
      {
        container_name      = var.name
        container_port      = port_mapping.container_port
        host_port           = port_mapping.host_port
        target_group_arn    = length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[index] : ""
      }
    ]

  target_groups_web = [
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
    }
  ]

  target_groups_tcp = [
    for port_mapping in var.port_mappings :
    {
      name_prefix          = local.name_prefix
      backend_protocol     = "TCP"
      backend_port         = port_mapping.container_port
      target_type          = var.ecs_launch_type == "EC2" ? "instance" : "ip"
      deregistration_delay = var.alb_deregistration_delay

      health_check = {
        enabled             = true
        interval            = var.alb_health_check_interval
        path                = null
        healthy_threshold   = var.alb_health_check_healthy_threshold
        unhealthy_threshold = var.alb_health_check_unhealthy_threshold
        timeout             = null
        matcher             = null
        port                = port_mapping.host_port
        protocol            = "TCP"
      }
      
    }
  ]
  
}
