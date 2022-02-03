resource "aws_eip" "autoscaling" {
  # If ec2_eip_count is set, use that number for number of EIPs, otherwise use var.max_size + 1 (but that might not be the best during downscaling and deletion of EIPs
  count             = var.ec2_eip_enabled ? (var.ec2_eip_count > 0 ? var.ec2_eip_count : var.max_size + 1) : 0
  public_ipv4_pool  = "amazon"

  tags = {
    Name = "${local.name}-${count.index + 1}"
    env  = var.env
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  create_asg = var.ecs_launch_type == "EC2" ? true : false
  create_lc  = var.ecs_launch_type == "EC2" ? true : false
  name       = local.name

  # Launch configuration
  lc_name = local.name

  # Auto scaling group
  #v4.0? asg_name              = local.name
  image_id                     = var.image_id
  instance_type                = var.instance_type
  security_groups              = var.security_groups
  iam_instance_profile_name    = var.iam_instance_profile # 4.0? var.iam_instance_profile - it's "ID of the IAM instance profile"
  key_name                     = var.key_name
  #4.0? recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size = var.root_block_device_size
      volume_type = var.root_block_device_type
    },
  ]

  target_group_arns = var.app_type == "web" ? module.alb[0].target_group_arns : []
  user_data         = var.ecs_launch_type == "EC2" ? data.template_file.asg_ecs_ec2_user_data.rendered : null

  vpc_zone_identifier       = var.public_ecs_service ? var.public_subnets : var.private_subnets
  health_check_type         = var.autoscaling_health_check_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0

  create_schedule           = var.create_schedule
  schedules                 = var.schedules

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


# IAM Role changes for ASG Auto EIP
resource "aws_iam_role_policy" "ec2_auto_eip" {
  count   = var.ec2_eip_enabled ? 1 : 0
  name    = "EC2ChangeEIP_Policy"
  role    = data.aws_iam_instance_profile.this.role_name


  policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:AssociateAddress"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
