resource "aws_dynamodb_table" "shared_config" {
  name         = "${var.project_name}-${var.environment}-shared-config"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  ttl {
    attribute_name = "ExpirationTime"
    enabled        = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-shared-config"
  }
}

