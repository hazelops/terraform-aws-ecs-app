# Data
data "aws_ami" "amazon_linux_ecs_generic" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Main
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

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

resource "aws_key_pair" "root" {
  key_name   = var.ec2_key_pair_name
  public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      public_key
    ]
  }
}

module "ecs" {
  source       = "registry.terraform.io/terraform-aws-modules/ecs/aws"
  version      = "~> 6.0"
  cluster_name = "${var.env}-${var.namespace}-worker-ec2"
}

module "worker_complete" {
  source = "../.."

  name     = "worker-ec2"
  app_type = "worker"
  env      = var.env

  public           = false
  ecs_launch_type  = "EC2"
  ecs_network_mode = "host"
  instance_type    = "t3.medium"
  max_size         = 1
  desired_capacity = 0


  # Containers
  ecs_cluster_arn  = module.ecs.cluster_arn
  ecs_cluster_name = module.ecs.cluster_name
  docker_registry  = var.docker_registry
  docker_image_tag = var.docker_image_tag

  docker_container_command = ["echo", "command-output"]
  deployment_minimum_healthy_percent = 0

  # Network
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  security_groups             = [aws_security_group.default_permissive.id]
  key_name                    = var.ec2_key_pair_name
  create_iam_instance_profile = true
  image_id = data.aws_ami.amazon_linux_ecs_generic.id

  # Environment variables
  app_secrets = [
  ]
  environment = {
  }
}

