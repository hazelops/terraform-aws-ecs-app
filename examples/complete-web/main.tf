module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.env}-vpc"
  cidr = "10.30.0.0/16"

  azs = [
    "${var.aws_region}a"
  ]
  public_subnets = [
    "10.30.10.0/23"
  ]

  private_subnets = [
    "10.30.20.0/23"
  ]
  manage_default_network_acl          = true
  default_network_acl_name            = "${var.env}-${var.namespace}"
}
resource "aws_security_group" "default_permissive" {
  name        = "${var.env}-default-permissive"
  vpc_id      = module.vpc.vpc_id
  description = "Managed by Terraform"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Terraform = "true"
    Env       = var.env
    Name      = "${var.env}-default-permissive"
  }
}

resource "aws_route53_record" "env_ns_record" {
  zone_id = data.aws_route53_zone.root.id
  name    = "${var.env}.${var.root_domain_name}"
  type    = "NS"
  //  ttl  = "172800"

  // Fast TTL for dev
  ttl     = "60"
  records = aws_route53_zone.env_domain.name_servers
}

resource "aws_route53_zone" "env_domain" {
  name = "${var.env}.${var.root_domain_name}"
}

module "env_acm" {
  source  = "registry.terraform.io/terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${local.env}.${local.root_domain_name}"

  subject_alternative_names = [
    "*.${local.env}.${local.root_domain_name}"
  ]

  zone_id = local.zone_id

  tags = {
    Name = "${var.env}.${var.root_domain_name}"
  }
}

module "ecs" {
  source             = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version            = "~> 4.0"
  cluster_name       = "${var.env}-${var.namespace}"
}

module "web_complete" {
  source = "../.."

  name                  = "app"
  app_type              = "web"
  env                   = var.env
  namespace             = var.namespace
  
  # Containers
  ecs_cluster_name      = local.ecs_cluster_name
  docker_registry       = local.docker_registry
  image_id              = local.image_id
  docker_image_tag      = local.docker_image_tag

  # Load Balancer
  public                = true
  alb_health_check_path = "/"
  alb_security_groups   = local.alb_security_groups
  tls_cert_arn          = local.tls_cert_arn

  # EFS settings
  efs_enabled           = false
  efs_mount_point       = "/mnt/efs"
  efs_root_directory    = "/"

  # Network
  vpc_id                        = local.vpc_id
  public_subnets                = local.public_subnets
  private_subnets               = local.private_subnets
  security_groups               = local.security_groups
  root_domain_name              = var.root_domain_name
  zone_id                       = local.zone_id
  route53_health_check_enabled  = false
  domain_names                  = [
    "app.${var.root_domain_name}"
  ]

  # Environment variables
  app_secrets = [
  ]
  environment = {
    ENV       = var.env
    APP_NAME  = "App"
  }
}

