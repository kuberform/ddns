resource "aws_dynamodb_table" "dynamic_dns" {
  name           = "kuberform-dynamic-dns-table-${data.aws_region.current.name}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags {
    Name     = "kuberform-dynamic-dns-table-${data.aws_region.current.name}"
    Owner    = "infrastructure"
    Billing  = "costcenter"
    Role     = "dynamic-dns"
    Provider = "https://github.com/kuberform"
  }
}
