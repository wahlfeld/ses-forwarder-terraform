account_id         = "123456789012"
region             = "us-west-2"
bucket_name        = "ses-forwarder"
mail_s3_prefix     = "path/"
lambda_role_name   = "ses-forwarder-lambda"
lambda_name        = "ses-forwarder"
lambda_recipient   = "user@email.com"
ses_mail_recipient = "user@email.com"
ses_rule_name      = "rule_name"
ses_set_name       = "rule_set_name"
sns_display_name   = "First Last"
sns_email_address  = "user@email.com"
cloudwatch_metric  = "ses-forwarder-error"
cloudwatch_alarm   = "ses-forwarder-alarm"
