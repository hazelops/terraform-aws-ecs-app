locals {
  env                  = var.env
  namespace            = var.namespace

  public_subnets       = module.vpc.public_subnets
  private_subnets      = module.vpc.private_subnets
  vpc_id               = module.vpc.vpc_id
  security_groups      = [aws_security_group.default_permissive.id]
  alb_security_groups  = [aws_security_group.default_permissive.id]
  root_domain_name     = var.root_domain_name
  zone_id              = aws_route53_zone.env_domain.id

  docker_registry      = var.docker_registry
  docker_image_tag     = var.docker_image_tag

  ecs_cluster_name     = module.ecs.cluster_name
}

variable "env" {}
variable "namespace" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "ssh_public_key" {}
variable "docker_registry" {}
variable "docker_image_tag" {}
variable "root_domain_name" {}
