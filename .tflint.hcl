# Not enforcing any rules for now
config {
  module = true
  force = false
  format = "compact"
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

plugin "aws" {
  enabled = true
  version = "0.30.0"
  source = "github.com/terraform-linters/tflint-ruleset-aws"
}
