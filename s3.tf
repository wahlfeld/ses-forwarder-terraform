resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  region = var.region
  acl    = "private"
  policy = data.template_file.bucket_policy.rendered
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "template_file" "bucket_policy" {
  template = file("${path.module}/resources/bucket_policy.json")
  vars = {
    account_id  = var.account_id
    bucket_name = var.bucket_name
  }
}