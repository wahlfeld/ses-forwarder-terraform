variable "account_id" {
  description = "The AWS account ID"
}
variable "region" {
  default = "us-west-2"
  description = "Must be either us-west-2, us-east-1 or eu-west-1 (where SES receiving is)"
  }
variable "bucket_name" {
  description = "The name of the S3 bucket where emails will be stored"
  }
variable "mail_s3_prefix" {
  description = "Folder prefix where emails will be stored e.g. /mail"
  }
variable "lambda_role_name" {
  description = "The name of the IAM role used by the Lambda function"
  }
variable "lambda_name" {
  description = "The name of the Lambda function"
  }
variable "lambda_recipient" {
  description = "Where the Lambda function will send/forward the sent mail to"
  }
variable "ses_mail_recipient" {
  description = "The email address that the sender used"
  }
variable "ses_rule_name" {
  description = "The name of the SES rule that invokes the Lambda function"
  }
variable "ses_set_name" {
  description = "The name of the active Rule Set in SES which you have already configured"
  }
variable "sns_display_name" {
  description = "The friendly name of the SNS topic"
  }
variable "sns_email_address" {
  description = "The email address used to send error notifications to"
  }
variable "sns_protocol" {
  default = "email"
  description = "The SNS protocol"
}
variable "cloudwatch_metric" {
  description = "The name of the metric used for detecting Lambda runtime errors"
  }
variable "cloudwatch_alarm" {
  description = "The name of the CloudWatch alarm monitoring the Lambda function"
  }