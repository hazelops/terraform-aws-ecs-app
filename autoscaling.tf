module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  create_asg = var.ecs_launch_type == "EC2" ? true : false
  create_lc  = var.ecs_launch_type == "EC2" ? true : false
  name       = local.name

  # Launch configuration
  lc_name = local.name

  # Auto scaling group
  asg_name                     = local.name
  image_id                     = var.image_id
  instance_type                = var.instance_type
  security_groups              = var.security_groups
  iam_instance_profile         = var.iam_instance_profile
  key_name                     = var.key_name
  recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size = var.root_block_device_size
      volume_type = var.root_block_device_type
    },
  ]

  target_group_arns = var.app_type == "web" ? module.alb[0].target_group_arns : []
  user_data         = var.ecs_launch_type == "EC2" ? data.template_file.asg_ecs_ec2_user_data.rendered : null

  vpc_zone_identifier       = var.private_subnets
  health_check_type         = var.autoscaling_health_check_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "cluster"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "service-groups"
      value               = var.ec2_service_group
      propagate_at_launch = true
    },
  ]
}


