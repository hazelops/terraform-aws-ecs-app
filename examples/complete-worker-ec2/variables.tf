variable "env" {}
variable "namespace" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "docker_registry" {
  default     = "docker.io"
}
variable "docker_image_tag" {
  default     = "latest"
}
variable "ec2_key_pair_name" {}
variable "ssh_public_key" {}
