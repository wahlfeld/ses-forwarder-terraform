terraform {
  required_version = "~> 0.13.0"

  # backend "s3" {
  #   bucket = "terraform-backend"
  #   key    = "ses-forwarder/mailbox-example"
  #   region = "us-west-2"
  # }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
