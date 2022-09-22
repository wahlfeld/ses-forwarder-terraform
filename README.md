# SES Forwarder Terraform

### Lambda function source: https://github.com/arithmetric/aws-lambda-ses-forwarder

## Architecture

![alt text](images/architecture.png)

Source: https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/

![alt text](images/architecture2.png)

Source: https://medium.com/@ashan.fernando/forwarding-emails-to-your-inbox-using-amazon-ses-2d261d60e417

## Prerequisites

* You have a domain in AWS
* You have a verified your domain in AWS SES (including DKIM)
* If you have not configured inbound email handling, create a new Rule Set. Otherwise, you can use an existing one.
* You have configured the DNS MX record for your domain to point to the email receiving SES endpoint e.g. `inbound-smtp.us-west-2.amazonaws.com`
* Know what Terraform is
* Know what all the components are in the diagrams above (ish)

## How to Use

1. Create a Terraform backend S3 bucket to store your state files
2. Copy and paste the `example` folder somewhere on your computer
3. Configure `backend.tf` to point at the S3 bucket you just created
4. Configure `terraform.tfvars` as per the input descriptions in `inputs.tf`
5. Run `terraform init && terraform apply`

* The steps above will set up a serverless mailbox for one email. You can copy and paste the example folder and repeat the steps to create multiple mailboxes (make sure your change the Terraform backend key).
* The `sns_email_address` variable is the email where error notifications will be sent to, so if you're administering several mailboxes you would keep this address the same for each one.
* You will need to confirm SNS subscription notifications will work.

## Tests

Currently using `terraform validate` + [terraform-compliance](https://github.com/eerkunt/terraform-compliance):
```
./test/test.sh
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket where emails will be stored | `string` | n/a | yes |
| <a name="input_cloudwatch_alarm"></a> [cloudwatch\_alarm](#input\_cloudwatch\_alarm) | The name of the CloudWatch alarm monitoring the Lambda function | `string` | n/a | yes |
| <a name="input_cloudwatch_metric"></a> [cloudwatch\_metric](#input\_cloudwatch\_metric) | The name of the metric used for detecting Lambda runtime errors | `string` | n/a | yes |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | The name of the Lambda function | `string` | n/a | yes |
| <a name="input_lambda_recipient"></a> [lambda\_recipient](#input\_lambda\_recipient) | Where the Lambda function will send/forward the sent mail to | `string` | n/a | yes |
| <a name="input_lambda_role_name"></a> [lambda\_role\_name](#input\_lambda\_role\_name) | The name of the IAM role used by the Lambda function | `string` | n/a | yes |
| <a name="input_mail_s3_prefix"></a> [mail\_s3\_prefix](#input\_mail\_s3\_prefix) | Folder prefix where emails will be stored e.g. /mail | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Must be either us-west-2, us-east-1 or eu-west-1 (where SES receiving is) | `string` | `"us-west-2"` | no |
| <a name="input_ses_mail_recipient"></a> [ses\_mail\_recipient](#input\_ses\_mail\_recipient) | The email address that the sender used | `string` | n/a | yes |
| <a name="input_ses_rule_name"></a> [ses\_rule\_name](#input\_ses\_rule\_name) | The name of the SES rule that invokes the Lambda function | `string` | n/a | yes |
| <a name="input_ses_set_name"></a> [ses\_set\_name](#input\_ses\_set\_name) | The name of the active Rule Set in SES which you have already configured | `string` | n/a | yes |
| <a name="input_sns_display_name"></a> [sns\_display\_name](#input\_sns\_display\_name) | The friendly name of the SNS topic | `string` | n/a | yes |
| <a name="input_sns_email_address"></a> [sns\_email\_address](#input\_sns\_email\_address) | The email address used to send error notifications to | `string` | n/a | yes |
| <a name="input_sns_protocol"></a> [sns\_protocol](#input\_sns\_protocol) | The SNS protocol | `string` | `"email"` | no |
<!-- END_TF_DOCS -->

## Limitations

* SES only allows receiving email sent to addresses within verified domains: http://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domains.html

* SES only allows sending emails up to 10 MB in size (including attachments after encoding): https://docs.aws.amazon.com/ses/latest/DeveloperGuide/limits.html

* Initially SES users are in a sandbox environment that has a number of limitations: http://docs.aws.amazon.com/ses/latest/DeveloperGuide/limits.html

Source: https://github.com/arithmetric/aws-lambda-ses-forwarder

## Other Documentation

* https://github.com/arithmetric/aws-lambda-ses-forwarder
* https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/
* https://medium.com/@ashan.fernando/forwarding-emails-to-your-inbox-using-amazon-ses-2d261d60e417
* https://github.com/cloudposse/terraform-aws-ses-lambda-forwarder
