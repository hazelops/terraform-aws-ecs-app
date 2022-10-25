module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.env}-vpc"
  cidr = "10.30.0.0/16"

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
  public_subnets = [
    "10.30.10.0/23",
    "10.30.12.0/23",
    "10.30.14.0/23"
  ]

  private_subnets = [
    "10.30.20.0/23",
    "10.30.22.0/23",
    "10.30.24.0/23"
  ]
  # database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway                  = true
  single_nat_gateway                  = true
  enable_vpn_gateway                  = false

  enable_dns_hostnames                = true
  enable_dns_support                  = true
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

module "worker_complete" {
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

  docker_container_command           = ["rake", "notify:daily"]
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
  environment = {
    ENV      = var.env
    APP_NAME = "App"
  }

  iam_role_policy_statement = [
    {
      Effect   = "Allow",
      Action   = "s3:*",
      Resource = "*"
  }]
}

