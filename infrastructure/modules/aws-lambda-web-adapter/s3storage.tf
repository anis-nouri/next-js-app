data "aws_canonical_user_id" "current" {}


resource "random_id" "example" {
  byte_length = 8
}

locals {
  next_logging_bucket = "${var.next_bucket_name}logs-${random_id.example.hex}"
}

resource "aws_s3_bucket" "next_bucket" {
  bucket = "${var.next_bucket_name}-${random_id.example.hex}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = local.next_logging_bucket
    target_prefix = "s3-access-logs/"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "versioning_next_bucket" {
  bucket = aws_s3_bucket.next_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "next_logging_bucket" {
  bucket = local.next_logging_bucket
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_s3_bucket_policy" "next_logging_bucket_policy" {
  bucket = aws_s3_bucket.next_logging_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:PutObject",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Resource = "${aws_s3_bucket.next_logging_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = aws_cloudfront_distribution.NextDistribution.owner_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "next_bucket_public_access" {
  bucket = aws_s3_bucket.next_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "next_logging_bucket_public_access" {
  bucket = aws_s3_bucket.next_logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
