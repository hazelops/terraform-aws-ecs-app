locals {
  app_secrets    = concat(var.app_secrets, [])
  global_secrets = concat(var.global_secrets, [])
  environment    = merge(var.environment, {})
}
