# Setup the s3 bucket for static website hosting
resource "aws_s3_bucket" "hosting_bucket" {
    bucket = var.subdomain_name
    acl = "private"
    policy = file("../s3-policy.json", {bucket = var.subdomain_name})
    
    website {
      index_document = "index.html"
      error_document = "error.html"
    }

    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://${var.subdomain_name}"]
      max_age_seconds = 3000
    }
}

# Setup s3 bucket for redirecting root to subdomain
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.domain_name
  acl = "private"
  policy = file("../s3-policy.json", {bucket = var.domain_name})

  website {
    redirect_all_requests_to = "https://${var.subdomain}"
  }
}

# bloc public access
resource "aws_s3_bucket_public_access_block" "subdomain" {
  bucket = aws_s3_bucket.hosting_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "domain" {
  bucket = aws_s3_bucket.root_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
