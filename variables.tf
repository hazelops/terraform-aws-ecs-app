variable "env" {
  type        = string
  description = "Target environment name of the infrastructure"
}

variable "name" {
  type        = string
  description = "ECS app name including all required namespaces"
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
  description = "The platform version on which to run your service. Only applicable when using Fargate launch type"
  default     = "LATEST"
}


variable "ec2_service_group" {
  type        = string
  description = "Service group name, e.g. app, service name etc."
  default     = "app"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for ECS"
  default     = "t3.small"
}

variable "environment" {
  type        = map(string)
  description = "Map of parameters to be set in SSM and then exposed into a Task Definition as environment variables."
}

variable "public" {
  type        = bool
  description = "It's publicity accessible application"
  default     = true
}

variable "app_secrets" {
  type        = list(any)
  description = "List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/*"
  default     = []
}

variable "public_ecs_service" {
  type        = bool
  description = "It's publicity accessible service"
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
  default     = ""
}

variable "domain_names" {
  type        = list(any)
  description = "Domain names for AWS Route53 A records"
  default     = []
}

variable "zone_id" {
  type        = string
  description = "AWS Route53 Zone ID"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "assign_public_ip" {
  type        = bool
  description = "ECS service network configuration - assign public IP"
  default     = false
}

variable "alb_security_groups" {
  type        = list(any)
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
  description = "Docker image name"
  default     = ""
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "docker_container_port" {
  type        = number
  description = "Docker container port"
  default     = 3000
}

variable "docker_host_port" {
  type        = number
  description = "Docker host port. 0 means Auto-assign."
  default     = 0
}

variable "port_mappings" {
  type        = any
  description = "List of ports to open from a service"
  default     = []
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
  default     = "1.19.2-alpine"
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
  type        = string
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
  description = "ECS cluster name"
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
}

variable "ecs_task_health_check_command" {
  type        = string
  description = "Command to check for the health of the container"
  default     = ""
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
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 256

  validation {
    condition     = can(regex("256|512|1024|2048|4096", var.cpu))
    error_message = "The cpu value must be a valid CPU value, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html."
  }
}

variable "memory" {
  type        = number
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 512

  validation {
    condition     = can(regex("512|1024|2048|3072|4096|5120|6144|7168|8192|9216|10240|11264|12288|13312|14336|15360|16384|17408|18432|19456|20480|21504|22528|23552|24576|25600|26624|27648|28672|29696|30720", var.memory))
    error_message = "The memory value must be a valid Memory value, https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html."
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
    error_message = "The ecs network mode value must be a valid ecs_network_mode value, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html."
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
  description = "Creation of a ECR repo"
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
  type        = list(any)
  description = "The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU"
  default     = []
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
    error_message = "The root_block_device_type value must be a valid type: io1, io2, gp2, gp3 (https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html)"
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
  description = "EFS mount point in the container"
  default     = "/mnt/efs"
}

variable "efs_root_directory" {
  type        = string
  description = "EFS root directory"
  default     = "/"
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
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions (UTC time zone)"
  type        = list(any)
  default     = []
}

variable "firelens_ecs_log_enabled" {
  type        = bool
  description = "AWS Firelens ECS logs enabled (used by FluentBit, Datadog, etc)"
  default     = false
}

variable "ecs_exec_enabled" {
  type        = bool
  description = "Turns on the Amazon ECS Exec for the task"
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
  default = {}
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
  type        = map(any)
  description = "Map of autoscaling group schedule to create"
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
}

variable "cpu_architecture" {
  type        = string
  description = "When you register a task definition, you specify the CPU architecture. The valid values are X86_64 and ARM64"
  default     = "X86_64"
}

variable "ecr_force_delete" {
  type        = bool
  description = "If true, will delete the ECR repository even if it contains images on destroy"
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
