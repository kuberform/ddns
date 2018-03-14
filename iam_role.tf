resource "aws_iam_role" "dynamic_dns" {
  name        = "kuberform-dyndns-${data.aws_region.current.name}-role"
  path        = "/kubernetes/"
  description = "Allows for Lambda to access required resources for dynamic dns."

  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.lambda_role.json}"
}

resource "aws_iam_role_policy" "dynamic_dns" {
  name   = "kuberform-dynamic-dns-policy"
  role   = "${aws_iam_role.dynamic_dns.id}"
  policy = "${data.aws_iam_policy_document.dynamic_dns.json}"
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dynamic_dns" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = ["logs:CreateLogGroup"]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = ["*"]

    resources = [
      "${aws_cloudwatch_log_group.dynamic_dns.arn}",
      "${aws_cloudwatch_log_group.dynamic_dns.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]

    resources = ["${aws_dynamodb_table.dynamic_dns.arn}"]
  }

  statement {
    effect = "Allow"

    actions = ["route53:ChangeResourceRecordSets"]

    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }
}
