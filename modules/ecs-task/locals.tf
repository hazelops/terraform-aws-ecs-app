locals {
  environment                 = merge(var.environment, {})
  docker_container_command    = (var.docker_container_command == [] ? [] : var.docker_container_command)
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)

  ssm_secret_path = var.ssm_secret_path != null ? var.ssm_secret_path : "/${var.env}/${var.name}"
  ssm_global_secret_path = var.ssm_global_secret_path != null ? var.ssm_global_secret_path : "/${var.env}/global"

  # ECS Task Container definition file is filled with content here
  container_definitions = concat(var.sidecar_container_definitions, [
    merge(var.additional_container_definition_parameters, {
      name    = var.name
      command = local.docker_container_command

      image                = "${var.docker_image_name}:${var.docker_image_tag}"
      resourceRequirements = var.resource_requirements

      dockerLabels : var.docker_labels


      cpu               = var.ecs_launch_type == "FARGATE" ? var.cpu : null
      memoryReservation = var.memory_reservation
      essential         = true
      healthCheck       = length(var.ecs_task_health_check_command) > 0 ? {
        retries    = 3
        timeout    = 5
        interval   = 30
        startPerid = null
        command    = [
          "CMD-SHELL",
          var.ecs_task_health_check_command
        ]
      } : null

      linuxParameters = var.operating_system_family == "LINUX" ? {
        sharedMemorySize = (var.shared_memory_size > 0 && var.ecs_launch_type != "FARGATE") ? var.shared_memory_size : null
        tmpfs            = (var.tmpfs_enabled && var.ecs_launch_type != "FARGATE") ? [
          {
            ContainerPath = var.tmpfs_container_path
            MountOptions  = var.tmpfs_mount_options
            Size          = var.tmpfs_size
          }
        ] : null,
        initProcessEnabled = var.ecs_exec_enabled ? true : null
      } : null

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
      ] : []

      logConfiguration = var.firelens_ecs_log_enabled ? {
        "logDriver" = "awsfirelens",
        options = {
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
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "main"
        }
      }

      dependsOn = var.docker_container_depends_on
    })
  ])


  iam_ecs_execution_role_policy = {
    "Version"   = "2012-10-17",
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
