output "this_target_group_arn" {
  value = length(module.alb[*].target_group_arns) >= 1 ? module.alb[0].target_group_arns[0] : ""
}

output "this_task_definition_arn" {
  value = module.service.task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.service.cloudwatch_log_group
}

output "alb_dns_name" {
  value = length(module.alb[*].lb_dns_name) >= 1 ? module.alb[0].lb_dns_name : ""
}

output "alb_dns_zone" {
  value = length(module.alb[*].lb_zone_id) >= 1 ? module.alb[0].lb_zone_id : ""
}

output "alb_arn" {
  value = length(module.alb[*].lb_arn) >= 1 ? module.alb[0].lb_arn : ""
}

output "efs" {
  value = var.efs_enabled ? module.efs.mount_target_dns_names[*] : ""
}

output "eips" {
  value = var.ec2_eip_enabled ? aws_eip.autoscaling.*.public_ip : []
}

output "public_ip" {
  value = (var.ec2_eip_enabled && length(aws_eip.autoscaling)>0) ? aws_eip.autoscaling.0.public_ip : ""
}

output "ec2_dns_name" {
  value = var.ec2_eip_dns_enabled ? aws_route53_record.ec2.0.fqdn : ""
}

output "r53_lb_dns_name" {
  value = var.app_type == "web" || var.app_type == "tcp-app" ? aws_route53_record.alb.0.fqdn : ""
}
