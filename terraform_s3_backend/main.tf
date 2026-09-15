terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}


provider "aws" {
    region = var.aws_region
}

resource "aws_s3_bucket" "backend_bucket" {
    bucket = lower(var.project_name)
    tags = {
        Name = var.project_name
    } 
}
resource "aws_s3_bucket_versioning" "backend_bucket_versioning" {
    bucket = aws_s3_bucket.backend_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_bucket_encryption" {
    bucket = aws_s3_bucket.backend_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "backend_bucket_public_access_block" {
    bucket = aws_s3_bucket.backend_bucket.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# Bucket Policy - TLS setup 

resource "aws_s3_bucket_policy" "backend_bucket_tls" {
  bucket = aws_s3_bucket.backend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"

        Principal = "*"

        Action = "s3:*"

        Resource = [
          aws_s3_bucket.backend_bucket.arn,
          "${aws_s3_bucket.backend_bucket.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}