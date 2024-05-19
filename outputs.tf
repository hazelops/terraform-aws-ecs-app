output "this_target_group_arn" {
  value = length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[0] : ""
}

output "this_task_definition_arn" {
  value = module.service.task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.service.cloudwatch_log_group
}

output "cloudwatch_event_rule_id" {
  description = "ID of the Cloudwatch event rule for ECS Scheduled Task"
  value = module.service.cloudwatch_event_rule_id
}

output "alb_dns_name" {
  description = "Name of the ALB DNS record (if ALB is created)"
  value = length(module.alb[*].lb_dns_name) >= 1 ? module.alb[0].lb_dns_name : ""
}

output "alb_dns_zone" {
  description = "Zone ID of the ALB DNS record (if ALB is created)"
  value = length(module.alb[*].lb_zone_id) >= 1 ? module.alb[0].lb_zone_id : ""
}

output "alb_arn" {
  description = "ARN of the ALB (if ALB is created)"
  value = length(module.alb[*].lb_arn) >= 1 ? module.alb[0].lb_arn : ""
}

output "efs_mount_target" {
  description = "DNS name of the EFS mount target (if EFS is created)"
  value = var.efs_enabled && var.efs_share_create ? module.efs.mount_target_dns_names[0] : ""
}

output "eips" {
  description = "List of EIPs associated with the EC2 instances (if EC2 is used)"
  value = var.ec2_eip_enabled ? aws_eip.autoscaling.*.public_ip : []
}

output "public_ip" {
  description = "Public IP of the EC2 instance (if EC2 is used)"
  value = (var.ec2_eip_enabled && length(aws_eip.autoscaling)>0) ? aws_eip.autoscaling.0.public_ip : ""
}

output "ec2_dns_name" {
  description = "Public DNS name of the EC2 instance (if EC2 is used)"
  value = var.ec2_eip_dns_enabled ? aws_route53_record.ec2.0.fqdn : ""
}

output "r53_lb_dns_name" {
  description = "DNS name of the record that is attached to the ALB (if app type is web or tcp-ap)"
  value = var.app_type == "web" || var.app_type == "tcp-app" ? aws_route53_record.alb.0.fqdn : ""
}
