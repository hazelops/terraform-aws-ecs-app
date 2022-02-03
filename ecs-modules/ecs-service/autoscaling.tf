resource "aws_appautoscaling_target" "this" {
  count              = var.autoscale_enabled ? 1 : 0
  max_capacity       = var.max_size
  min_capacity       = var.min_size
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.this_deployed[0],
    aws_ecs_service.this[0],
  ]
}

# REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              = (var.autoscale_enabled && var.autoscale_target_value_memory > 0) ? 1 : 0
  name               = "${var.name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.autoscale_target_value_memory
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count              = (var.autoscale_enabled && var.autoscale_target_value_cpu > 0) ? 1 : 0
  name               = "${var.name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.autoscale_target_value_cpu
  }
}

resource "aws_appautoscaling_scheduled_action" "up" {
  count              = length(var.autoscale_scheduled_up)
  name               = "${var.name}-scheduled-up-autoscaling-${count.index}"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  schedule           = var.autoscale_scheduled_up[count.index]

  scalable_target_action {
    min_capacity = var.autoscaling_min_size
    max_capacity = var.autoscaling_max_size
  }

}

resource "aws_appautoscaling_scheduled_action" "down" {
  count              = length(var.autoscale_scheduled_down)
  name               = "${var.name}-scheduled-down-autoscaling-${count.index}"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  schedule           = var.autoscale_scheduled_down[count.index]

  scalable_target_action {
    min_capacity = var.min_size
    max_capacity = var.max_size
  }
}
