variable "region" {
  description = "The AWS region where your resources will be provisioned."
  type        = string
  default     = "eu-west-1"
}

variable "next_bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
  default     = "nextbucket"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway."
  default     = "next_APIGateway"
}

variable "lambda_function_image_uri" {
  description = "URI of the Lambda function's Docker image."
  default     = "055531036085.dkr.ecr.eu-west-1.amazonaws.com/next-js-app-runner:latest"
}