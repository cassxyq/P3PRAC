# Setup the s3 bucket for static website hosting
resource "aws_s3_bucket" "hosting_bucket" {
  bucket = var.subdomain_name
  acl    = "public-read"
  
  object_lock_enabled = false

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Setup s3 bucket for redirecting root to subdomain
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.domain_name
  acl    = "public-read"
  policy = file("${env.WORKSPACE}/frontend/frontend/modules/s3-policy.json")

  website {
    redirect_all_requests_to = "https://${var.subdomain_name}"
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

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.hosting_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.hosting-oai.iam_arn]
    }
  }
}

/*data "aws_iam_policy_document" "s3root_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.root_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.hosting-oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "root" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = data.aws_iam_policy_document.s3root_policy.json
}*/

resource "aws_s3_bucket_policy" "hosting" {
  bucket = aws_s3_bucket.hosting_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}


