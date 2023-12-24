resource "aws_route53_zone" "spa" {
  provider = aws.iqonda
  name     = "spa-app.ls-al.com" # CHANGEME
}

resource "aws_acm_certificate" "spa" {
  provider          = aws.iqonda
  domain_name       = aws_route53_zone.spa.name # app.example.com or whatever
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${aws_route53_zone.spa.name}",
  ]

  # in case we need to recreate, make a new one first
  # then remove the old
  lifecycle {
    create_before_destroy = true
  }
}

# dynamically set up the validation records so acm
# can verify we own the domain
resource "aws_route53_record" "spa-certificate" {
  provider = aws.iqonda
  for_each = {
    for dvo in aws_acm_certificate.spa.domain_validation_options : dvo.domain_name => {
      domain = dvo.domain_name
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  ttl             = 600
  zone_id         = aws_route53_zone.spa.zone_id
  records         = [each.value.record]

  lifecycle {
    create_before_destroy = true
  }
}

# this will "wait" for the cert to be come valid on creation
# so we don't spin up resources with pending certs
resource "aws_acm_certificate_validation" "spa" {
  provider                = aws.iqonda
  certificate_arn         = aws_acm_certificate.spa.arn
  validation_record_fqdns = [for record in aws_route53_record.spa-certificate : record.fqdn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "spa" {
  provider = aws.iqonda
  zone_id  = aws_route53_zone.spa.zone_id
  name     = aws_route53_zone.spa.name
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.spa.domain_name
    zone_id                = aws_cloudfront_distribution.spa.hosted_zone_id
    evaluate_target_health = false
  }
}