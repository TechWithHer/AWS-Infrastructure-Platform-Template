output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}