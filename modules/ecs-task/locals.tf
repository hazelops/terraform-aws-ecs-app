locals {
  environment                 = merge(var.environment, {})
  docker_container_command    = (var.docker_container_command == [] ? [] : var.docker_container_command)
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)

  ssm_secret_path        = var.ssm_secret_path != null ? var.ssm_secret_path : "/${var.env}/${var.name}"
  ssm_global_secret_path = var.ssm_global_secret_path != null ? var.ssm_global_secret_path : "/${var.env}/global"

  # ===========================================================================
  # Container definition builds in 3 steps to properly handle null values:
  # 1. Filter nested objects (linuxParameters) to remove internal nulls
  # 2. Build full definition object with all fields (some may be null)
  # 3. Strip out top-level null values - ECS API will provide defaults
  # ===========================================================================

  # ---------------------------------------------------------------------------
  # Step 1: Filter nested objects to remove null values inside them
  # ---------------------------------------------------------------------------

  # Linux parameters - filter out null values, then merge with initProcessEnabled
  trimmed_linux_parameters = var.operating_system_family == "LINUX" ? {
    for k, v in {
      sharedMemorySize   = (var.shared_memory_size > 0 && var.ecs_launch_type != "FARGATE") ? var.shared_memory_size : null
      tmpfs              = (var.tmpfs_enabled && var.ecs_launch_type != "FARGATE") ? [
        {
          ContainerPath = var.tmpfs_container_path
          MountOptions  = var.tmpfs_mount_options
          Size          = var.tmpfs_size
        }
      ] : null
      initProcessEnabled = var.ecs_exec_enabled ? true : null
    } : k => v if v != null
  } : null

  # ---------------------------------------------------------------------------
  # Step 2: Build full container definition object
  # Some values may be null - they will be filtered out in Step 3
  # ---------------------------------------------------------------------------
  main_container_definition = {
    name    = var.name
    command = local.docker_container_command

    image                = "${var.docker_image_name}:${var.docker_image_tag}"
    resourceRequirements = length(var.resource_requirements) > 0 ? var.resource_requirements : null

    dockerLabels = var.docker_labels

    cpu               = var.ecs_launch_type == "FARGATE" ? var.cpu : null
    memoryReservation = var.memory_reservation
    essential         = true

    # healthCheck: startPeriod is omitted - AWS default is "off" (disabled)
    # See: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html
    healthCheck = length(var.ecs_task_health_check_command) > 0 ? {
      retries  = 3
      timeout  = 5
      interval = 30
      command = [
        "CMD-SHELL",
        var.ecs_task_health_check_command
      ]
    } : null

    linuxParameters = local.trimmed_linux_parameters

    mountPoints = [
      # This way we ensure that we only mount main app volumes to the main app container.
      for volume in var.volumes : lookup(volume, "mount_point", {}) if(contains(keys(volume), "mount_point"))
    ]

    environment = [for k, v in local.environment : { name = k, value = v }]

    secrets = concat([
      for param_name in var.app_secrets :
      {
        name      = param_name
        valueFrom = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_secret_path}/${param_name}"
      }
      ], [
      for param_name in var.global_secrets :
      {
        name      = replace(param_name, "/", "") != param_name ? element(split("/", param_name), 1) : param_name
        valueFrom = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_global_secret_path}/${param_name}"
      }
    ])

    portMappings = [
      for p in var.port_mappings :
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
    ] : null

    logConfiguration = var.firelens_ecs_log_enabled ? {
      "logDriver" = "awsfirelens",
      "options" = {
        "Name"           = "datadog"
        "Host"           = "http-intake.logs.datadoghq.com"
        "apiKey"         = data.aws_ssm_parameter.dd_api_key[0].value
        "dd_service"     = var.name
        "dd_source"      = "ecs"
        "dd_tags"        = "fluentbit:true,env:${var.env},service:${var.env}-${var.name}"
        "dd_message_key" = "log"
        "TLS"            = "on"
        "provider"       = "ecs"
      }
      } : {
      "logDriver" = "awslogs",
      "options" = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = data.aws_region.current.region
        "awslogs-stream-prefix" = "main"
      }
    }

    dependsOn = length(var.docker_container_depends_on) > 0 ? var.docker_container_depends_on : null
  }

  # ---------------------------------------------------------------------------
  # Step 3: Strip out all null values from the container definition
  # ECS API will provide defaults in place of null/empty values
  # Then merge with additional user-provided parameters (they can override)
  # ---------------------------------------------------------------------------
  main_container = merge(
    { for k, v in local.main_container_definition : k => v if v != null },
    var.additional_container_definition_parameters
  )

  # ---------------------------------------------------------------------------
  # Step 4: Final container definitions list (sidecars + main container)
  # ---------------------------------------------------------------------------
  container_definitions = concat(var.sidecar_container_definitions, [local.main_container])


  # ===========================================================================
  # IAM Policy for ECS Execution Role
  # ===========================================================================
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
        "Effect" = "Allow",
        "Action" = [
          "firehose:PutRecordBatch"
        ],
        "Resource" = [
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
          "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_secret_path}/*",
          "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_global_secret_path}/*"
        ]
      },
      {
        "Action" = [
          "kms:Decrypt"
        ],
        "Effect"   = "Allow",
        "Resource" = "*"
      }
    ])
  }
}
