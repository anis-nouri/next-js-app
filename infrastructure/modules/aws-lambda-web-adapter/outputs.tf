# Output the Lambda function's Invoke URL
output "nextjs_function_url" {
  description = "URL for invoking the Next.js Lambda function"
  value       = aws_lambda_function_url.nextjs_function_url.function_url
}


output "api_gateway_url" {
  description = "URL of the AWS API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.NextDistribution.domain_name
}

output "next_bucket_name" {
  value       = aws_s3_bucket.next_bucket.bucket
  description = "The name of the next S3 bucket"
}

output "next_logging_bucket_name" {
  value       = aws_s3_bucket.next_logging_bucket.bucket
  description = "The name of the example logging S3 bucket"
}
