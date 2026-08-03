resource "aws_cloudwatch_event_rule" "daily_health_check" {

  name = "${var.project_name}-${var.environment}-daily-health"

  description = "Runs the Operations Lambda every morning."

  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {

  rule = aws_cloudwatch_event_rule.daily_health_check.name

  target_id = "OperationsLambda"

  arn = aws_lambda_function.operations.arn

}

resource "aws_lambda_permission" "allow_eventbridge" {

  statement_id = "AllowExecutionFromEventBridge"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.operations.function_name

  principal = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.daily_health_check.arn

}