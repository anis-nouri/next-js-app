output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.my_lambda_module.cloudfront_domain_name
}
