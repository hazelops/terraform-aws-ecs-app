# Terraform AWS ECS App Module
Terraform module to create AWS ECS application service

## Security & Compliance [<img src="https://cloudposse.com/wp-content/uploads/2020/11/bridgecrew.svg" width="250" align="right" />](https://bridgecrew.io/)

Security scanning is graciously provided by Bridgecrew.

| Benchmark | Description |
|--------|---------------|
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=INFRASTRUCTURE+SECURITY) | Infrastructure Security Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+AWS+V1.2) | Center for Internet Security, AWS V1.2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_azure)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+AZURE+V1.1) | Center for Internet Security, AZURE V1.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/pci)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=PCI-DSS+V3.2) | Payment Card Industry Data Security Standards V3.2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/nist)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=NIST-800-53) | National Institute of Standards and Technology Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/iso)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=ISO27001) | Information Security Management System, ISO/IEC 27001 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/soc2)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=SOC2) | Service Organization Control 2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/soc2)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=SOC2) | Center for Internet Security, GCP Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/hipaa)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=HIPAA) | Health Insurance Portability and Accountability Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/pci_dss_v321)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=PCI-DSS+V3.2.1) | PCI-DSS V3.2.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/fedramp_moderate)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=FEDRAMP+%28MODERATE%29) | FEDRAMP (MODERATE) Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_kubernetes)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+KUBERNETES+V1.5) | Center for Internet Security, KUBERNETES V1.5 Compliance  |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_aws_13)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+AWS+V1.3) | Center for Internet Security, AWS V1.3 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_azure_13)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+AZURE+V1.3) | Center for Internet Security, AZURE V1.3 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_docker_12)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+DOCKER+V1.2) | Center for Internet Security, Docker V1.2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_eks_11)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+EKS+V1.1) | Center for Internet Security, EKS V1.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_gke_11)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+GKE+V1.1) | Center for Internet Security, GKE V1.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ecs-app/cis_kubernetes_16)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ecs-app&benchmark=CIS+KUBERNETES+V1.6) | Center for Internet Security, KUBERNETES V1.6 Compliance |


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 5.0 |
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | ~> 3.0 |
| <a name="module_datadog"></a> [datadog](#module\_datadog) | hazelops/ecs-datadog-agent/aws | ~> 3.0 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | hazelops/ecr/aws | ~> 1.0 |
| <a name="module_efs"></a> [efs](#module\_efs) | cloudposse/efs/aws | ~> 0.31 |
| <a name="module_nginx"></a> [nginx](#module\_nginx) | hazelops/ecs-nginx-proxy/aws | ~> 1.0 |
| <a name="module_route_53_health_check"></a> [route\_53\_health\_check](#module\_route\_53\_health\_check) | hazelops/route53-healthcheck/aws | ~> 1.0 |
| <a name="module_service"></a> [service](#module\_service) | ./ecs-modules/ecs-service | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [template_file.asg_ecs_ec2_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_deregistration_delay"></a> [alb\_deregistration\_delay](#input\_alb\_deregistration\_delay) | n/a | `number` | `5` | no |
| <a name="input_alb_health_check_healthy_threshold"></a> [alb\_health\_check\_healthy\_threshold](#input\_alb\_health\_check\_healthy\_threshold) | n/a | `number` | `3` | no |
| <a name="input_alb_health_check_interval"></a> [alb\_health\_check\_interval](#input\_alb\_health\_check\_interval) | n/a | `number` | `30` | no |
| <a name="input_alb_health_check_path"></a> [alb\_health\_check\_path](#input\_alb\_health\_check\_path) | ALB health check path | `string` | `"/health"` | no |
| <a name="input_alb_health_check_timeout"></a> [alb\_health\_check\_timeout](#input\_alb\_health\_check\_timeout) | n/a | `number` | `6` | no |
| <a name="input_alb_health_check_unhealthy_threshold"></a> [alb\_health\_check\_unhealthy\_threshold](#input\_alb\_health\_check\_unhealthy\_threshold) | n/a | `number` | `3` | no |
| <a name="input_alb_health_check_valid_response_codes"></a> [alb\_health\_check\_valid\_response\_codes](#input\_alb\_health\_check\_valid\_response\_codes) | n/a | `string` | `"200-399"` | no |
| <a name="input_alb_idle_timeout"></a> [alb\_idle\_timeout](#input\_alb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_alb_security_groups"></a> [alb\_security\_groups](#input\_alb\_security\_groups) | Security groups to assign to ALB | `list` | `[]` | no |
| <a name="input_autoscale_enabled"></a> [autoscale\_enabled](#input\_autoscale\_enabled) | ECS Autoscaling enabled | `bool` | `false` | no |
| <a name="input_autoscale_scheduled_down"></a> [autoscale\_scheduled\_down](#input\_autoscale\_scheduled\_down) | List of Cron-like expressions for scheduled ecs autoscale DOWN | `list` | `[]` | no |
| <a name="input_autoscale_scheduled_up"></a> [autoscale\_scheduled\_up](#input\_autoscale\_scheduled\_up) | List of Cron-like expressions for scheduled ecs autoscale UP | `list` | `[]` | no |
| <a name="input_autoscale_target_value_cpu"></a> [autoscale\_target\_value\_cpu](#input\_autoscale\_target\_value\_cpu) | ECS Service Average CPU Utilization threshold. Integer value for percentage - IE 80 | `number` | `50` | no |
| <a name="input_autoscale_target_value_memory"></a> [autoscale\_target\_value\_memory](#input\_autoscale\_target\_value\_memory) | ECS Service Average Memory Utilization threshold. Integer value for percentage. IE 60 | `number` | `50` | no |
| <a name="input_autoscaling_health_check_type"></a> [autoscaling\_health\_check\_type](#input\_autoscaling\_health\_check\_type) | ECS 'EC2' or 'ELB' health check type | `string` | `"EC2"` | no |
| <a name="input_aws_service_discovery_private_dns_namespace"></a> [aws\_service\_discovery\_private\_dns\_namespace](#input\_aws\_service\_discovery\_private\_dns\_namespace) | Amazon ECS Service Discovery private DNS namespace | `string` | `""` | no |
| <a name="input_cloudwatch_schedule_expressions"></a> [cloudwatch\_schedule\_expressions](#input\_cloudwatch\_schedule\_expressions) | List of Cron-like Cloudwatch Event Rule schedule expressions (UTC time zone) | `list` | `[]` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `256` | no |
| <a name="input_datadog_enabled"></a> [datadog\_enabled](#input\_datadog\_enabled) | Datadog agent is enabled | `bool` | `false` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit on the number of running tasks | `number` | `100` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number (capacity) of running ECS tasks | `number` | `1` | no |
| <a name="input_docker_container_command"></a> [docker\_container\_command](#input\_docker\_container\_command) | Docker container command | `list(string)` | `[]` | no |
| <a name="input_docker_container_port"></a> [docker\_container\_port](#input\_docker\_container\_port) | Docker container port | `number` | `3000` | no |
| <a name="input_docker_image_name"></a> [docker\_image\_name](#input\_docker\_image\_name) | Docker image name | `string` | `""` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | Docker image tag | `string` | `"latest"` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | ERC docker registry | `string` | n/a | yes |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names for AWS Route53 A records | `list` | `[]` | no |
| <a name="input_ec2_service_group"></a> [ec2\_service\_group](#input\_ec2\_service\_group) | Service group name, e.g. app, service name etc. | `string` | `"app"` | no |
| <a name="input_ecr_repo_create"></a> [ecr\_repo\_create](#input\_ecr\_repo\_create) | Creation of a ECR repo | `bool` | `false` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | ECR repository name | `string` | `""` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS cluster name | `string` | `""` | no |
| <a name="input_ecs_exec_enabled"></a> [ecs\_exec\_enabled](#input\_ecs\_exec\_enabled) | Turns on the Amazon ECS Exec for the task | `bool` | `false` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | ECS launch type: FARGATE or EC2 | `string` | `"FARGATE"` | no |
| <a name="input_ecs_network_mode"></a> [ecs\_network\_mode](#input\_ecs\_network\_mode) | Corresponds to networkMode in an ECS task definition. Supported values are none, bridge, host, or awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ecs_platform_version"></a> [ecs\_platform\_version](#input\_ecs\_platform\_version) | The platform version on which to run your service. Only applicable when using Fargate launch type | `string` | `"LATEST"` | no |
| <a name="input_ecs_service_deployed"></a> [ecs\_service\_deployed](#input\_ecs\_service\_deployed) | This service resource doesn't have task definition lifecycle policy, so terraform is used to deploy it (instead of ecs cli) | `bool` | `false` | no |
| <a name="input_ecs_service_discovery_enabled"></a> [ecs\_service\_discovery\_enabled](#input\_ecs\_service\_discovery\_enabled) | ECS service can optionally be configured to use Amazon ECS Service Discovery | `bool` | `false` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | The ECS service name | `string` | `""` | no |
| <a name="input_ecs_volumes_from"></a> [ecs\_volumes\_from](#input\_ecs\_volumes\_from) | The VolumeFrom property specifies details on a data volume from another container in the same task definition | `list` | `[]` | no |
| <a name="input_efs_enabled"></a> [efs\_enabled](#input\_efs\_enabled) | EFS Enabled | `bool` | `false` | no |
| <a name="input_efs_mount_point"></a> [efs\_mount\_point](#input\_efs\_mount\_point) | EFS mount point | `string` | `"/mnt/efs"` | no |
| <a name="input_efs_root_directory"></a> [efs\_root\_directory](#input\_efs\_root\_directory) | EFS root directory | `string` | `"/"` | no |
| <a name="input_env"></a> [env](#input\_env) | Target environment name of the infrastructure | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Set of environment variables | `map(string)` | n/a | yes |
| <a name="input_firelens_ecs_log_enabled"></a> [firelens\_ecs\_log\_enabled](#input\_firelens\_ecs\_log\_enabled) | AWSFirelens ECS logs enabled | `bool` | `false` | no |
| <a name="input_global_secrets"></a> [global\_secrets](#input\_global\_secrets) | List of SSM ParameterStore global secrets - by default, /$var.env/global/* | `list` | `[]` | no |
| <a name="input_gpu"></a> [gpu](#input\_gpu) | GPU-enabled container instances | `number` | `0` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile | `string` | `null` | no |
| <a name="input_iam_role_policy_statement"></a> [iam\_role\_policy\_statement](#input\_iam\_role\_policy\_statement) | ECS Service IAM Role policy statement | `list(any)` | `[]` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | EC2 AMI id | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for ECS | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 key name | `string` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of running ECS tasks | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `512` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of running ECS tasks | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | The service name | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name within the infrastructure | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | VPC Private subnets to place ECS resources | `list` | `[]` | no |
| <a name="input_proxy_docker_container_command"></a> [proxy\_docker\_container\_command](#input\_proxy\_docker\_container\_command) | Proxy docker container CMD | `list(string)` | <pre>[<br>  "nginx",<br>  "-g",<br>  "daemon off;"<br>]</pre> | no |
| <a name="input_proxy_docker_entrypoint"></a> [proxy\_docker\_entrypoint](#input\_proxy\_docker\_entrypoint) | Proxy docker container entrypoint | `list` | <pre>[<br>  "/docker-entrypoint.sh"<br>]</pre> | no |
| <a name="input_proxy_docker_image_name"></a> [proxy\_docker\_image\_name](#input\_proxy\_docker\_image\_name) | Nginx proxy docker image name | `string` | `"nginx"` | no |
| <a name="input_public"></a> [public](#input\_public) | It's publicity accessible service | `bool` | `true` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | VPC Public subnets to place ECS resources | `list` | `[]` | no |
| <a name="input_resource_requirements"></a> [resource\_requirements](#input\_resource\_requirements) | The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU | `list` | `[]` | no |
| <a name="input_root_block_device_size"></a> [root\_block\_device\_size](#input\_root\_block\_device\_size) | n/a | `number` | `"50"` | no |
| <a name="input_root_block_device_type"></a> [root\_block\_device\_type](#input\_root\_block\_device\_type) | n/a | `string` | `"gp2"` | no |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | Domain name of AWS Route53 Zone | `string` | n/a | yes |
| <a name="input_route53_health_check_enabled"></a> [route53\_health\_check\_enabled](#input\_route53\_health\_check\_enabled) | AWS Route53 health check is enabled | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups to assign to ECS Fargate task/ECS EC2 | `list` | `[]` | no |
| <a name="input_app_secrets"></a> [service\_secrets](#input\_service\_secrets) | List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/* | `list` | `[]` | no |
| <a name="input_app_type"></a> [service\_type](#input\_service\_type) | ECS application type. Valid values: web (with load balancer), worker (scheduled task without ALB). | `string` | `"web"` | no |
| <a name="input_sns_service_subscription_endpoint"></a> [sns\_service\_subscription\_endpoint](#input\_sns\_service\_subscription\_endpoint) | You can use different endpoints, such as email, Pagerduty, Slack, etc. | `string` | `"exmple@example.com"` | no |
| <a name="input_sns_service_subscription_endpoint_protocol"></a> [sns\_service\_subscription\_endpoint\_protocol](#input\_sns\_service\_subscription\_endpoint\_protocol) | See valid protocols here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol-support | `string` | `"email"` | no |
| <a name="input_ssm_global_secret_path"></a> [ssm\_global\_secret\_path](#input\_ssm\_global\_secret\_path) | AWS SSM root path to global environment secrets like /dev/global | `string` | `null` | no |
| <a name="input_ssm_secret_path"></a> [ssm\_secret\_path](#input\_ssm\_secret\_path) | AWS SSM root path to environment secrets of an app like /dev/app1 | `string` | `null` | no |
| <a name="input_tls_cert_arn"></a> [tls\_cert\_arn](#input\_tls\_cert\_arn) | TLS certificate ARN | `string` | `null` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts) | `list` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC ID | `string` | n/a | yes |
| <a name="input_web_proxy_docker_container_port"></a> [web\_proxy\_docker\_container\_port](#input\_web\_proxy\_docker\_container\_port) | Proxy docker container port | `number` | `80` | no |
| <a name="input_web_proxy_docker_image_tag"></a> [web\_proxy\_docker\_image\_tag](#input\_web\_proxy\_docker\_image\_tag) | Nginx proxy docker image tag | `string` | `"1.19.2-alpine"` | no |
| <a name="input_web_proxy_enabled"></a> [web\_proxy\_enabled](#input\_web\_proxy\_enabled) | Nginx proxy enabled | `bool` | `false` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | AWS Route53 Zone ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | n/a |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | n/a |
| <a name="output_alb_dns_zone"></a> [alb\_dns\_zone](#output\_alb\_dns\_zone) | n/a |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | n/a |
| <a name="output_efs"></a> [efs](#output\_efs) | n/a |
| <a name="output_this_target_group_arn"></a> [this\_target\_group\_arn](#output\_this\_target\_group\_arn) | n/a |
| <a name="output_this_task_definition_arn"></a> [this\_task\_definition\_arn](#output\_this\_task\_definition\_arn) | n/a |
