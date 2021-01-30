resource "aws_dynamodb_table" "profile-visitor" {
  hash_key = "IPAddress"
  name     = local.table

  attribute {
    name = "IPAddress"
    type = "S"
  }

  write_capacity = 1
  read_capacity  = 1
}
