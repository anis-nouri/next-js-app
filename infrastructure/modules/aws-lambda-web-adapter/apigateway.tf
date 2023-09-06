resource "aws_apigatewayv2_api" "main" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main_api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name              = "/aws/api-gw/${aws_apigatewayv2_api.main.name}"
  retention_in_days = 30
}


resource "aws_apigatewayv2_integration" "lambda_handler" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.nextjs_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_handler.id}"
}
