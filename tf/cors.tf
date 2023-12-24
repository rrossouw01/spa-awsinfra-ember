resource "aws_s3_bucket_cors_configuration" "spa" {
provider            = aws.iqonda
  bucket = aws_s3_bucket.spa.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = [
      "https://spa-app.ls-al.com"
    ]
    expose_headers = [
      "Content-Length",
      "Content-Type",
      "Connection",
      "Date",
      "ETag",
      "x-amz-request-id",
      "x-amz-version-id",
      "x-amz-id-2",
    ]
    max_age_seconds = 3600
  }
}

resource "aws_cloudfront_cache_policy" "spa-with-cors" {
provider            = aws.iqonda
name        = "spa-cors-policy"
  default_ttl = local.spa_default_ttl
  min_ttl     = local.spa_min_ttl
  max_ttl     = local.spa_max_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "origin",
          "access-control-request-headers",
          "access-control-request-method"
        ]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "none"
    }
  }
}