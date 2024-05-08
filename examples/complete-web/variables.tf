locals {
  tls_cert_arn = length(module.env_acm.acm_certificate_arn) > 0 ? module.env_acm.acm_certificate_arn : null
}

variable "env" {}
variable "namespace" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "docker_registry" {
  default = "docker.io"
}
variable "docker_image_tag" {
  default = "latest"
}
variable "root_domain_name" {
  default = "nutcorp.net"
}
