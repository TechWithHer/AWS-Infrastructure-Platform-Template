resource "aws_lambda_function" "operations" {

  function_name = "${var.project_name}-${var.environment}-operations"

  role = aws_iam_role.lambda.arn

  runtime = "python3.12"

  handler = "lambda_function.lambda_handler"

  filename = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 30

  memory_size = 256

  environment {

    variables = {

      PROJECT_NAME = var.project_name

      ENVIRONMENT = var.environment
    }

  }

  depends_on = [
    aws_iam_role_policy_attachment.logs
  ]
}