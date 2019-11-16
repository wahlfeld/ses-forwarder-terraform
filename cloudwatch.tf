resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  name           = "${var.cloudwatch_metric}"
  pattern        = "error"
  log_group_name = "${aws_cloudwatch_log_group.lambda_log_group.name}"

  metric_transformation {
    name      = "${var.cloudwatch_metric}"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ses-forwarder-alarm" {
  depends_on          = [aws_cloudformation_stack.sns_topic]
  alarm_name          = "${var.cloudwatch_alarm}"
  alarm_description   = "Alarm for when errors occur in ses-forwarder function."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "${aws_cloudwatch_log_metric_filter.lambda_metric_filter.name}"
  namespace           = "LogMetrics"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"]
}