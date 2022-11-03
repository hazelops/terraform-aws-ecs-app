# Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.0"
}

# Main
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.env}-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "${var.aws_region}a"
  ]
  public_subnets = [
    "10.0.10.0/23"
  ]

  private_subnets = [
    "10.0.20.0/23"
  ]

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

module "ecs" {
  source             = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version            = "~> 4.0"
  cluster_name       = "${var.env}-${var.namespace}"
}

module "worker_scheduled" {
  source = "../.."

  name             = "worker"
  app_type         = "worker"
  env              = var.env
  namespace        = var.namespace

  public           = false
  ecs_launch_type  = "FARGATE"

  # Containers
  ecs_cluster_arn       = module.ecs.cluster_arn
  ecs_cluster_name      = module.ecs.cluster_name
  docker_registry       = var.docker_registry
  docker_image_tag      = var.docker_image_tag

  docker_container_command           = ["echo", "command-output"]
  deployment_minimum_healthy_percent = 0

  # Autoscaling
  autoscale_enabled = true
  min_size          = 1
  max_size          = 1
  desired_capacity  = 1

  # Scheduled ECS scaling up/down
  autoscaling_min_size         = 1
  autoscaling_max_size         = 4
  autoscale_scheduled_timezone = "America/Los_Angeles"

  # Scaling to the value of autoscaling_max_size
  # Time is in PST here (see `autoscale_scheduled_timezone` parameter)
  autoscale_scheduled_up = [
    "cron(30 21 * * ? *)",
    "cron(30 13 * * ? *)",
  ]

  # Scaling down - back to default autoscaling_min_size
  autoscale_scheduled_down = [
    "cron(00 03 * * ? *)",
    "cron(00 15 * * ? *)",
  ]

  # Network
  vpc_id                        = module.vpc.vpc_id
  private_subnets               = module.vpc.private_subnets
  security_groups               = [aws_security_group.default_permissive.id]

  # Environment variables
  app_secrets = [
  ]
  environment = {
  }
}

