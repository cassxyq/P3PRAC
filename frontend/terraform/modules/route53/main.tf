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