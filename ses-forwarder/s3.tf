resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
  policy = data.template_file.bucket_policy.rendered

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "two-week-retention"
    prefix  = var.mail_s3_prefix
    enabled = true

    expiration {
      days = 14
    }
  }

  tags = merge(local.common_tags, {})
}

data "template_file" "bucket_policy" {
  template = file("${path.module}/local/bucket_policy.json")
  vars = {
    account_id  = var.account_id
    bucket_name = var.bucket_name
  }
}
