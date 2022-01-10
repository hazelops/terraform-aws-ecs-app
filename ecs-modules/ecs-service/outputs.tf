output "task_definition_arn" {
  description = "Deployed ECS Task definition ARN"
  value       = module.task.task_definition_arn
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = var.ecs_cluster_name
}

output "cloudwatch_log_group" {
  description = "Cloudwatch Log group of ECS Service"
  value       = module.task.cloudwatch_log_group
}
