variable "env" {
  type        = string
  description = "Environment name (dev, prod)"
}

variable "name" {
  type        = string
  description = "Application name. Used as the primary identifier for all created resources (e.g., 'api', 'worker', 'web')"
}

variable "app_type" {
  type        = string
  description = "ECS application type. Valid values: web (with ALB), worker (without ALB)."
  default     = "web"

  validation {
    condition     = var.app_type == "web" || var.app_type == "tcp-app" || var.app_type == "worker"
    error_message = "The app_type value must be a valid type: web, worker or tcp-app."
  }
}

variable "ecs_service_name" {
  type        = string
  description = "The ECS service name"
  default     = ""
}

variable "ecs_platform_version" {
  type        = string
  description = "The platform version on which to run your service. Only applicable when using Fargate launch type. Valid values are LATEST, or a specific version like 1.4.0"
  default     = "LATEST"

  validation {
    condition     = var.ecs_platform_version == "LATEST" || can(regex("^\\d+\\.\\d+\\.\\d+$", var.ecs_platform_version))
    error_message = "The ecs_platform_version must be 'LATEST' or a semantic version like '1.4.0'."
  }
}


variable "ec2_service_group" {
  type        = string
  description = "Service group name, e.g. app, service name etc."
  default     = "app"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for ECS"
  default     = "t4g.nano"
}

variable "environment" {
  type        = map(string)
  description = "Map of environment variables to be stored in SSM Parameter Store and exposed to the ECS task. Example: { API_KEY = 'value', DATABASE_URL = 'value' }"
}

variable "public" {
  type        = bool
  description = "It's publicly accessible application"
  default     = true
}

variable "app_secrets" {
  type        = list(any)
  description = "List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/*"
  default     = []
}

variable "public_ecs_service" {
  type        = bool
  description = "It's publicly accessible service"
  default     = false
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
  type        = list(string)
  description = "VPC Public subnets to place ECS resources"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "VPC Private subnets to place ECS resources"
  default     = []
}

variable "security_groups" {
  type        = list(string)
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
  description = "Root domain name for Route53 DNS records (e.g., 'example.com'). Leave empty if not using custom domain"
  default     = ""
}

variable "domain_names" {
  type        = list(string)
  description = "Domain names for AWS Route53 A records"
  default     = []
}

variable "zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID for creating DNS records. Required if using custom domain"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where ECS resources will be created. Required"
}

variable "assign_public_ip" {
  type        = bool
  description = "ECS service network configuration - assign public IP"
  default     = false
}

variable "alb_security_groups" {
  type        = list(string)
  description = "Security groups to assign to ALB"
  default     = []
}

variable "docker_registry" {
  type        = string
  description = "ECR or any other docker registry"
  default     = "docker.io"
}

# It should include registry, e.g. hashicorp/terraform
variable "docker_image_name" {
  type        = string
  description = "Docker image name without registry and tag (e.g., 'nginx', 'myapp/api'). Can include repository path"
  default     = ""
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "docker_container_port" {
  type        = number
  description = "Port exposed by the Docker container. Default is 3000"
  default     = 3000
}

variable "docker_host_port" {
  type        = number
  description = "Docker host port. 0 means Auto-assign."
  default     = 0
}

variable "port_mappings" {
  description = "List of additional port mappings for the container. Used for tcp-app type applications"
  type = list(object({
    container_port   = optional(number)
    host_port        = optional(number)
    protocol         = optional(string, "tcp")
    container_name   = optional(string)
    target_group_arn = optional(string)
  }))
  default = []
}

variable "docker_container_entrypoint" {
  type        = list(string)
  description = "Docker container entrypoint"
  default     = []
}

variable "docker_container_command" {
  type        = list(string)
  description = "Docker container command"
  default     = []
}

variable "sidecar_container_definitions" {
  type        = any
  description = "Sidecar container definitions for ECS task"
  default     = []
}

variable "alb_idle_timeout" {
  type        = number
  description = "The time in seconds that the connection is allowed to be idle."
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
  default     = "1.28.0-alpine"
}
variable "proxy_docker_image_name" {
  type        = string
  description = "Nginx proxy docker image name"
  default     = "nginx"
}

variable "web_proxy_docker_container_port" {
  type        = number
  description = "Proxy docker container port"
  default     = 80
}

variable "proxy_docker_container_command" {
  type        = list(string)
  description = "Proxy docker container CMD"
  default     = ["nginx", "-g", "daemon off;"]
}

variable "proxy_docker_entrypoint" {
  type        = list(string)
  description = "Proxy docker container entrypoint"
  default     = ["/docker-entrypoint.sh"]
}

variable "autoscale_scheduled_up" {
  type        = list(string)
  description = "List of Cron-like expressions for scheduled ecs autoscale UP"
  default     = []
}

variable "autoscale_scheduled_down" {
  type        = list(string)
  description = "List of Cron-like expressions for scheduled ecs autoscale DOWN"
  default     = []
}

variable "autoscale_scheduled_timezone" {
  type        = string
  description = "Time Zone for the scheduled event"
  default     = "UTC"
}

variable "ec2_eip_enabled" {
  type        = bool
  description = "Enable EC2 ASG Auto Assign EIP mode"
  default     = false
}

variable "ec2_eip_count" {
  type        = number
  description = "Count of EIPs to create"
  default     = 0
}

variable "ec2_eip_dns_enabled" {
  type        = bool
  description = "Whether to manage DNS records to be attached to the EIP"
  default     = false
}


variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster where the service will be deployed. Required"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ECS cluster arn. Should be specified to avoid data query by cluster name"
  default     = ""
}

