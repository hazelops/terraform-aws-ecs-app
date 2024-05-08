# Data
data "aws_route53_zone" "root" {
  name         = "${var.root_domain_name}."
  private_zone = false
}

# Main
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.env}-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]
  public_subnets = [
    "10.0.10.0/23",
    "10.0.12.0/23"
  ]

  private_subnets = [
    "10.0.20.0/23"
  ]
  manage_default_network_acl = true
  default_network_acl_name   = "${var.env}-${var.namespace}"
}
resource "aws_security_group" "default_permissive" {
  name   = "${var.env}-default-permissive"
  vpc_id = module.vpc.vpc_id

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

module "env_acm" {
  source  = "registry.terraform.io/terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${var.env}.${var.root_domain_name}"

  subject_alternative_names = [
    "*.${var.env}.${var.root_domain_name}"
  ]

  zone_id = aws_route53_zone.env_domain.id

  tags = {
    Name = "${var.env}.${var.root_domain_name}"
  }
}

module "ecs" {
  source       = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version      = "~> 4.0"
  cluster_name = "${var.env}-${var.namespace}"
}

module "tcp_app" {
  source = "../.."

  name     = "tcpapp"
  app_type = "tcp-app"
  env = var.env

  # Containers
  ecs_cluster_name = module.ecs.cluster_name
  docker_registry  = var.docker_registry
  docker_image_tag = var.docker_image_tag

  # Load Balancer
  public        = true
  https_enabled = true
  tls_cert_arn  = local.tls_cert_arn

  port_mappings = [
    {
      container_port = 4442
      host_port      = 4442
    },
    {
      container_port = 4443
      host_port      = 4443
    },
    {
      container_port = 4444
      host_port      = 4444
      tls            = true
    }
  ]

  # Network
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  security_groups  = [aws_security_group.default_permissive.id]
  root_domain_name = var.root_domain_name
  zone_id = aws_route53_zone.env_domain.id

  # Environment variables
  app_secrets = [
  ]
  environment = {
  }
}

