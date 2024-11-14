resource "aws_dynamodb_table" "ResultsTable" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "S3Key"
  range_key      = "AttrType"
  
  attribute {
    name = "S3Key"
    type = "S"
  }

  attribute {
    name = "AttrType"
    type = "S"
  }

  attribute {
    name = "JobId"
    type = "S"
  }

  local_secondary_index {
    name            = "JobIdIndex"
    projection_type = "INCLUDE"
    non_key_attributes = ["analysis"]
    range_key       = "JobId"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    cost = "aws-ee"
  }
}
