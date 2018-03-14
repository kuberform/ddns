resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "kuberform-dynamic-dns-${data.aws_region.current.name}"
  qualifier     = "${aws_lambda_function.dynamic_dns.version}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.dynamic_dns.arn}"
}
