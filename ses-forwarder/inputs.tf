variable "account_id" {
  type = string
}

variable "region" {
  type    = string
}

variable "bucket_name" {
  type = string
}

variable "mail_s3_prefix" {
  type = string
}

variable "lambda_role_name" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_recipient" {
  type = string
}

variable "ses_mail_recipient" {
  type = string
}

variable "ses_rule_name" {
  type = string
}

variable "ses_set_name" {
  type = string
}

variable "sns_display_name" {
  type = string
}

variable "sns_email_address" {
  type = string
}

variable "sns_protocol" {
  type    = string
  default = "email"
}

variable "cloudwatch_metric" {
  type = string
}

variable "cloudwatch_alarm" {
  type = string
}
