data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_instance_profile" "this" {
  count = var.ecs_launch_type == "EC2" ? 1 : 0
  name  = module.autoscaling.iam_instance_profile_id
}

# Get latest AMI info for Amazon Linux 2023 ECS optimized
data "aws_ami" "this" {
  count       = var.ecs_launch_type == "EC2" && var.image_id == null ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-2023*-${lower(var.cpu_architecture)}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

