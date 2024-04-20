resource "aws_s3_bucket" "my_site_bucket" {
  bucket = var.domainName
  acl    = "private"
  tags = {
    Environment        = var.SiteTags
  }
}

resource "aws_s3_bucket_ownership_controls" "my_site_bucket" {
  bucket = aws_s3_bucket.my_site_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my_site_bucket" {
  bucket = aws_s3_bucket.my_site_bucket.id

  block_public_acls         = false
  block_public_policy       = false
  restrict_public_buckets   = false
  ignore_public_acls        = false
}

resource "aws_s3_bucket_acl" "my_site_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my_site_bucket,
    aws_s3_bucket_public_access_block.my_site_bucket,
  ]

   bucket = aws_s3_bucket.my_site_bucket.id
  acl    = "public-read"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.my_site_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

data "aws_caller_identity" "current" {
}


resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.my_site_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}