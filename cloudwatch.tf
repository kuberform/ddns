resource "aws_cloudwatch_event_rule" "dynamic_dns" {
  name        = "dynamic_dns_events"
  description = "Captures instance state changes and triggers dynamic dns Lambda."

  event_pattern = "${file("${path.module}/eventfilter/instance_state.json")}"
}

resource "aws_cloudwatch_event_target" "dynamic_dns" {
  rule      = "${aws_cloudwatch_event_rule.dynamic_dns.name}"
  target_id = "sendToDyndnsLambda"
  arn       = "${aws_lambda_function.dynamic_dns.qualified_arn}"
}

resource "aws_cloudwatch_log_group" "dynamic_dns" {
  name              = "/aws/lambda/kuberform-dynamic-dns-${data.aws_region.current.name}"
  retention_in_days = 3

  tags {
    Name    = "kuberform-dynamic-dns-${data.aws_region.current.name}"
    Owner   = "infrastructure"
    Billing = "costcenter"
    Role    = "dynamic-dns"
    Package = "https://github.com/kuberform"
  }
}
