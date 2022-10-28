data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

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

