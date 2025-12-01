resource "aws_s3_bucket" "shared_assets" {
  bucket = "${var.project_name}-${var.environment}-shared-assets"

  force_destroy = var.environment != "prod"
}

resource "aws_s3_bucket_versioning" "shared_assets" {
  bucket = aws_s3_bucket.shared_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shared_assets" {
  bucket = aws_s3_bucket.shared_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "shared_assets" {
  bucket = aws_s3_bucket.shared_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