variable "autoscaling_health_check_type" {
  type        = string
  description = "ECS 'EC2' or 'ELB' health check type"
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.autoscaling_health_check_type)
    error_message = "The autoscaling_health_check_type must be either 'EC2' or 'ELB'."
  }
}

variable "ecs_task_health_check_command" {
  type        = string
  description = "Command to check for the health of the container"
  default     = ""
}

variable "alb_health_check_path" {
  type        = string
  description = "Path for ALB health check endpoint (e.g., '/health', '/api/health')"
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
  description = "Desired number of running ECS tasks. Must be between min_size and max_size"
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
  type        = number
  description = "Lower limit on the number of running tasks"
  default     = 100
}


variable "datadog_enabled" {
  type        = bool
  description = "Datadog agent is enabled"
  default     = false
}

variable "datadog_jmx_enabled" {
  type        = bool
  description = "Enables / Disables jmx monitor via the datadog agent"
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
  default     = "example@example.com"
}

variable "sns_service_subscription_endpoint_protocol" {
  type        = string
  description = "SNS subscription protocol. See valid protocols here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol-support"
  default     = "email"

  validation {
    condition     = contains(["email", "email-json", "http", "https", "sms", "sqs", "lambda", "firehose", "application"], var.sns_service_subscription_endpoint_protocol)
    error_message = "The sns_service_subscription_endpoint_protocol must be a valid SNS protocol: email, email-json, http, https, sms, sqs, lambda, firehose, or application."
  }
}

# The var.cpu & var.memory vars are valid only for FARGATE. EC2 instance type is used to set ECS EC2 specs
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
variable "cpu" {
  type        = number
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096, 8192, 16384], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096, 8192, 16384. Please check: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  }
}

variable "memory" {
  type        = number
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 512

  validation {
    condition = contains([
      512, 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192, 9216, 10240,
      11264, 12288, 13312, 14336, 15360, 16384, 17408, 18432, 19456, 20480,
      21504, 22528, 23552, 24576, 25600, 26624, 27648, 28672, 29696, 30720,
      32768, 36864, 40960, 45056, 49152, 53248, 57344, 61440,
      65536, 73728, 81920, 90112, 98304, 106496, 114688, 122880
    ], var.memory)
    error_message = "Memory must be a valid Fargate memory value. Please check: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  }
}

variable "memory_reservation" {
  type        = number
  description = "The soft limit (in MiB) of memory to reserve for the container"
  default     = 256
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
    error_message = "The ecs network mode value must be a valid ecs_network_mode value, please see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html."
  }
}

variable "tls_cert_arn" {
  type        = string
  description = "TLS certificate ARN"
  default     = null
}

variable "https_enabled" {
  type        = bool
  description = "Whether enable https or not (still needs tls_cert_arn)"
  default     = true
}

variable "ecr_repo_create" {
  type        = bool
  description = "Whether to create an ECR repository for this application. Set to true if you need a new registry"
  default     = false
}

variable "create_iam_instance_profile" {
  type        = bool
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  default     = true
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
  default     = ""
}

