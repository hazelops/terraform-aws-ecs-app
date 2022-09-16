locals {
  name             = "${var.env}-${var.name}"
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
}
