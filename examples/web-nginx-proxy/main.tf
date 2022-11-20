# Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.0"
}

# Data
data "aws_route53_zone" "root" {
  name         = "${var.root_domain_name}."
  private_zone = false
}

# Main
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.env}-vpc"
  cidr = "10.2.0.0/16"

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]
  public_subnets = [
    "10.2.10.0/23",
    "10.2.12.0/23"
  ]

  private_subnets = [
    "10.2.20.0/23"
  ]

  enable_nat_gateway                  = true
  single_nat_gateway                  = true
  manage_default_network_acl          = true
  default_network_acl_name            = "${var.env}-${var.namespace}"
}
resource "aws_security_group" "default_permissive" {
  name        = "${var.env}-default-permissive"
  vpc_id      = module.vpc.vpc_id

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

}

resource "aws_route53_record" "env_ns_record" {
  zone_id = data.aws_route53_zone.root.id
  name    = "${var.env}.${var.root_domain_name}"
  type    = "NS"
  ttl     = "60"
  records = aws_route53_zone.env_domain.name_servers
}

resource "aws_route53_zone" "env_domain" {
  name = "${var.env}.${var.root_domain_name}"
}

module "ecs" {
  source             = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version            = "~> 4.0"
  cluster_name       = "${var.env}-${var.namespace}-proxy"
}

module "web_proxy" {
  source = "../.."

  name                  = "proxy"
  app_type              = "web"
  env                   = var.env
  namespace             = var.namespace
  
  # Nginx Proxy enabling
  web_proxy_enabled     = true
  # We mount a shared volume to /etc/nginx dir in our container. In order to the web proxy to work - your app must copy(create) Nginx config template to /etc/nginx/templates/default.conf.template. See proxied-prj/entrypoint.sh.  

  # Containers
  ecs_cluster_name      = module.ecs.cluster_name
  docker_registry       = var.docker_registry
  docker_image_tag      = var.docker_image_tag

  # Load Balancer
  public                = true
  https_enabled         = false
  alb_health_check_path = "/"
  alb_security_groups   = [aws_security_group.default_permissive.id]

  # Network
  vpc_id                        = module.vpc.vpc_id
  public_subnets                = module.vpc.public_subnets
  private_subnets               = module.vpc.private_subnets
  security_groups               = [aws_security_group.default_permissive.id]
  root_domain_name              = var.root_domain_name
  zone_id                       = aws_route53_zone.env_domain.id

  # Environment variables
  app_secrets = [
  ]
  environment = {
  }
}

