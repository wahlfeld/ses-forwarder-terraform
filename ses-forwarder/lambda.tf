resource "aws_iam_role" "lambda_iam_role" {
  name               = var.lambda_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(local.common_tags, {})
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.lambda_role_name
  policy = data.template_file.iam_policy.rendered
}

resource "aws_iam_role_policy_attachment" "iam_policy_attachment" {
  depends_on = [
    aws_iam_role.lambda_iam_role,
    aws_iam_policy.iam_policy
  ]

  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

data "template_file" "iam_policy" {
  template = file("${path.module}/local/iam_policy.json")
  vars = {
    account_id       = var.account_id
    region           = var.region
    bucket_name      = var.bucket_name
    lambda_role_name = var.lambda_role_name
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/local/index.js"
  output_path = "${path.module}/local/lambda.zip"
}

resource "aws_lambda_function" "ses_forwarder" {
  depends_on       = [aws_iam_role.lambda_iam_role]
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs10.x"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      bucket_name        = var.bucket_name,
      mail_s3_prefix     = var.mail_s3_prefix,
      ses_mail_recipient = var.ses_mail_recipient,
      lambda_recipient   = var.lambda_recipient,
      region             = var.region
    }
  }

  tags = merge(local.common_tags, {})
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14

  tags = merge(local.common_tags, {})
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id   = "GiveSESPermissionToInvokeFunction"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.ses_forwarder.function_name
  principal      = "ses.amazonaws.com"
  source_account = var.account_id
}
