locals {
  public_subnets       = module.vpc.public_subnets
  private_subnets      = module.vpc.private_subnets
  vpc_id               = module.vpc.vpc_id
  security_groups      = [aws_security_group.default_permissive.id]
  alb_security_groups  = [aws_security_group.default_permissive.id]
  zone_id              = aws_route53_zone.env_domain.id

  image_id             = data.aws_ami.amazon_linux_ecs_generic.id
  tls_cert_arn         = length(module.env_acm.acm_certificate_arn) > 0 ? module.env_acm.acm_certificate_arn : null
}

variable "env" {}
variable "namespace" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "ssh_public_key" {}
variable "docker_registry" {}
variable "docker_image_tag" {}
variable "root_domain_name" {}
