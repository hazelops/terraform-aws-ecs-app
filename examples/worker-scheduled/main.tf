module "web_complete" {
  source = "../.."

  name             = "worker"
  app_type         = "worker"
  env              = var.env
  namespace        = var.namespace
  ecs_cluster_name = local.ecs_cluster_name

  public           = false
  ecs_launch_type  = "FARGATE"
  min_size         = 1
  max_size         = 1
  desired_capacity = 0
  memory           = 2048
  cpu              = 1024

  # Containers
  ecs_cluster_arn      = module.ecs.cluster_arn
  docker_registry      = local.docker_registry
  image_id             = local.image_id
  docker_image_tag     = local.docker_image_tag

  docker_container_command           = ["echo", "here-is-the-output"]
  cloudwatch_schedule_expressions    = ["cron(0 * * * ? *)"]
  deployment_minimum_healthy_percent = 0

  # Network
  vpc_id           = local.vpc_id
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  security_groups  = local.security_groups
  root_domain_name = var.root_domain_name
  zone_id          = local.zone_id

  # Environment variables
  app_secrets = [
  ]

}

