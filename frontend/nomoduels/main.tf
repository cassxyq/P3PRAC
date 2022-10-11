terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}


# Setup the s3 bucket
resource "aws_s3_bucket" "hosting-bucket" {
    bucket = var.hosting_domain
    tags = {
        Name = var.s3tag_name
        Environment = var.prefix
    }
}

resource "aws_s3_bucket_acl" "hosting-bucket-acl" {
    bucket = aws_s3_bucket.hosting-bucket.id
    acl    = "private"
}

resource "aws_s3_bucket" "root_bucket" {
    bucket = var.hostzone_name
    acl = "private"
    tags = {
        Name = var.s3tag_name
        Environment = var.prefix
    }

    website {
    redirect_all_requests_to = "https://${var.hosting_domain}"
  }
}

# Using versioning
/*resource "aws_s3_bucket" "hosting-bucket-version" {
  bucket = var.hosting_domain
  acl    = "private"

  versioning {
    enabled = true
  }
}*/

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.hosting-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# configure hosing static websites
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.hosting-bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

/* routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }*/ 
} 


# cloudfront OAI
resource "aws_cloudfront_origin_access_identity" "hosting-oai" {
  comment = "OAI for hosting bucket"
}


# cloudfront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.hosting-bucket.bucket_regional_domain_name
    origin_id   = var.hosting_domain
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.hosting-oai.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = [var.hosting_domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.hosting_domain
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

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction{
        restriction_type = "none"
    }
  }

  tags = {
    Environment = var.prefix
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    ssl_support_method = "sni-only"
  } 

}

/*resource "aws_cloudfront_distribution" "root_s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.root_bucket.bucket_regional_domain_name
        origin_name = var.hostzone_name
    }

    enabled = true
    is_ipv6_enabled = true

    alias = [var.hostzone_name]

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = var.hostzone_name
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
        acm_certificate_arn = data.aws_acm_certificate.issued.arn
        ssl_support_method = "sni-only"
    }

}*/

data "aws_acm_certificate" "issued" {
  domain = "notfound404.click"
  statuses = ["ISSUED"]
  provider = aws.us-east-1
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

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.hosting-bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}



data "aws_route53_zone" "selected" {
    name = var.hostzone_name
    private_zone = false
}

resource "aws_route53_record" "test" {
    zone_id = data.aws_route53_zone.selected.zone_id
    name = "test.notfound404.click"
    type = "A"
    
    alias {
        name = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
        evaluate_target_health = false
    }

}