data "archive_file" "lambda_zip" {

  type = "zip"

  source_file = "${path.module}/src/lambda_function.py"

  output_path = "${path.module}/lambda.zip"
}