output "backend_bucket_arn" {
  value = aws_s3_bucket.backend_bucket.arn
}

output "backend_bucket_name" {
  value = aws_s3_bucket.backend_bucket.bucket
}

output "backend_bucket_region" {
  value = var.aws_region
}