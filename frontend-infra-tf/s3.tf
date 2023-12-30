resource "aws_s3_bucket" "spa" {
  provider = aws.iqonda
  bucket   = "poc-spa-app"
  #acl      = "private"
}

resource "aws_cloudfront_origin_access_identity" "spa" {
  provider = aws.iqonda
  comment  = "poc spa identity"
}

data "aws_iam_policy_document" "spa" {
  provider = aws.iqonda
  # allow the origin access identity to get objects
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.spa.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.spa.iam_arn]
    }
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.spa.arn,
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.spa.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "spa" {
  provider = aws.iqonda
  bucket   = aws_s3_bucket.spa.bucket
  policy   = data.aws_iam_policy_document.spa.json
}