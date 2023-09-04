/*locals {
  lambda_origin_id = "nextLambdaOrigin"
}

resource "aws_cloudfront_distribution" "NextDistribution" {
  origin {
    domain_name = aws_lambda_function_url.nextjs_function_url.function_url
    origin_id   = local.lambda_origin_id
  }
  enabled             = true
  comment             = "Next.js Distribution"
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.lambda_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

*/
