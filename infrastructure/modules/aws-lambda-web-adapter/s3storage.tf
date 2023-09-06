data "aws_canonical_user_id" "current" {}


resource "random_id" "example" {
  byte_length = 8
}

locals {
  next_logging_bucket = "${var.next_bucket_name}logs-${random_id.example.hex}"
  next_bucket         = "${var.next_bucket_name}-${random_id.example.hex}"
}

resource "aws_s3_bucket" "next_bucket" {
  bucket = local.next_bucket
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


resource "aws_s3_bucket_ownership_controls" "next_logging_bucket_ownership_controls" {
  bucket = aws_s3_bucket.next_logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "next_logging_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.next_logging_bucket_ownership_controls]

  bucket = aws_s3_bucket.next_logging_bucket.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "WRITE"
    }
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "READ"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}


resource "aws_s3_bucket_public_access_block" "next_bucket_public_access" {
  bucket = aws_s3_bucket.next_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "next_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.next_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.next_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "next_bucket_policy" {
  bucket = aws_s3_bucket.next_bucket.id
  policy = data.aws_iam_policy_document.next_bucket_policy_document.json
}