variable "resource_requirements" {
  description = "Container resource requirements (GPU only). Specify GPU count for GPU-enabled tasks. Example: [{ type = 'GPU', value = '1' }]"
  type = list(object({
    type  = optional(string)
    value = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for req in var.resource_requirements : req.type == "GPU"
    ])
    error_message = "Only GPU resource requirements are supported. Type must be 'GPU'."
  }
}

variable "root_block_device_size" {
  type        = number
  description = "EBS root block device size in GB"
  default     = "50"
}

variable "http_port" {
  type        = number
  description = "Port that is used for HTTP protocol"
  default     = 80
}

variable "root_block_device_type" {
  type        = string
  description = "EBS root block device type"
  default     = "gp2"

  validation {
    condition     = can(regex("io1|io2|gp2|gp3", var.root_block_device_type))
    error_message = "The root_block_device_type value must be a valid type: io1, io2, gp2, gp3 (https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html)."
  }
}

variable "alb_health_check_valid_response_codes" {
  type        = string
  description = "The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
  default     = "200-399"
}

variable "alb_deregistration_delay" {
  type        = number
  description = "The amount of time, in seconds, for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  default     = 5
}

variable "alb_health_check_interval" {
  type        = number
  description = "The approximate amount of time, in seconds, between health checks of an individual target"
  default     = 30
}

variable "alb_health_check_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = 3
}

variable "alb_health_check_unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health check failures required before considering the target unhealthy"
  default     = 3
}

variable "alb_health_check_timeout" {
  type        = number
  description = "The amount of time, in seconds, during which no response means a failed health check"
  default     = 6
}

variable "volumes" {
  type        = list(any)
  description = "Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts)"
  default     = []
}

variable "efs_enabled" {
  type        = bool
  description = "Whether to enable EFS mount for ECS task"
  default     = false
}

variable "efs_share_create" {
  type        = bool
  description = "Whether to create EFS share or not"
  default     = false
}

variable "efs_file_system_id" {
  type        = string
  description = "EFS file system ID"
  default     = ""
}

variable "efs_mount_point" {
  type        = string
  description = "Container path where EFS volume will be mounted (e.g., '/mnt/efs', '/data')"
  default     = "/mnt/efs"
}

variable "efs_root_directory" {
  type        = string
  description = "EFS root directory"
  default     = "/"
}

variable "efs_authorization_config" {
  description = "EFS authorization configuration. IAM can be ENABLED or DISABLED"
  type = object({
    access_point_id = optional(string)
    iam             = optional(string, "ENABLED")
  })
  default = {}

  validation {
    condition = (
      try(var.efs_authorization_config.iam, null) == null ||
      contains(["ENABLED", "DISABLED"], var.efs_authorization_config.iam)
    )
    error_message = "efs_authorization_config.iam must be either 'ENABLED' or 'DISABLED'."
  }
}

variable "efs_access_points" {
  type        = any
  description = "EFS access points - map of access point definitions. See terraform-aws-modules/efs/aws documentation for format."
  default     = {}
}

variable "ecs_service_deployed" {
  type        = bool
  description = "This service resource doesn't have task definition lifecycle policy, so terraform is used to deploy it (instead of ecs cli or ize)"
  default     = false
}

