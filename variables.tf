locals {
  name             = "${var.env}-${var.name}"
  ecs_service_name = var.ecs_service_name != "" ? var.ecs_service_name : "${var.env}-${var.name}"
  name_prefix      = "${substr(var.name, 0, 5)}-"
  namespace        = "${var.env}-${var.namespace}"
  ecs_cluster_name = var.ecs_cluster_name != "" ? var.ecs_cluster_name : local.namespace
  domain_names     = ["${var.name}.${var.env}.${var.root_domain_name}"]
  ecr_repo_name    = var.ecr_repo_name != "" ? var.ecr_repo_name : "${var.namespace}-${var.name}"

  # Datadog Environment Variables: https://docs.datadoghq.com/agent/guide/environment-variables/
  #                                https://docs.datadoghq.com/agent/docker/apm/?tab=linux#docker-apm-agent-environment-variables
  datadog_env_vars = var.datadog_enabled ? {
    DD_PROFILING_ENABLED       = "true"
    DD_TRACE_ENABLED           = "true"
    DD_RUNTIME_METRICS_ENABLED = "true"
    DD_APM_ENABLED             = "true"
    DD_SERVICE                 = var.name
    DD_SERVICE_NAME            = var.name
    DD_ENV                     = var.env
  } : {}

  fluentbit_container_definition = [
    {
      essential         = true
      image             = "amazon/aws-for-fluent-bit:latest"
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

variable "env" {
  type        = string
  description = "Target environment name of the infrastructure"
}

variable "namespace" {
  type        = string
  description = "Namespace name within the infrastructure"
}

variable "name" {
  type        = string
  description = "ECS app name"
}

variable "app_type" {
  type        = string
  description = "ECS application type. Valid values: web (with load balancer), worker (scheduled task without ALB)."
  default     = "web"

  validation {
    condition     = var.app_type == "web" || var.app_type == "worker"
    error_message = "The app_type value must be a valid type: web or worker."
  }
}

variable "ecs_service_name" {
  default     = ""
  type        = string
  description = "The ECS service name"
}

variable "ecs_platform_version" {
  description = "The platform version on which to run your service. Only applicable when using Fargate launch type"
  default     = "LATEST"
  type        = string
}


variable "ec2_service_group" {
  description = "Service group name, e.g. app, service name etc."
  type        = string
  default     = "app"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for ECS"
  default     = "t3.micro"
}

variable "environment" {
  type        = map(string)
  description = "Set of environment variables"
}

variable "public" {
  description = "It's publicity accessible application"
  type        = bool
  default     = true
}

variable "app_secrets" {
  type        = list(any)
  description = "List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/*"
  default     = []
}

variable "ssm_secret_path" {
  type        = string
  description = "AWS SSM root path to environment secrets of an app like /dev/app1"
  default     = null
}

variable "global_secrets" {
  type        = list(any)
  description = "List of SSM ParameterStore global secrets - by default, /$var.env/global/*"
  default     = []
}

variable "ssm_global_secret_path" {
  type        = string
  description = "AWS SSM root path to global environment secrets like /dev/global"
  default     = null
}

variable "public_subnets" {
  type        = list(any)
  description = "VPC Public subnets to place ECS resources"
  default     = []
}

variable "private_subnets" {
  type        = list(any)
  description = "VPC Private subnets to place ECS resources"
  default     = []
}

variable "security_groups" {
  type        = list(any)
  description = "Security groups to assign to ECS Fargate task/ECS EC2"
  default     = []
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile"
  default     = null
}

variable "iam_role_policy_statement" {
  type        = list(any)
  description = "ECS Service IAM Role policy statement"
  default     = []
}

variable "key_name" {
  type        = string
  description = "EC2 key name"
  default     = null
}

variable "image_id" {
  type        = string
  description = "EC2 AMI id"
  default     = null
}

variable "root_domain_name" {
  type        = string
  description = "Domain name of AWS Route53 Zone"
}

variable "domain_names" {
  type        = list(any)
  description = "Domain names for AWS Route53 A records"
  default     = []
}

variable "zone_id" {
  type        = string
  description = "AWS Route53 Zone ID"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "alb_security_groups" {
  type        = list(any)
  description = "Security groups to assign to ALB"
  default     = []
}

variable "docker_registry" {
  type        = string
  description = "ERC docker registry"
}

# It should include registry, e.g. hashicorp/terraform
variable "docker_image_name" {
  type        = string
  description = "Docker image name"
  default     = ""
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "docker_container_port" {
  description = "Docker container port"
  type        = number
  default     = 3000
}

variable "docker_container_command" {
  type        = list(string)
  description = "Docker container command"
  default     = []
}

variable "alb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "ecs_launch_type" {
  type        = string
  description = "ECS launch type: FARGATE or EC2"
  default     = "FARGATE"

  validation {
    condition     = var.ecs_launch_type == "FARGATE" || var.ecs_launch_type == "EC2"
    error_message = "The ecs_launch_type value must be a valid type: FARGATE or EC2."
  }
}

variable "web_proxy_enabled" {
  type        = bool
  description = "Nginx proxy enabled"
  default     = false
}

variable "web_proxy_docker_image_tag" {
  type        = string
  description = "Nginx proxy docker image tag"
  default     = "1.19.2-alpine"
}
variable "proxy_docker_image_name" {
  description = "Nginx proxy docker image name"
  default     = "nginx"
}

variable "web_proxy_docker_container_port" {
  type        = number
  description = "Proxy docker container port"
  default     = 80
}

variable "proxy_docker_container_command" {
  description = "Proxy docker container CMD"
  type        = list(string)
  default     = ["nginx", "-g", "daemon off;"]
}

variable "proxy_docker_entrypoint" {
  description = "Proxy docker container entrypoint"
  default     = ["/docker-entrypoint.sh"]
}

variable "autoscale_scheduled_up" {
  description = "List of Cron-like expressions for scheduled ecs autoscale UP"
  default     = []
}

variable "autoscale_scheduled_down" {
  description = "List of Cron-like expressions for scheduled ecs autoscale DOWN"
  default     = []
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name"
  default     = ""
}

variable "autoscaling_health_check_type" {
  type        = string
  description = "ECS 'EC2' or 'ELB' health check type"
  default     = "EC2"
}

variable "alb_health_check_path" {
  type        = string
  description = "ALB health check path"
  default     = "/health"
}

variable "min_size" {
  type        = number
  description = "Minimum number of running ECS tasks"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of running ECS tasks"
  default     = 1
}

variable "desired_capacity" {
  type        = number
  description = "Desired number (capacity) of running ECS tasks"
  default     = 1
}

variable "autoscale_enabled" {
  type        = bool
  description = "ECS Autoscaling enabled"
  default     = false
}

variable "autoscale_target_value_cpu" {
  type        = number
  description = "ECS Service Average CPU Utilization threshold. Integer value for percentage - IE 80"
  default     = 50
}

variable "autoscale_target_value_memory" {
  type        = number
  description = "ECS Service Average Memory Utilization threshold. Integer value for percentage. IE 60"
  default     = 50
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks"
  default     = 100
  type        = number
}


variable "datadog_enabled" {
  type        = bool
  description = "Datadog agent is enabled"
  default     = false
}

variable "route53_health_check_enabled" {
  type        = bool
  description = "AWS Route53 health check is enabled"
  default     = false
}

variable "sns_service_subscription_endpoint" {
  type        = string
  description = "You can use different endpoints, such as email, Pagerduty, Slack, etc."
  default     = "exmple@example.com"
}

variable "sns_service_subscription_endpoint_protocol" {
  type        = string
  description = "See valid protocols here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol-support"
  default     = "email"
}

# The var.cpu & var.memory vars are valid only for FARGATE. EC2 instance type is used to set ECS EC2 specs 
variable "cpu" {
  type        = number
  default     = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"

  validation {
    condition     = can(regex("256|512|1024|2048|4096", var.cpu))
    error_message = "The cpu value must be a valid CPU value, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html."
  }
}

variable "memory" {
  type        = number
  default     = 512
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"

  validation {
    condition     = can(regex("512|1024|2048|3072|4096|5120|6144|7168|8192|9216|10240|11264|12288|13312|14336|15360|16384|17408|18432|19456|20480|21504|22528|23552|24576|25600|26624|27648|28672|29696|30720", var.memory))
    error_message = "The memory value must be a valid Memory value, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html."
  }
}

variable "gpu" {
  type        = number
  description = "GPU-enabled container instances"
  default     = 0
}

variable "aws_service_discovery_private_dns_namespace" {
  type        = string
  description = "Amazon ECS Service Discovery private DNS namespace"
  default     = ""
}

variable "ecs_service_discovery_enabled" {
  type        = bool
  description = "ECS service can optionally be configured to use Amazon ECS Service Discovery"
  default     = false
}

variable "ecs_network_mode" {
  type        = string
  description = "Corresponds to networkMode in an ECS task definition. Supported values are none, bridge, host, or awsvpc"
  default     = "awsvpc"

  validation {
    condition     = can(regex("awsvpc|host|bridge|none", var.ecs_network_mode))
    error_message = "The ecs network mode value must be a valid ecs_network_mode value, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html."
  }
}

variable "tls_cert_arn" {
  type        = string
  description = "TLS certificate ARN"
  default     = null
}

variable "ecr_repo_create" {
  type        = bool
  description = "Creation of a ECR repo"
  default     = false
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
  default     = ""
}

variable "resource_requirements" {
  type        = list(any)
  description = "The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU"
  default     = []
}

variable "root_block_device_size" {
  type    = number
  default = "50"
}

variable "root_block_device_type" {
  type    = string
  default = "gp2"
}

variable "alb_health_check_valid_response_codes" {
  type    = string
  default = "200-399"
}

variable "alb_deregistration_delay" {
  type    = number
  default = 5
}

variable "alb_health_check_interval" {
  type    = number
  default = 30
}

variable "alb_health_check_healthy_threshold" {
  type    = number
  default = 3
}

variable "alb_health_check_unhealthy_threshold" {
  type    = number
  default = 3
}

variable "alb_health_check_timeout" {
  type    = number
  default = 6
}

variable "volumes" {
  type        = list(any)
  description = "Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts)"
  default     = []
}

variable "efs_enabled" {
  type        = bool
  description = "EFS Enabled"
  default     = false
}

variable "efs_mount_point" {
  type        = string
  description = "EFS mount point"
  default     = "/mnt/efs"
}

variable "efs_root_directory" {
  type        = string
  description = "EFS root directory"
  default     = "/"
}

variable "ecs_service_deployed" {
  type        = bool
  description = "This service resource doesn't have task definition lifecycle policy, so terraform is used to deploy it (instead of ecs cli)"
  default     = false
}

variable "ecs_volumes_from" {
  type        = list(any)
  description = "The VolumeFrom property specifies details on a data volume from another container in the same task definition"
  default     = []
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "cloudwatch_schedule_expressions" {
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions (UTC time zone)"
  type        = list(any)
  default     = []
}

variable "firelens_ecs_log_enabled" {
  type        = bool
  description = "AWSFirelens ECS logs enabled"
  default     = false
}

variable "ecs_exec_enabled" {
  type        = bool
  description = "Turns on the Amazon ECS Exec for the task"
  default     = true
}
