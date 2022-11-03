locals {
  tls_cert_arn  = length(module.env_acm.acm_certificate_arn) > 0 ? module.env_acm.acm_certificate_arn : null
}

variable "env" {}
variable "namespace" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "docker_registry" {}
variable "docker_image_tag" {}
variable "root_domain_name" {}
