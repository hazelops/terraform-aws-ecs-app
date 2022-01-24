locals {
  app_secrets    = concat(var.app_secrets, [])
  global_secrets = concat(var.global_secrets, [])
  environment    = merge(var.environment, {})
}

variable "env" {
  type        = string
  description = "Target environment name of the infrastructure"
}

variable "name" {
  type        = string
  description = "ECS app name"
}

variable "namespace" {
  type        = string
  description = "Namespace name within the infrastructure"
}

variable "memoryReservation" {
  type        = number
  default     = 1024
  description = "The soft limit (in MiB) of memory to reserve for the container"
}
variable "environment" {
  type        = map(string)
  description = "Set of environment variables"
}

variable "ecs_platform_version" {
  description = "The platform version on which to run your service. Only applicable when using Fargate launch type"
  default     = "LATEST"
  type        = string
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

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "ecs_service_name" {
  type        = string
  description = "ECS service name"
  default     = ""
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

variable "ec2_service_group" {
  description = "Service group name, e.g. app, service name etc."
  type        = string
  default     = "app"
}

variable "service_desired_count" {
  description = "The number of instances of a task definition"
  default     = 1
  type        = number
}

variable "ecs_target_task_count" {
  description = "The target task count of 'worker' ecs app type, see $var.app_type of the root module"
  default     = 1
  type        = number
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 100
  type        = number
}

variable "target_group_arn" {
  type        = string
  description = "Application load balancer target group ARN"
  default     = null
}

variable "sidecar_container_definitions" {
  type        = any
  description = "ECS Sidecar container definitions, e.g. Datadog agent"
  default     = []
}

variable "additional_container_definition_parameters" {
  type        = any
  description = "Additional parameters passed straight to the container definition, eg. tmpfs config"
  default     = {}
}


variable "iam_role_policy_statement" {
  type        = list(any)
  description = "ECS Service IAM Role policy statement"
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

# The var.cpu & var.memory vars are valid only for FARGATE. EC2 instance type is used to set ECS EC2 specs
variable "cpu" {
  type        = number
  default     = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"

  validation {
    condition     =  can(regex("256|512|1024|2048|4096", var.cpu))
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

variable "autoscaling_min_size" {
  type        = number
  description = "Minimum number of running ECS tasks during scheduled-up-autoscaling action"
  default     = 2
}

variable "autoscaling_max_size" {
  type        = number
  description = "Maximum number of running ECS tasks during scheduled-up-autoscaling action"
  default     = 2
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

variable "subnets" {
  type        = list(any)
  description = "VPC subnets to place ECS task"
  default     = []
}

variable "security_groups" {
  type        = list(any)
  description = "Security groups to assign to ECS Fargate task/ECS EC2"
  default     = []
}

variable "assign_public_ip" {
  type        = bool
  description = "ECS service network configuration - assign public IP"
  default     = false
}

variable "ecs_service_discovery_enabled" {
  type        = bool
  description = "ECS service can optionally be configured to use Amazon ECS Service Discovery"
  default     = false
}

variable "aws_service_discovery_private_dns_namespace" {
  type        = string
  description = "Amazon ECS Service Discovery private DNS namespace"
  default     = ""
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

variable "resource_requirements" {
  type        = list(any)
  description = "The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU"
  default     = []
}

variable "volumes" {
  type        = list(any)
  description = "Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts)"
  default     = []
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

variable "port_mappings" {
  type        = list(any)
  description = "Docker container port mapping to a host port. We don't forward ports from the container if we are using proxy (proxy reaches out to container via internal network)"
  default     = []
}

variable "web_proxy_enabled" {
  type        = bool
  description = "Nginx proxy enabled"
  default     = false
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "cloudwatch_schedule_expressions" {
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions"
  type        = list(any)
  default     = []
}

variable "autoscale_scheduled_up" {
  type        = list(any)
  description = "List of Cron-like expressions for scheduled ecs autoscale UP"
  default     = []
}

variable "autoscale_scheduled_down" {
  type        = list(any)
  description = "List of Cron-like expressions for scheduled ecs autoscale DOWN"
  default     = []
}

variable "ecs_exec_enabled" {
  type        = bool
  description = "Turns on the Amazon ECS Exec for the task"
  default     = true
}

variable "firelens_ecs_log_enabled" {
  type        = bool
  description = "AWSFirelens ECS logs enabled"
  default     = false
}

variable "tmpfs_enabled" {
  type = bool
  description = "TMPFS support for non-Fargate deployments"
  default = false
}

variable "tmpfs_size" {
  type = number
  description = "Size of the tmpfs in MB"
  default = 1024
}

variable "tmpfs_container_path" {
  type = string
  description = "Path where tmpfs shm would be mounted"
  default = "/tmp/"
}


variable "tmpfs_mount_options" {
  type = list(string)
  description = "Options for the mount of the ram disk. noatime by default to speed up access"
  default = ["noatime"]
}

variable "shared_memory_size" {
  type = number
  description = "Size of the /dev/shm shared memory in MB"
  default = 0
}
