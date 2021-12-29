locals {
  environment                 = merge(var.environment, {})
  docker_container_command    = (var.docker_container_command == [] ? [] : var.docker_container_command)
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)

  ssm_secret_path             = var.ssm_secret_path != null ? var.ssm_secret_path : "/${var.env}/${var.name}"
  ssm_global_secret_path      = var.ssm_global_secret_path != null ? var.ssm_global_secret_path : "/${var.env}/global"

  # ECS Task Container definition file is filled with content here
  container_definitions = concat(var.sidecar_container_definitions, [
    {
      name    = var.name
      command = local.docker_container_command

      image                = "${var.docker_image_name}:${var.docker_image_tag}"
      resourceRequirements = var.resource_requirements


      cpu               = var.cpu
      memoryReservation = var.memory_reservation
      essential         = true

      linuxParameters   = var.ecs_exec_enabled ? { initProcessEnabled = true } : {}

      mountPoints = [
        # This way we ensure that we only mount main app volumes to the main app container.
        for volume in var.volumes : lookup(volume, "mount_point", null) if(lookup(volume, "mount_point", false))
      ]

      environment = [for k, v in local.environment : { name = k, value = v }]

      secrets     = concat([for param_name in var.service_secrets :
        {
          name      = param_name
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_secret_path}/${param_name}"
        }
      ],[for param_name in var.global_secrets :
        {
          name      = replace(param_name, "/", "") != param_name ? element(split("/", param_name),1) : param_name
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_global_secret_path}/${param_name}"
        }
      ])

      portMappings = [for p in var.port_mappings :
        {
          containerPort = p.container_port
          hostPort      = p.host_port
        }
      ]

      links = var.docker_container_links

      PlacementConstraints = var.ecs_launch_type == "EC2" ? [
        {
          type       = "memberOf"
          expression = "attribute:service-group == ${var.task_group}"
        }
      ] : []

      logConfiguration = var.firelens_ecs_log_enabled ? {
        "logDriver" = "awsfirelens",
        options = {
          "Name"            = "datadog"
          "Host"            = "http-intake.logs.datadoghq.com"
          "apiKey"          = data.aws_ssm_parameter.dd_api_key[0].value
          "dd_service"      = "${var.name}"
          "dd_source"       = "ecs"
          "dd_tags"         = "fluentbit:true,env:${var.env},service:${var.env}-${var.name}"
          "dd_message_key"  = "log"
          "region"          = data.aws_region.current.name
          "TLS"             = "on"
          "provider"        = "ecs"
        }
      } : {
        "logDriver" = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "main"
        }
      }

      dependsOn = var.docker_container_depends_on
    }
  ])


  iam_ecs_execution_role_policy = {
    "Version" = "2012-10-17",
    "Statement" = concat(var.iam_role_policy_statement, [
      {
        "Effect" = "Allow",
        "Action" = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" = "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "firehose:PutRecordBatch"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect" = "Allow",
        "Action" = [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel"
        ],
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "ssm:GetParameter*"
        ],
        "Resource" = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_secret_path}/*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_global_secret_path}/*"
        ]
      }
    ])
  }
}


variable "env" {
  type        = string
  description = "Target environment name of the infrastructure"
}

variable "name" {
  type        = string
  description = "The service name"
}

variable "memory_reservation" {
  type        = number
  description = "The soft limit (in MiB) of memory to reserve for the container"
  default     = 256
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

variable "ecs_exec_enabled" {
  type        = bool
  description = "Turns on the Amazon ECS Exec for the task"
  default     = true
}


variable "environment" {
  type        = map(string)
  description = "Set of environment variables"
}

variable "service_secrets" {
  type        = list
  description = "List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/*"
  default     = []
}

variable "ssm_secret_path" {
  type        = string
  description = "AWS SSM root path to environment secrets of an app like /dev/app1"
  default     = null
}

variable "global_secrets" {
  type        = list
  description = "List of SSM ParameterStore global secrets - by default, /$var.env/global/*"
  default     = []
}

variable "ssm_global_secret_path" {
  type        = string
  description = "AWS SSM root path to global environment secrets like /dev/global"
  default     = null
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

variable "port_mappings" {
  type        = list
  description = "Docker container port mapping to a host port. We don't forward ports from the container if we are using proxy (proxy reaches out to container via internal network)"
  default     = []
}

variable "docker_container_command" {
  type        = list(string)
  description = "Docker container command"
  default     = []
}

variable "docker_container_entrypoint" {
  type        = list(string)
  description = "Docker container entrypoint"
  default     = []
}

variable "docker_container_depends_on" {
  type        = list(any)
  description = "Docker container dependencies"
  default     = []
  #Example: [{
  #      containerName = "datadog-agent",
  #      condition     = "START"
  #  }]
}

variable "docker_container_links" {
  type        = list(any)
  description = "ECS container definitions links"
  default     = []
}

variable "sidecar_container_definitions" {
  type        = list(any)
  description = "ECS Sidecar container definitions, e.g. Datadog agent"
  default     = []
}


variable "task_group" {
  description = "ECS Task group name, e.g. app, service name etc."
  type        = string
  default     = "app"
}

variable "iam_role_policy_statement" {
  type        = list(any)
  description = "ECS Task IAM Role policy statement"
  default     = []
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

variable "ecs_network_mode" {
  type        = string
  description = "Corresponds to networkMode in an ECS task definition. Supported values are none, bridge, host, or awsvpc"
  default     = "awsvpc"

  validation {
    condition     = can(regex("awsvpc|host|bridge|none", var.ecs_network_mode))
    error_message = "The ecs network mode value must be a valid ecs_network_mode value, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html."
  }
}

variable "ecs_network_configuration" {
  description = "ECS Network Configuration"
  default     = {}
  type        = map(any)
}

variable "ecs_task_family_name" {
  type        = string
  description = "ECS Task Family Name"
  default     = ""
}

variable "ecs_volumes_from" {
  type        = list
  description = "The VolumeFrom property specifies details on a data volume from another container in the same task definition"
  default     = []
}

variable "resource_requirements" {
  type        = list
  description = "The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU"
  default     = []
}

variable "volumes" {
  type        = list
  description = "Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts)"
  default     = []
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "cloudwatch_schedule_expressions" {
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions"
  type        = list
  default     = []
}

variable "cloudwatch_retention_in_days" {
  description = "Default AWS Cloudwatch retention in days"
  type        = number
  default     = 90
}

variable "firelens_ecs_log_enabled" {
  type        = bool
  description = "AWSFirelens ECS logs enabled"
  default     = false
}
