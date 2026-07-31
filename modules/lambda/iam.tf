data "aws_iam_policy_document" "assume_role" {

  statement {

    actions = [
      "sts:AssumeRole"
    ]

    principals {

      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]

    }

  }

}

resource "aws_iam_role" "lambda" {

  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

}

resource "aws_iam_role_policy_attachment" "logs" {

  role = aws_iam_role.lambda.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}

data "aws_iam_policy_document" "ec2_read" {

  statement {

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = ["*"]

  }

}
resource "aws_iam_policy" "ec2_read" {

  name   = "${var.project_name}-${var.environment}-ec2-read"

  policy = data.aws_iam_policy_document.ec2_read.json
}

resource "aws_iam_role_policy_attachment" "ec2_read" {

  role       = aws_iam_role.lambda.name

  policy_arn = aws_iam_policy.ec2_read.arn
}