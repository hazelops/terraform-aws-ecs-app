data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_instance_profile" "this" {
  count = var.ecs_launch_type == "EC2" ? 1 : 0
  name  = module.autoscaling.iam_instance_profile_id
}

