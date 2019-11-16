resource "aws_ses_receipt_rule" "dev_rule" {
  depends_on = [
    aws_s3_bucket.bucket,
    aws_lambda_function.ses_forwarder,
    aws_lambda_permission.allow_ses
  ]
  name          = "${var.ses_rule_name}"
  rule_set_name = "${var.ses_set_name}"
  recipients    = ["${var.ses_mail_recipient}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = "${var.bucket_name}"
    object_key_prefix = "${var.mail_s3_prefix}"
    position          = 1
  }

  lambda_action {
    function_arn    = aws_lambda_function.ses_forwarder.arn
    invocation_type = "Event"
    position        = 2

  }
}