variable "ecs_volumes_from" {
  type        = list(any)
  description = "The VolumeFrom property specifies details on a data volume from another container in the same task definition"
  default     = []
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "cloudwatch_schedule_expressions" {
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions (UTC time zone). Example: ['cron(0 10 * * ? *)', 'rate(5 minutes)']"
  type        = list(string)
  default     = []
}

variable "firelens_ecs_log_enabled" {
  type        = bool
  description = "AWS Firelens ECS logs enabled (used by FluentBit, Datadog, etc)"
  default     = false
}

variable "ecs_exec_enabled" {
  type        = bool
  description = "Enable Amazon ECS Exec for debugging. Allows you to execute commands in running containers using 'aws ecs execute-command'"
  default     = true
}

variable "ecs_exec_custom_prompt_enabled" {
  type        = bool
  description = "Enable Custom shell prompt on ECS Exec"
  default     = false
}

variable "ecs_exec_prompt_string" {
  type        = string
  description = "Shell prompt that contains ENV and APP_NAME is enabled"
  default     = "\\e[1;35m★\\e[0m $ENV-$APP_NAME:$(wget -qO- $ECS_CONTAINER_METADATA_URI_V4 | sed -n 's/.*\"com.amazonaws.ecs.task-definition-version\":\"\\([^\"]*\\).*/\\1/p') \\e[1;36m★\\e[0m $(wget -qO- $ECS_CONTAINER_METADATA_URI_V4 | sed -n 's/.*\"Image\":\"\\([^\"]*\\).*/\\1/p' | awk -F\\: '{print $2}' )\\n\\e[1;33m\\e[0m \\w \\e[1;34m❯\\e[0m "
}


variable "additional_container_definition_parameters" {
  type        = any
  description = "Additional parameters passed straight to the container definition, eg. tmpfs config"
  default     = {}
}


variable "tmpfs_enabled" {
  type        = bool
  description = "TMPFS support for non-Fargate deployments"
  default     = false
}

variable "tmpfs_size" {
  type        = number
  description = "Size of the tmpfs in MB"
  default     = 1024
}

variable "tmpfs_container_path" {
  type        = string
  description = "Path where tmpfs shm would be mounted"
  default     = "/tmp/"
}

variable "tmpfs_mount_options" {
  type        = list(string)
  description = "Options for the mount of the ram disk. noatime by default to speed up access"
  default     = ["noatime"]
}

variable "shared_memory_size" {
  type        = number
  description = "Size of the /dev/shm shared memory in MB"
  default     = 0
}

variable "create_schedule" {
  type        = bool
  description = "Determines whether to create autoscaling group schedule or not"
  default     = false
}

variable "schedules" {
  description = "Map of autoscaling group schedules for EC2 Auto Scaling"
  type = map(object({
    desired_capacity = optional(number)
    end_time         = optional(string)
    max_size         = optional(number)
    min_size         = optional(number)
    recurrence       = optional(string)
    start_time       = optional(string)
    time_zone        = optional(string, "UTC")
  }))
  default = {}
}

variable "docker_labels" {
  type        = map(any)
  description = "Labels to be added to the docker. Used for auto-configuration, for instance of JMX discovery"
  default     = null
}

variable "operating_system_family" {
  type        = string
  description = "Platform to be used with ECS. The valid values for Amazon ECS tasks hosted on Fargate are LINUX, WINDOWS_SERVER_2019_FULL, and WINDOWS_SERVER_2019_CORE. The valid values for Amazon ECS tasks hosted on EC2 are LINUX, WINDOWS_SERVER_2022_CORE, WINDOWS_SERVER_2022_FULL, WINDOWS_SERVER_2019_FULL, and WINDOWS_SERVER_2019_CORE, WINDOWS_SERVER_2016_FULL, WINDOWS_SERVER_2004_CORE, and WINDOWS_SERVER_20H2_CORE."
  default     = "LINUX"

  validation {
    condition = contains([
      "LINUX",
      "WINDOWS_SERVER_2019_FULL",
      "WINDOWS_SERVER_2019_CORE",
      "WINDOWS_SERVER_2022_CORE",
      "WINDOWS_SERVER_2022_FULL",
      "WINDOWS_SERVER_2016_FULL",
      "WINDOWS_SERVER_2004_CORE",
      "WINDOWS_SERVER_20H2_CORE"
    ], var.operating_system_family)
    error_message = "The operating_system_family must be a valid OS family. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform"
  }
}

variable "cpu_architecture" {
  type        = string
  description = "When you register a task definition, you specify the CPU architecture. The valid values are X86_64 and ARM64"
  default     = "ARM64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "The cpu_architecture must be either 'X86_64' or 'ARM64'."
  }
}

variable "ecr_force_delete" {
  type        = bool
  description = "If true, the ECR repository will be deleted even if it contains images on destroy"
  default     = false
}

variable "alb_access_logs_enabled" {
  type        = bool
  description = "If true, ALB access logs will be written to S3"
  default     = false
}

variable "alb_access_logs_s3bucket_name" {
  type        = string
  description = "S3 bucket name for ALB access logs"
  default     = ""
}

variable "alb_access_logs_s3prefix" {
  type        = string
  description = "S3 prefix for ALB access logs"
  default     = ""
}

variable "alb_deletion_protection_enabled" {
  type        = bool
  description = "If true, deletion protection of the load balancer will be enabled."
  default     = true
}
