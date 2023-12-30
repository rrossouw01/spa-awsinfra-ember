#data "aws_dynamodb_table" "history" {
#  name = "upmon-history"
#}

# Create dynamo db table
resource "aws_dynamodb_table" "table01" {
  #provider     = aws.usergroup
  name         = "poc_spa_awsinfra"
  hash_key     = "id"
  range_key    = "type"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "type"
    type = "S"
  }
}

#❯❯ aws dynamodb batch-write-item --request-items file://rentals-ddb.json
#{
#    "UnprocessedItems": {}
#}
