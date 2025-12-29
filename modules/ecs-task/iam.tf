resource "aws_iam_role_policy" "ecs_execution" {
  name   = "${var.env}-${var.name}-ecs-execution-role-policy"
  role   = aws_iam_role.ecs_execution.id
  policy = jsonencode(local.iam_ecs_execution_role_policy)
}

resource "aws_iam_role" "ecs_execution" {
  name = "${var.env}-${var.name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "ecs-tasks.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task" {
  name   = "${var.env}-${var.name}-ecs-task-role-policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = jsonencode(local.iam_ecs_execution_role_policy)
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}-${var.name}-ecs-task-role"

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "ecs-tasks.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}
