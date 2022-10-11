# cloudfront OAI
resource "aws_cloudfront_origin_access_identity" "hosting-oai" {
  comment = "OAI for hosting bucket"
}


# cloudfront distribution for hosting s3
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.hosting-bucket.bucket_regional_domain_name
    origin_id   = var.subdomain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.hosting-oai.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = [var.subdomain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.subdomain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_ALL"

  restrictions {
    geo_restriction {
        restriction_type = "none"
    }
  }

  tags = {
    Environment = var.prefix
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method = "sni-only"
  } 
}

# cloudfront distribution for redirect to hosting 
resource "aws_cloudfront_distribution" "root_s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.root_bucket.bucket_regional_domain_name
        origin_name = var.domain_name
    }

    enabled = true
    is_ipv6_enabled = true

    alias = [var.domain_name]

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = var.domain_name
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
        ssl_support_method = "sni-only"
    }
}




/*data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.hosting-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.hosting-oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.hosting-bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}*/