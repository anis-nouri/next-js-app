# Output the Lambda function's Invoke URL
output "nextjs_function_url" {
  description = "URL for invoking the Next.js Lambda function"
  value       = aws_lambda_function.nextjs_function.invoke_arn
}