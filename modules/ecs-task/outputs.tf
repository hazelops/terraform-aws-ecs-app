output "task_definition_arn" {
  description = "Deployed ECS Task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}


output "cloudwatch_log_group" {
  description = "Cloudwatch Log group of ECS Service"
  value       = aws_cloudwatch_log_group.this.name
}

output "ecs_network_configuration" {
  description = "ECS Network Configuration of ECS Task"
  value       = var.ecs_network_configuration
}

output "ecs_launch_type" {
  description = "ECS launch type: FARGATE or EC2"
  value       = var.ecs_launch_type
}
