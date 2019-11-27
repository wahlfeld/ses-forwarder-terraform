provider "aws" {
  region = "${var.region}"
}

module "ses-forwarder-dev" {
  source = "github.com/wahlfeld/ses-forwarder-terraform.git//?ref=master"

  account_id         = "${var.account_id}"
  region             = "${var.region}"
  bucket_name        = "${var.bucket_name}"
  lambda_role_name   = "${var.lambda_role_name}"
  lambda_name        = "${var.lambda_name}"
  lambda_recipient   = "${var.lambda_recipient}"
  mail_s3_prefix     = "${var.mail_s3_prefix}"
  ses_mail_recipient = "${var.ses_mail_recipient}"
  ses_rule_name      = "${var.ses_rule_name}"
  ses_set_name       = "${var.ses_set_name}"
  sns_display_name   = "${var.sns_display_name}"
  sns_email_address  = "${var.sns_email_address}"
  cloudwatch_metric  = "${var.cloudwatch_metric}"
  cloudwatch_alarm   = "${var.cloudwatch_alarm}"
}