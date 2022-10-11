terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "notfound404.click-tfbackend"
    key = "test/terraform.tfstate"
    region = "ap-southeast-2"
  }
}


provider "aws" {
  region = "ap-southeast-2"
}

# Setup the s3 bucket for static website hosting
resource "aws_s3_bucket" "hosting_bucket" {
    bucket = var.subdomain_name
    acl = "private"
    policy = templatefile("../s3-policy.json", {bucket = "${var.subdomain_name}"})
    
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
  policy = templatefile("../s3-policy.json", {bucket = "${var.domain_name}"})

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

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
  provider = aws.us-east-1

  lifecycle {
    create_before_destroy = true
  }
}

/*data "aws_route_53" "hostzone" {
    name = var.domain_name
    private_zone = false
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}*/

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.domain : record.fqdn]
  provider = aws.us-east-1
}

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

data "aws_route53_zone" "selected" {
    name = var.domain_name
    private_zone = true
}

resource "aws_route53_record" "domain" {
    zone_id = aws_route53_zone.selected.zone_id
    name = var.domain_name
    type = "A"
    
    alias {
        name = aws_cloudfront_distribution.root_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "subdomain" {
    zone_id = aws_route53_zone.selected.zone_id
    name = var.subdomain_name
    type = "A"
    
    alias {
        name = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}