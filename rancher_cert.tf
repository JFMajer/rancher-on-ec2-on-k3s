data "aws_route53_zone" "rancher" {
  name         = "rancher.heheszlo.com"
  private_zone = false
}

resource "aws_acm_certificate" "rancher_server" {
  domain_name       = var.rancher_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_verification_record" {
  for_each = {
    for dvo in aws_acm_certificate.rancher_server.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.rancher.zone_id
}

resource "aws_acm_certificate_validation" "rancher_cert_validation" {
  certificate_arn         = aws_acm_certificate.rancher_server.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_verification_record : record.fqdn]
}

resource "aws_route53_record" "rancher" {
  zone_id = data.aws_route53_zone.rancher.zone_id
  name    = "rancher.heheszlo.com"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}