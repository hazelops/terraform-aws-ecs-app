output "target_group_arn" {
  value = length(module.alb[*].target_groups) >= 1 ? module.alb[0].target_groups[0] : ""
}

output "task_definition_arn" {
  value = module.service.task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.service.cloudwatch_log_group
}

output "cloudwatch_event_rule_id" {
  value = module.service.cloudwatch_event_rule_id
}

output "alb_dns_name" {
  value = length(module.alb[*].dns_name) >= 1 ? module.alb[0].dns_name : ""
}

output "alb_dns_zone" {
  value = length(module.alb[*].zone_id) >= 1 ? module.alb[0].zone_id : ""
}

output "alb_arn" {
  value = length(module.alb[*].arn) >= 1 ? module.alb[0].arn : ""
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
