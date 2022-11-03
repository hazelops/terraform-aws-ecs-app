output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "private_subnet_cidrs" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "cloudwatch_log_group" {
  value = module.tcp_app.cloudwatch_log_group
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

