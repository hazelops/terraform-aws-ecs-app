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
  value = length(module.alb[*].this_lb_dns_name) >= 1 ? module.alb[0].this_lb_dns_name : ""
}

output "alb_dns_zone" {
  value = length(module.alb[*].this_lb_zone_id) >= 1 ? module.alb[0].this_lb_zone_id : ""
}

output "alb_arn" {
  value = length(module.alb[*].this_lb_arn) >= 1 ? module.alb[0].this_lb_arn : ""
}

output "efs" {
  value = module.efs.mount_target_dns_names[*]
}

output "eips" {
  value = var.ec2_eip_enabled ? aws_eip.autoscaling.*.public_ip : []
}
