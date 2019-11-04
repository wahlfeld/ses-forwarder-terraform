variable "account_id" {}
variable "region" {}
variable "bucket_name" {}
variable "lambda_role_name" {}
variable "lambda_name" {}
variable "mail_s3_prefix" {}
variable "mail_sender" {}
variable "mail_recipient" {}
variable "sns_display_name" {}
variable "sns_email_address" {}
variable "sns_protocol" {
    default = "email"
}
variable "sns_stack_name" {}