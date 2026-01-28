variable "env" {
  type        = string
  description = "Target environment name of the infrastructure"
}

variable "name" {
  type        = string
  description = "ECS app name including namespace (if applies)"
}

variable "memory_reservation" {
  type        = number
  description = "The soft limit (in MiB) of memory to reserve for the container"
  default     = 256
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

variable "ecs_exec_enabled" {
  type        = bool
  description = "Turns on the Amazon ECS Exec for the task"
  default     = true
}


variable "environment" {
  type        = map(string)
  description = "Set of environment variables"
}

variable "app_secrets" {
  type        = list(string)
  description = "List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/*"
  default     = []
}

variable "ssm_secret_path" {
  type        = string
  description = "AWS SSM root path to environment secrets of an app like /dev/app1"
  default     = null
}

variable "global_secrets" {
  type        = list(string)
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
  type        = number
  description = "Docker container port"
  default     = 3000
}

variable "port_mappings" {
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string)
  }))
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
  type = list(object({
    containerName = string
    condition     = string
  }))
  description = "Docker container dependencies. Condition can be: START, COMPLETE, SUCCESS, HEALTHY"
  default     = []

  # Example: [{
  #   containerName = "datadog-agent",
  #   condition     = "START"
  # }]
}

variable "docker_container_links" {
  type        = list(string)
  description = "ECS container definitions links"
  default     = []
}

variable "sidecar_container_definitions" {
  type = list(object({
    name              = string
    image             = string
    cpu               = optional(number)
    memory            = optional(number)
    memoryReservation = optional(number)
    essential         = optional(bool)

    # Environment and secrets
    environment = optional(list(object({
      name  = string
      value = string
    })))
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })))

    # Networking
    portMappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string)
    })))
    links = optional(list(string))

    # Commands
    command          = optional(list(string))
    entryPoint       = optional(list(string))
    workingDirectory = optional(string)

    # Health check
    healthCheck = optional(object({
      command     = list(string)
      interval    = optional(number)
      timeout     = optional(number)
      retries     = optional(number)
      startPeriod = optional(number)
    }))

    # Logging
    logConfiguration = optional(object({
      logDriver = string
      options   = optional(map(string))
      secretOptions = optional(list(object({
        name      = string
        valueFrom = string
      })))
    }))

    # Storage
    mountPoints = optional(list(object({
      sourceVolume  = string
      containerPath = string
      readOnly      = optional(bool)
    })))
    volumesFrom = optional(list(object({
      sourceContainer = string
      readOnly        = optional(bool)
    })))

    # Dependencies
    dependsOn = optional(list(object({
      containerName = string
      condition     = string
    })))

    # Linux parameters
    linuxParameters = optional(object({
      capabilities = optional(object({
        add  = optional(list(string))
        drop = optional(list(string))
      }))
      devices = optional(list(object({
        hostPath      = string
        containerPath = optional(string)
        permissions   = optional(list(string))
      })))
      initProcessEnabled = optional(bool)
      sharedMemorySize   = optional(number)
      tmpfs = optional(list(object({
        containerPath = string
        size          = number
        mountOptions  = optional(list(string))
      })))
      maxSwap    = optional(number)
      swappiness = optional(number)
    }))

    # Docker labels and security
    dockerLabels           = optional(map(string))
    dockerSecurityOptions  = optional(list(string))
    user                   = optional(string)
    privileged             = optional(bool)
    readonlyRootFilesystem = optional(bool)

    # FireLens
    firelensConfiguration = optional(object({
      type    = string
      options = optional(map(string))
    }))

    # Resource requirements (GPU)
    resourceRequirements = optional(list(object({
      type  = string
      value = string
    })))

    # Other settings
    hostname       = optional(string)
    interactive    = optional(bool)
    pseudoTerminal = optional(bool)
    systemControls = optional(list(object({
      namespace = string
      value     = string
    })))
    ulimits = optional(list(object({
      name      = string
      softLimit = number
      hardLimit = number
    })))
    dnsServers       = optional(list(string))
    dnsSearchDomains = optional(list(string))
    extraHosts = optional(list(object({
      hostname  = string
      ipAddress = string
    })))
    disableNetworking = optional(bool)
    startTimeout      = optional(number)
    stopTimeout       = optional(number)
  }))

  description = "ECS Sidecar container definitions, e.g. Datadog agent. Full container definition objects following AWS ECS ContainerDefinition schema."
  default     = []
}

