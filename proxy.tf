module "nginx" {
  source  = "hazelops/ecs-nginx-proxy/aws"
  version = "~> 1.0"

  app_name = var.name
  env      = var.env
  environment = merge(var.environment, {
    PROXY_ENABLED = var.web_proxy_enabled ? "true" : "false"
    APP_HOST      = "127.0.0.1:${var.docker_container_port}"
  })

  cloudwatch_log_group  = module.service.cloudwatch_log_group
  ecs_launch_type       = var.ecs_launch_type
  ecs_network_mode      = var.ecs_network_mode
  enabled               = var.web_proxy_enabled
  docker_container_port = var.web_proxy_docker_container_port
  docker_image_tag      = var.web_proxy_docker_image_tag
}
