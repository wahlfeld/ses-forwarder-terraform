# SES Forwarder Terraform

### Lambda function source: https://github.com/arithmetric/aws-lambda-ses-forwarder

## Architecture

![alt text](images/architecture.png)

Source: https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/

![alt text](images/architecture2.png)

Source: https://medium.com/@ashan.fernando/forwarding-emails-to-your-inbox-using-amazon-ses-2d261d60e417

## Prerequisites

* You have a domain in AWS
* You have a validated your domain in AWS SES
* If you have not configured inbound email handling, create a new Rule Set. Otherwise, you can use an existing one.
* You have configured the DNS MX record for your domain to point to the email receiving SES endpoint e.g. `inbound-smtp.us-west-2.amazonaws.com`
* Know what Terraform is
* Know what all the components are in the diagrams above (ish)

## How to Use

1. Create a Terraform backend S3 bucket to store your state files
2. Copy and paste the `example` folder somewhere on your computer
3. Configure `backend.tf` to point at the S3 bucket you just created
4. Configure `terraform.tfvars` as per the variable descriptions in `variables.tf`
5.  Run `terraform init && terraform apply`

* The steps above will set up a serverless mailbox for one email. You can copy and paste the example folder and repeat the steps to create multiple mailboxes (make sure your change the Terraform backend key).
* The `sns_email_address` variable is the email where error notifications will be sent to, so if you're administering several mailboxes you would keep this address the same for each one.

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
