# IAM - CloudWatch Events Role
resource "aws_iam_role" "ecs_events" {
  count = var.cloudwatch_schedule_expressions == [] ? 0 : 1

  name               = var.ecs_service_name != "" ? "${var.ecs_service_name}-ECSEvents" : "${var.env}-${var.name}-ECSEvents"
  assume_role_policy = data.aws_iam_policy_document.ecs_events_assume_role[0].json
  path               = "/"
  description        = "CloudWatch Events IAM Role"
}

data "aws_iam_policy_document" "ecs_events_assume_role" {
  count = var.cloudwatch_schedule_expressions == [] ? 0 : 1

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service_events_role" {
  count = var.cloudwatch_schedule_expressions == [] ? 0 : 1

  role       = aws_iam_role.ecs_events[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}
