# ECS Service Module

This module creates an ECS Service. 
It's mainly meant to be used by [hazelops/ecs-app](https://registry.terraform.io/modules/hazelops/ecs/aws) Terraform module, but can be used by others too.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_task"></a> [task](#module\_task) | ../ecs-task | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.this_deployed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_iam_role.ecs_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_service_events_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_service_discovery_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecs_events_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_container_definition_parameters"></a> [additional\_container\_definition\_parameters](#input\_additional\_container\_definition\_parameters) | Additional parameters passed straight to the container definition, eg. tmpfs config | `any` | `{}` | no |
| <a name="input_app_secrets"></a> [app\_secrets](#input\_app\_secrets) | List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/* | `list(any)` | `[]` | no |
| <a name="input_app_type"></a> [app\_type](#input\_app\_type) | ECS application type. Valid values: web (with load balancer), worker (scheduled task without ALB). | `string` | `"web"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | ECS service network configuration - assign public IP | `bool` | `false` | no |
| <a name="input_autoscale_enabled"></a> [autoscale\_enabled](#input\_autoscale\_enabled) | ECS Autoscaling enabled | `bool` | `false` | no |
| <a name="input_autoscale_scheduled_down"></a> [autoscale\_scheduled\_down](#input\_autoscale\_scheduled\_down) | List of Cron-like expressions for scheduled ecs autoscale DOWN | `list(any)` | `[]` | no |
| <a name="input_autoscale_scheduled_timezone"></a> [autoscale\_scheduled\_timezone](#input\_autoscale\_scheduled\_timezone) | Time Zone for the scheduled event | `string` | `"UTC"` | no |
| <a name="input_autoscale_scheduled_up"></a> [autoscale\_scheduled\_up](#input\_autoscale\_scheduled\_up) | List of Cron-like expressions for scheduled ecs autoscale UP | `list(any)` | `[]` | no |
| <a name="input_autoscale_target_value_cpu"></a> [autoscale\_target\_value\_cpu](#input\_autoscale\_target\_value\_cpu) | ECS Service Average CPU Utilization threshold. Integer value for percentage - IE 80 | `number` | `50` | no |
| <a name="input_autoscale_target_value_memory"></a> [autoscale\_target\_value\_memory](#input\_autoscale\_target\_value\_memory) | ECS Service Average Memory Utilization threshold. Integer value for percentage. IE 60 | `number` | `50` | no |
| <a name="input_autoscaling_max_size"></a> [autoscaling\_max\_size](#input\_autoscaling\_max\_size) | Maximum number of running ECS tasks during scheduled-up-autoscaling action | `number` | `2` | no |
| <a name="input_autoscaling_min_size"></a> [autoscaling\_min\_size](#input\_autoscaling\_min\_size) | Minimum number of running ECS tasks during scheduled-up-autoscaling action | `number` | `2` | no |
| <a name="input_aws_service_discovery_private_dns_namespace"></a> [aws\_service\_discovery\_private\_dns\_namespace](#input\_aws\_service\_discovery\_private\_dns\_namespace) | Amazon ECS Service Discovery private DNS namespace | `string` | `""` | no |
| <a name="input_cloudwatch_schedule_expressions"></a> [cloudwatch\_schedule\_expressions](#input\_cloudwatch\_schedule\_expressions) | List of Cron-like Cloudwatch Event Rule schedule expressions | `list(any)` | `[]` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `256` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | n/a | `any` | n/a | yes |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit on the number of running tasks. | `number` | `100` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number (capacity) of running ECS tasks | `number` | `1` | no |
| <a name="input_docker_container_command"></a> [docker\_container\_command](#input\_docker\_container\_command) | Docker container command | `list(string)` | `[]` | no |
| <a name="input_docker_container_depends_on"></a> [docker\_container\_depends\_on](#input\_docker\_container\_depends\_on) | Docker container dependencies | `list(any)` | `[]` | no |
| <a name="input_docker_container_entrypoint"></a> [docker\_container\_entrypoint](#input\_docker\_container\_entrypoint) | Docker container entrypoint | `list(string)` | `[]` | no |
| <a name="input_docker_container_links"></a> [docker\_container\_links](#input\_docker\_container\_links) | ECS container definitions links | `list(any)` | `[]` | no |
| <a name="input_docker_container_port"></a> [docker\_container\_port](#input\_docker\_container\_port) | Docker container port | `number` | `3000` | no |
| <a name="input_docker_image_name"></a> [docker\_image\_name](#input\_docker\_image\_name) | Docker image name | `string` | `""` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | Docker image tag | `string` | n/a | yes |
| <a name="input_docker_labels"></a> [docker\_labels](#input\_docker\_labels) | Labels to be added to the docker. Used for auto-configuration, for instance of JMX discovery | `map(any)` | `null` | no |
| <a name="input_ec2_service_group"></a> [ec2\_service\_group](#input\_ec2\_service\_group) | Service group name, e.g. app, service name etc. Mainly used in scheduling tasks on different instances. | `string` | `"app"` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ECS cluster arn. Should be specified to avoid data query by cluster name | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS cluster name | `string` | n/a | yes |
| <a name="input_ecs_exec_enabled"></a> [ecs\_exec\_enabled](#input\_ecs\_exec\_enabled) | Turns on the Amazon ECS Exec for the task | `bool` | `true` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | ECS launch type: FARGATE or EC2 | `string` | `"FARGATE"` | no |
| <a name="input_ecs_network_mode"></a> [ecs\_network\_mode](#input\_ecs\_network\_mode) | Corresponds to networkMode in an ECS task definition. Supported values are none, bridge, host, or awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ecs_platform_version"></a> [ecs\_platform\_version](#input\_ecs\_platform\_version) | The platform version on which to run your service. Only applicable when using Fargate launch type | `string` | `"LATEST"` | no |
| <a name="input_ecs_service_deployed"></a> [ecs\_service\_deployed](#input\_ecs\_service\_deployed) | This service resource doesn't have task definition lifecycle policy, so terraform is used to deploy it (instead of ecs cli) | `bool` | `false` | no |
| <a name="input_ecs_service_discovery_enabled"></a> [ecs\_service\_discovery\_enabled](#input\_ecs\_service\_discovery\_enabled) | ECS service can optionally be configured to use Amazon ECS Service Discovery | `bool` | `false` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | ECS service name | `string` | `""` | no |
| <a name="input_ecs_target_task_count"></a> [ecs\_target\_task\_count](#input\_ecs\_target\_task\_count) | The target task count of 'worker' ecs app type, see $var.app\_type of the root module | `number` | `1` | no |
| <a name="input_ecs_task_health_check_command"></a> [ecs\_task\_health\_check\_command](#input\_ecs\_task\_health\_check\_command) | Command to check for the health of the container | `string` | n/a | yes |
| <a name="input_ecs_volumes_from"></a> [ecs\_volumes\_from](#input\_ecs\_volumes\_from) | The VolumeFrom property specifies details on a data volume from another container in the same task definition | `list(any)` | `[]` | no |
| <a name="input_env"></a> [env](#input\_env) | Target environment name of the infrastructure | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Set of environment variables | `map(string)` | n/a | yes |
| <a name="input_firelens_ecs_log_enabled"></a> [firelens\_ecs\_log\_enabled](#input\_firelens\_ecs\_log\_enabled) | AWSFirelens ECS logs enabled | `bool` | `false` | no |
| <a name="input_global_secrets"></a> [global\_secrets](#input\_global\_secrets) | List of SSM ParameterStore global secrets - by default, /$var.env/global/* | `list(any)` | `[]` | no |
| <a name="input_iam_role_policy_statement"></a> [iam\_role\_policy\_statement](#input\_iam\_role\_policy\_statement) | ECS Service IAM Role policy statement | `list(any)` | `[]` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of running ECS tasks | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `512` | no |
| <a name="input_memoryReservation"></a> [memoryReservation](#input\_memoryReservation) | The soft limit (in MiB) of memory to reserve for the container | `number` | `1024` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | The soft limit (in MiB) of memory to reserve for the container | `number` | `256` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of running ECS tasks | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | ECS app name including the namespace (if applies) | `string` | n/a | yes |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | n/a | `any` | n/a | yes |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | Docker container port mapping to a host port. We don't forward ports from the container if we are using proxy (proxy reaches out to container via internal network) | `list(any)` | `[]` | no |
| <a name="input_resource_requirements"></a> [resource\_requirements](#input\_resource\_requirements) | The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU | `list(any)` | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups to assign to ECS Fargate task/ECS EC2 | `list(any)` | `[]` | no |
| <a name="input_service_desired_count"></a> [service\_desired\_count](#input\_service\_desired\_count) | The number of instances of a task definition | `number` | `1` | no |
| <a name="input_shared_memory_size"></a> [shared\_memory\_size](#input\_shared\_memory\_size) | Size of the /dev/shm shared memory in MB | `number` | `0` | no |
| <a name="input_sidecar_container_definitions"></a> [sidecar\_container\_definitions](#input\_sidecar\_container\_definitions) | ECS Sidecar container definitions, e.g. Datadog agent | `any` | `[]` | no |
| <a name="input_ssm_global_secret_path"></a> [ssm\_global\_secret\_path](#input\_ssm\_global\_secret\_path) | AWS SSM root path to global environment secrets like /dev/global | `string` | `null` | no |
| <a name="input_ssm_secret_path"></a> [ssm\_secret\_path](#input\_ssm\_secret\_path) | AWS SSM root path to environment secrets of an app like /dev/app1 | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | VPC subnets to place ECS task | `list(any)` | `[]` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | Application load balancer target group ARN | `string` | `null` | no |
| <a name="input_tmpfs_container_path"></a> [tmpfs\_container\_path](#input\_tmpfs\_container\_path) | Path where tmpfs shm would be mounted | `string` | `"/tmp/"` | no |
| <a name="input_tmpfs_enabled"></a> [tmpfs\_enabled](#input\_tmpfs\_enabled) | TMPFS support for non-Fargate deployments | `bool` | `false` | no |
| <a name="input_tmpfs_mount_options"></a> [tmpfs\_mount\_options](#input\_tmpfs\_mount\_options) | Options for the mount of the ram disk. noatime by default to speed up access | `list(string)` | <pre>[<br>  "noatime"<br>]</pre> | no |
| <a name="input_tmpfs_size"></a> [tmpfs\_size](#input\_tmpfs\_size) | Size of the tmpfs in MB | `number` | `1024` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts) | `list(any)` | `[]` | no |
| <a name="input_web_proxy_enabled"></a> [web\_proxy\_enabled](#input\_web\_proxy\_enabled) | Nginx proxy enabled | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_id"></a> [cloudwatch\_event\_rule\_id](#output\_cloudwatch\_event\_rule\_id) | Cloudwatch event rule for ECS Scheduled Task |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | Cloudwatch Log group of ECS Service |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS Cluster name |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Deployed ECS Task definition ARN |
<!-- END_TF_DOCS -->
