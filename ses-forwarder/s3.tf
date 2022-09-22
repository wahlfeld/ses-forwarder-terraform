resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  policy = data.template_file.bucket_policy.rendered

  lifecycle {
    ignore_changes = [
      lifecycle_rule,
      server_side_encryption_configuration
    ]
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "two-week-retention"
    status = "Enabled"

    filter {
      prefix = var.mail_s3_prefix
    }

    expiration {
      days = 14
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "template_file" "bucket_policy" {
  template = file("${path.module}/local/bucket_policy.json")
  vars = {
    account_id  = var.account_id
    bucket_name = var.bucket_name
  }
}
