resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.nextjs_function.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "function_logging_policy" {
  name = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}


resource "aws_lambda_function" "nextjs_function" {
  function_name = "next-js-website"
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"
  image_uri     = var.lambda_function_image_uri
  runtime       = "nodejs16.x"
  architectures = ["x86_64"]
  memory_size   = 512
  timeout       = 10
  tags = {
    CreatedBy = "anis.nouri"
  }

}
resource "aws_lambda_function_url" "nextjs_function_url" {
  function_name      = aws_lambda_function.nextjs_function.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nextjs_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/{proxy+}"
}
