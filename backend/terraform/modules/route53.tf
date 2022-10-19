data "aws_route53_zone" "selected" {
  #name         = "notfound404.click" use id instead of name to avoid no match
  zone_id = var.hostzone_id
  private_zone = true
}

resource "aws_route53_record" "listener" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "albtest.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}