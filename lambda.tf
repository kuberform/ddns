variable "zone_id_map" {
  type        = "string"
  description = "Map data from module.kuberform.dns_zone.region_zones."
}

data "archive_file" "dynamic_dns" {
  type        = "zip"
  source_file = "${path.module}/lambda/dyndns.py"
  output_path = "${path.module}/lambda/lambda.zip"
}

data "aws_route53_zone" "region_zone" {
  zone_id = "${var.zone_id_map[data.aws_region.current.name]}"
}

resource "aws_lambda_function" "dynamic_dns" {
  description      = "Dynamic DNS event handler for Kubernetes instances."
  filename         = "${path.module}/lambda/lambda.zip"
  source_code_hash = "${data.archive_file.dynamic_dns.output_base64sha256}"
  function_name    = "kuberform-dynamic-dns-${data.aws_region.current.name}"
  role             = "${aws_iam_role.dynamic_dns.arn}"
  handler          = "dyndns.lambda_handler"
  runtime          = "python3.6"
  publish          = true

  environment {
    variables = {
      ZONE_ID      = "${var.zone_id}"
      DYNAMO_TABLE = "${aws_dynamodb_table.dynamic_dns.id}"
      ZONE_DOMAIN  = "${data.aws_route53_zone.region_zone.name}"
    }
  }

  tags {
    Name     = "kuberform-dynamic-dns-${data.aws_region.current.name}"
    Owner    = "infrastructure"
    Billing  = "costcenter"
    Role     = "dynamic-dns"
    Zone     = "${var.zone_id}"
    Domain   = "${data.aws_route53_zone.region_zone.name}"
    Provider = "https://github.com/kuberform"
  }
}
