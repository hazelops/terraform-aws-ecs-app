# ECS Task Module

This module creates an ECS Task.
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.dd_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_container_definition_parameters"></a> [additional\_container\_definition\_parameters](#input\_additional\_container\_definition\_parameters) | Additional parameters passed straight to the container definition, eg. tmpfs config | `any` | `{}` | no |
| <a name="input_app_secrets"></a> [app\_secrets](#input\_app\_secrets) | List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/* | `list(any)` | `[]` | no |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch\_retention\_in\_days](#input\_cloudwatch\_retention\_in\_days) | Default AWS Cloudwatch retention in days | `number` | `90` | no |
| <a name="input_cloudwatch_schedule_expressions"></a> [cloudwatch\_schedule\_expressions](#input\_cloudwatch\_schedule\_expressions) | List of Cron-like Cloudwatch Event Rule schedule expressions (https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html) | `list(any)` | `[]` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `256` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | n/a | `any` | n/a | yes |
| <a name="input_docker_container_command"></a> [docker\_container\_command](#input\_docker\_container\_command) | Docker container command | `list(string)` | `[]` | no |
| <a name="input_docker_container_depends_on"></a> [docker\_container\_depends\_on](#input\_docker\_container\_depends\_on) | Docker container dependencies | `list(any)` | `[]` | no |
| <a name="input_docker_container_entrypoint"></a> [docker\_container\_entrypoint](#input\_docker\_container\_entrypoint) | Docker container entrypoint | `list(string)` | `[]` | no |
| <a name="input_docker_container_links"></a> [docker\_container\_links](#input\_docker\_container\_links) | ECS container definitions links | `list(any)` | `[]` | no |
| <a name="input_docker_container_port"></a> [docker\_container\_port](#input\_docker\_container\_port) | Docker container port | `number` | `3000` | no |
| <a name="input_docker_image_name"></a> [docker\_image\_name](#input\_docker\_image\_name) | Docker image name | `string` | `""` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | Docker image tag | `string` | `"latest"` | no |
| <a name="input_docker_labels"></a> [docker\_labels](#input\_docker\_labels) | Labels to be added to the docker. Used for auto-configuration, for instance of JMX discovery | `map(any)` | `null` | no |
| <a name="input_ecs_exec_enabled"></a> [ecs\_exec\_enabled](#input\_ecs\_exec\_enabled) | Turns on the Amazon ECS Exec for the task | `bool` | `true` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | ECS launch type: FARGATE or EC2 | `string` | `"FARGATE"` | no |
| <a name="input_ecs_network_configuration"></a> [ecs\_network\_configuration](#input\_ecs\_network\_configuration) | ECS Network Configuration | `map(any)` | `{}` | no |
| <a name="input_ecs_network_mode"></a> [ecs\_network\_mode](#input\_ecs\_network\_mode) | Corresponds to networkMode in an ECS task definition. Supported values are none, bridge, host, or awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ecs_task_family_name"></a> [ecs\_task\_family\_name](#input\_ecs\_task\_family\_name) | ECS Task Family Name | `string` | `""` | no |
| <a name="input_ecs_task_health_check_command"></a> [ecs\_task\_health\_check\_command](#input\_ecs\_task\_health\_check\_command) | Command to check for the health of the container | `string` | n/a | yes |
| <a name="input_ecs_volumes_from"></a> [ecs\_volumes\_from](#input\_ecs\_volumes\_from) | The VolumeFrom property specifies details on a data volume from another container in the same task definition | `list(any)` | `[]` | no |
| <a name="input_env"></a> [env](#input\_env) | Target environment name of the infrastructure | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Set of environment variables | `map(string)` | n/a | yes |
| <a name="input_firelens_ecs_log_enabled"></a> [firelens\_ecs\_log\_enabled](#input\_firelens\_ecs\_log\_enabled) | AWSFirelens ECS logs enabled | `bool` | `false` | no |
| <a name="input_global_secrets"></a> [global\_secrets](#input\_global\_secrets) | List of SSM ParameterStore global secrets - by default, /$var.env/global/* | `list(any)` | `[]` | no |
| <a name="input_iam_role_policy_statement"></a> [iam\_role\_policy\_statement](#input\_iam\_role\_policy\_statement) | ECS Task IAM Role policy statement | `list(any)` | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `512` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | The soft limit (in MiB) of memory to reserve for the container | `number` | `256` | no |
| <a name="input_name"></a> [name](#input\_name) | ECS app name including namespace (if applies) | `string` | n/a | yes |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | n/a | `any` | n/a | yes |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | Docker container port mapping to a host port. We don't forward ports from the container if we are using proxy (proxy reaches out to container via internal network) | `list(any)` | `[]` | no |
| <a name="input_resource_requirements"></a> [resource\_requirements](#input\_resource\_requirements) | The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU | `list(any)` | `[]` | no |
| <a name="input_shared_memory_size"></a> [shared\_memory\_size](#input\_shared\_memory\_size) | Size of the /dev/shm shared memory in MB | `number` | `0` | no |
| <a name="input_sidecar_container_definitions"></a> [sidecar\_container\_definitions](#input\_sidecar\_container\_definitions) | ECS Sidecar container definitions, e.g. Datadog agent | `any` | `[]` | no |
| <a name="input_ssm_global_secret_path"></a> [ssm\_global\_secret\_path](#input\_ssm\_global\_secret\_path) | AWS SSM root path to global environment secrets like /dev/global | `string` | `null` | no |
| <a name="input_ssm_secret_path"></a> [ssm\_secret\_path](#input\_ssm\_secret\_path) | AWS SSM root path to environment secrets of an app like /dev/app1 | `string` | `null` | no |
| <a name="input_task_group"></a> [task\_group](#input\_task\_group) | ECS Task group name, e.g. app, service name etc. | `string` | `"app"` | no |
| <a name="input_tmpfs_container_path"></a> [tmpfs\_container\_path](#input\_tmpfs\_container\_path) | Path where tmpfs tmpfs would be mounted | `string` | `"/tmp/"` | no |
| <a name="input_tmpfs_enabled"></a> [tmpfs\_enabled](#input\_tmpfs\_enabled) | TMPFS support for non-Fargate deployments | `bool` | `false` | no |
| <a name="input_tmpfs_mount_options"></a> [tmpfs\_mount\_options](#input\_tmpfs\_mount\_options) | Options for the mount of the ram disk. noatime by default to speed up access | `list(string)` | <pre>[<br>  "noatime"<br>]</pre> | no |
| <a name="input_tmpfs_size"></a> [tmpfs\_size](#input\_tmpfs\_size) | Size of the tmpfs in MB | `number` | `1024` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts) | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | Cloudwatch Log group of ECS Service |
| <a name="output_ecs_launch_type"></a> [ecs\_launch\_type](#output\_ecs\_launch\_type) | ECS launch type: FARGATE or EC2 |
| <a name="output_ecs_network_configuration"></a> [ecs\_network\_configuration](#output\_ecs\_network\_configuration) | ECS Network Configuration of ECS Task |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | Deployed ECS Task definition ARN |
<!-- END_TF_DOCS -->
