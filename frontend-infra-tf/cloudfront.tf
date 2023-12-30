locals {
  spa_min_ttl     = 300
  spa_default_ttl = 3600
  spa_max_ttl     = 86400
}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy
resource "aws_cloudfront_cache_policy" "spa" {
  provider    = aws.iqonda
  name        = "spa-policy"
  default_ttl = local.spa_default_ttl
  min_ttl     = local.spa_min_ttl
  max_ttl     = local.spa_max_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    query_strings_config {
      query_string_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "spa" {
  provider            = aws.iqonda
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${aws_route53_zone.spa.name} distribution"
  default_root_object = "index.html" # point to your renders index.html!

  origin {
    domain_name = aws_s3_bucket.spa.bucket_domain_name
    origin_id   = "main"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.spa.cloudfront_access_identity_path
    }
  }

  aliases = [
    aws_route53_zone.spa.name,
  ]

  default_cache_behavior {
    target_origin_id       = "main"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https" # redirect to HTTP :tada:
    cache_policy_id        = aws_cloudfront_cache_policy.spa.id
  }

  viewer_certificate {
    # here's that certificate validation resource :tada:
    acm_certificate_arn      = aws_acm_certificate_validation.spa.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # these two custom_error_response make the spa work, if we hit a URL that
  # does not exist inthe bucket, we _must_ serve the index file so routing can
  # kick in and such.
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}