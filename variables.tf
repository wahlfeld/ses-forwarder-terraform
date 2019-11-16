variable "account_id" {}
variable "region" {}
variable "bucket_name" {}
variable "lambda_role_name" {}
variable "lambda_name" {}
variable "mail_s3_prefix" {}
variable "lambda_recipient" {}
variable "ses_mail_recipient" {}
variable "ses_rule_name" {}
variable "ses_set_name" {}
variable "sns_display_name" {}
variable "sns_email_address" {}
variable "sns_protocol" {
  default = "email"
}
variable "cloudwatch_metric" {}
variable "cloudwatch_alarm" {}