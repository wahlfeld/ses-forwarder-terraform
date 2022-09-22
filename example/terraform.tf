terraform {
  # backend "s3" {
  #   bucket = "terraform-backend"
  #   key    = "ses-forwarder/mailbox-example"
  #   region = "us-west-2"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
