terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wahlfeldterraform"
    key    = "ses-forwarder"
    region = "ap-southeast-2"
  }
}