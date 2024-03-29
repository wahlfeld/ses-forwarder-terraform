data "template_file" "cloudformation_sns_stack" {
  template = file("${path.module}/local/sns_topic.json")
  vars = {
    sns_display_name = var.sns_display_name
    subscription     = join(",", formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\" }", var.sns_email_address, var.sns_protocol))
  }
}

resource "aws_cloudformation_stack" "sns_topic" {
  name          = var.lambda_name
  template_body = data.template_file.cloudformation_sns_stack.rendered

  tags = {
    "Name" = var.lambda_name
  }
}
