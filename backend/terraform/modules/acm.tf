resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
  provider = var.aws_region

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  #name         = "notfound404.click" use id instead of name to avoid no match
  zone_id = var.hostzone_id
  private_zone = true
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
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
  provider = var.aws_region
}