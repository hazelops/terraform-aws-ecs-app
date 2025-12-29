data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "dd_api_key" {
  count = var.firelens_ecs_log_enabled ? 1 : 0
  name  = "/${var.env}/global/DD_API_KEY"
}

