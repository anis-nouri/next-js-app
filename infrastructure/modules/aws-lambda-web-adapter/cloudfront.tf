locals {
  lambda_origin_id = "nextAPIGatewayOrigin"
  s3_origin_id     = "nextS3Origin"
}

resource "aws_cloudfront_origin_access_identity" "next_origin_access_identity" {
  comment = "OAI for Next static resources in S3 bucket"
}

resource "aws_cloudfront_distribution" "NextDistribution" {
  origin {
    domain_name = "${aws_apigatewayv2_api.main.id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = local.lambda_origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.next_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.next_origin_access_identity.cloudfront_access_identity_path
    }
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

  ordered_cache_behavior {
    path_pattern           = "/_next/static/*"
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "https-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  logging_config {
    bucket          = aws_s3_bucket.next_logging_bucket.bucket_regional_domain_name
    include_cookies = false
    prefix          = "cloudfront-access-logs"
  }
}
