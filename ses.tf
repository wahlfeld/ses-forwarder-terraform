data "template_file" "cloudformation_sns_stack" {
  template = "${file(".terraform/modules/ses-forwarder-dev/resources/sns_topic.json")}"
  vars = {
    sns_display_name = "${var.sns_display_name}"
    subscription     = "${join(",", formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }", var.sns_email_address, var.sns_protocol))}"
  }
}
resource "aws_cloudformation_stack" "sns_topic" {
  name          = "${var.lambda_name}"
  template_body = "${data.template_file.cloudformation_sns_stack.rendered}"
  tags = "${merge(
    map("Name", "${var.lambda_name}")
  )}"
}

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