module "web_complete" {
  source = "../.."

  name             = "app"
  app_type         = "web"
  env              = var.env
  namespace        = var.namespace
  ecs_cluster_name = local.ecs_cluster_name

  # Containers
  docker_registry      = local.docker_registry
  image_id             = local.image_id
  docker_image_tag     = local.docker_image_tag
  iam_instance_profile = local.iam_instance_profile
  key_name             = local.key_name

  # Load Balancer
  public                = true
  alb_health_check_path = "/"
  alb_security_groups   = local.alb_security_groups
  tls_cert_arn          = local.tls_cert_arn

  # EFS settings
  efs_enabled        = false
  efs_mount_point    = "/mnt/efs"
  efs_root_directory = "/"

  # Network
  vpc_id                       = local.vpc_id
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  security_groups              = local.security_groups
  root_domain_name             = local.root_domain_name
  zone_id                      = local.zone_id
  route53_health_check_enabled = false
  domain_names = [
    "app.${var.root_domain_name}"
  ]

  # Environment variables
  app_secrets = [
  ]
  environment = {
    ENV      = var.env
    APP_NAME = "App"
  }
}

