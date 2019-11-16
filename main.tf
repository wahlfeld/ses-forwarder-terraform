provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  region = "${var.region}"
  acl    = "private"
  policy = "${data.template_file.bucket_policy.rendered}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "template_file" "bucket_policy" {
  template = "${file("bucket_policy.json")}"
  vars = {
    account_id  = "${var.account_id}"
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${var.lambda_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy" {
  name   = "${var.lambda_role_name}"
  policy = "${data.template_file.iam_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "iam_policy_attachment" {
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.iam_policy
  ]
  role       = "${aws_iam_role.lambda_iam_role.name}"
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
}

data "template_file" "iam_policy" {
  template = "${file("iam_policy.json")}"
  vars = {
    account_id       = "${var.account_id}"
    region           = "${var.region}"
    bucket_name      = "${var.bucket_name}"
    lambda_role_name = "${var.lambda_role_name}"
  }
}

resource "aws_lambda_function" "ses_forwarder" {
  depends_on       = [aws_iam_role.lambda_iam_role]
  filename         = "lambda.zip"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.lambda_iam_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${filebase64sha256("lambda.zip")}"
  runtime          = "nodejs10.x"
  timeout          = 30

  environment {
    variables = {
      bucket_name        = "${var.bucket_name}",
      mail_s3_prefix     = "${var.mail_s3_prefix}",
      ses_mail_recipient = "${var.ses_mail_recipient}",
      lambda_recipient   = "${var.lambda_recipient}",
      region             = "${var.region}"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id   = "GiveSESPermissionToInvokeFunction"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.ses_forwarder.function_name}"
  principal      = "ses.amazonaws.com"
  source_account = "${var.account_id}"
}

data "template_file" "cloudformation_sns_stack" {
  template = "${file("sns_topic.json")}"
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

  add_header_action {
    header_name  = "Custom-Header"
    header_value = "Added by SES"
    position     = 1
  }

  s3_action {
    bucket_name       = "${var.bucket_name}"
    object_key_prefix = "${var.mail_s3_prefix}"
    position          = 2
  }

  lambda_action {
    function_arn    = aws_lambda_function.ses_forwarder.arn
    invocation_type = "Event"
    position        = 3

  }
}

resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  name           = "${var.cloudwatch_metric}"
  pattern        = "error"
  log_group_name = "${aws_cloudwatch_log_group.lambda_log_group.name}"

  metric_transformation {
    name      = "${var.cloudwatch_metric}"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ses-forwarder-alarm" {
  depends_on          = [aws_cloudformation_stack.sns_topic]
  alarm_name          = "ses-forwarder-alarm-dev"
  alarm_description   = "Alarm for when errors occur in ses-forwarder function."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "${aws_cloudwatch_log_metric_filter.lambda_metric_filter.name}"
  namespace           = "LogMetrics"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"]
}