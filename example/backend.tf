terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "terraform-backend"
    key    = "ses-forwarder/mailbox"
    region = "us-west-2"
  }
}