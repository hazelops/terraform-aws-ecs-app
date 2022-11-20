output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "private_subnet_cidrs" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "cloudwatch_log_group" {
  value = module.worker_complete.cloudwatch_log_group
}

output "cloudwatch_event_rule_id" {
  value = module.worker_complete.cloudwatch_event_rule_id
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
