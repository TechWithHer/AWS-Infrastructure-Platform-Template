locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic" "alerts" {

  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
  })
}

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "email"

  endpoint = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {

  alarm_name = "${var.project_name}-${var.environment}-high-cpu"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = var.evaluation_periods
  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = var.period
  statistic = "Average"

  threshold = var.cpu_threshold

  alarm_description = "Alarm when CPU exceeds ${var.cpu_threshold}%"

  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-cpu-alarm"
  })
}