variable "additional_container_definition_parameters" {
  type = object({
    # Working directory and user settings
    workingDirectory = optional(string)
    user             = optional(string)
    hostname         = optional(string)

    # Networking settings
    disableNetworking = optional(bool)
    dnsServers        = optional(list(string))
    dnsSearchDomains  = optional(list(string))
    extraHosts = optional(list(object({
      hostname  = string
      ipAddress = string
    })))

    # Security settings
    privileged             = optional(bool)
    readonlyRootFilesystem = optional(bool)
    dockerSecurityOptions  = optional(list(string))
    credentialSpecs        = optional(list(string))

    # Resource limits
    ulimits = optional(list(object({
      name      = string
      softLimit = number
      hardLimit = number
    })))

    # System controls
    systemControls = optional(list(object({
      namespace = string
      value     = string
    })))

    # TTY and interactive settings
    interactive    = optional(bool)
    pseudoTerminal = optional(bool)

    # Timeout settings
    startTimeout = optional(number)
    stopTimeout  = optional(number)

    # FireLens configuration
    firelensConfiguration = optional(object({
      type    = string
      options = optional(map(string))
    }))
  })

  description = "Additional parameters passed straight to the container definition, eg. tmpfs config. Only safe parameters that don't conflict with main configuration are allowed."
  default     = {}

  validation {
    condition = alltrue([
      for key in keys(var.additional_container_definition_parameters) :
      contains([
        "workingDirectory", "user", "hostname", "disableNetworking",
        "dnsServers", "dnsSearchDomains", "extraHosts", "privileged",
        "readonlyRootFilesystem", "dockerSecurityOptions", "credentialSpecs",
        "ulimits", "systemControls", "interactive", "pseudoTerminal",
        "startTimeout", "stopTimeout", "firelensConfiguration"
      ], key)
    ])
    error_message = "Only specific safe container definition parameters are allowed. Forbidden parameters that would conflict with main configuration: name, image, command, entryPoint, cpu, memory, memoryReservation, essential, environment, secrets, portMappings, mountPoints, volumesFrom, links, linuxParameters, healthCheck, logConfiguration, dependsOn, dockerLabels, resourceRequirements."
  }
}


variable "task_group" {
  type        = string
  description = "ECS Task group name, e.g. app, service name etc."
  default     = "app"
}

variable "iam_role_policy_statement" {
  type = list(object({
    Effect    = string
    Action    = any # Can be string or list(string)
    Resource  = any # Can be string or list(string)
    Sid       = optional(string)
    Principal = optional(any)
    Condition = optional(any)
  }))
  description = "ECS Task IAM Role policy statement. Standard AWS IAM policy statement structure."
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
  type = object({
    subnets          = optional(list(string))
    security_groups  = optional(list(string))
    assign_public_ip = optional(bool)
  })
  description = "ECS Network Configuration for awsvpc network mode"
  default     = {}
}

variable "ecs_task_family_name" {
  type        = string
  description = "ECS Task Family Name"
  default     = ""
}

variable "ecs_volumes_from" {
  type = list(object({
    sourceContainer = string
    readOnly        = optional(bool)
  }))
  description = "The VolumeFrom property specifies details on a data volume from another container in the same task definition"
  default     = []
}

variable "ecs_task_health_check_command" {
  type        = string
  description = "Command to check for the health of the container"
}

variable "resource_requirements" {
  type = list(object({
    type  = string
    value = string
  }))
  description = "The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU"
  default     = []
}

variable "volumes" {
  type = list(object({
    name      = string
    host_path = optional(string)

    # Mount point for container (used in container definition)
    mount_point = optional(object({
      sourceVolume  = string
      containerPath = string
      readOnly      = optional(bool)
    }))

    # EFS volume configuration
    efs_volume_configuration = optional(list(object({
      file_system_id          = string
      root_directory          = optional(string)
      transit_encryption      = optional(string)
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = optional(string)
        iam             = optional(string)
      }))
    })))

    # Docker volume configuration (for EC2 launch type)
    docker_volume_configuration = optional(list(object({
      scope         = optional(string)
      autoprovision = optional(bool)
      driver        = optional(string)
      driver_opts   = optional(map(string))
      labels        = optional(map(string))
    })))
  }))

  description = "Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts)"
  default     = []
}

variable "cloudwatch_schedule_expressions" {
  type        = list(string)
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions (https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)"
  default     = []
}

variable "cloudwatch_retention_in_days" {
  type        = number
  description = "Default AWS Cloudwatch retention in days"
  default     = 90
}

variable "firelens_ecs_log_enabled" {
  type        = bool
  description = "AWSFirelens ECS logs enabled"
  default     = false
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
  description = "Path where tmpfs tmpfs would be mounted"
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

variable "docker_labels" {
  type        = map(string)
  description = "Labels to be added to the docker. Used for auto-configuration, for instance of JMX discovery"
  default     = null
}

variable "operating_system_family" {
  type        = string
  description = "OS family for ECS runtime platform (e.g., LINUX, WINDOWS_SERVER_2019_CORE)"

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
    error_message = "The operating_system_family value must be a valid OS family, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform."
  }
}

variable "cpu_architecture" {
  type        = string
  description = "CPU architecture for the task.Could be X86_64 or ARM64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "The cpu_architecture value must be either X86_64 or ARM64."
  }
}
