resource "aws_eip" "autoscaling" {
  # If ec2_eip_count is set, use that number for number of EIPs, otherwise use var.max_size + 1 (but that might not be the best during downscaling and deletion of EIPs
  count            = var.ec2_eip_enabled ? (var.ec2_eip_count > 0 ? var.ec2_eip_count : var.max_size + 1) : 0
  public_ipv4_pool = "amazon"
  domain           = "vpc"
  tags = {
    Name    = "${local.name}-${count.index + 1}"
    env     = var.env
    service = local.name
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.0"

  create                 = var.ecs_launch_type == "EC2" ? true : false
  create_launch_template = var.ecs_launch_type == "EC2" ? true : false

  name = local.name
  launch_template_name = local.name

  # Auto scaling group
  image_id        = var.image_id
  instance_type   = var.instance_type
  security_groups = var.security_groups
  key_name = var.key_name

  # EC2 Instance Profile
  create_iam_instance_profile = var.ecs_launch_type == "EC2" ? var.create_iam_instance_profile : false
  iam_instance_profile_name   = "${var.env}-${var.name}"
  iam_role_name               = "${var.env}-${var.name}-ec2-profile-role"
  iam_role_path               = "/ec2/"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.root_block_device_size
        volume_type           = var.root_block_device_type
      }
    }
  ]

  target_group_arns = var.app_type == "web" || var.app_type == "tcp-app" ? module.alb[0].target_group_arns : []
  user_data         = var.ecs_launch_type == "EC2" ? base64encode(local.asg_ecs_ec2_user_data) : null

  vpc_zone_identifier       = var.public_ecs_service ? var.public_subnets : var.private_subnets
  health_check_type         = var.autoscaling_health_check_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0

  create_schedule = var.create_schedule
  schedules       = var.schedules

  tags = {
    env            = var.env
    cluster        = local.ecs_cluster_name
    service-groups = var.ec2_service_group
  }
}


# IAM Role changes for ASG Auto EIP
resource "aws_iam_role_policy" "ec2_auto_eip" {
  count = var.ec2_eip_enabled && var.ecs_launch_type == "EC2" ? 1 : 0
  name  = "EC2ChangeEIP_Policy"
  role  = data.aws_iam_instance_profile.this[0].role_name


  policy = jsonencode({
    Version   = "2012-10-17"
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
