# The policy document to access the role
#data "aws_iam_policy_document" "dynamodb_table_policy_example" {
#  provider   = aws.usergroup
#  depends_on = [aws_dynamodb_table.example]
#  statement {
#    sid = "dynamodbtablepolicy"
#
#    actions = [
#      "dynamodb:Query"
#    ]
#
#    resources = [
#      aws_dynamodb_table.example.arn,
#    ]
#  }
#}
#
## The IAM Role for the execution
#resource "aws_iam_role" "api_gateway_dynamodb_example" {
#  provider           = aws.usergroup
#  name               = "api_gateway_dynamodb_example"
#  assume_role_policy = <<-EOF
#  {
#    "Version": "2012-10-17",
#    "Statement": [
#      {
#        "Action": "sts:AssumeRole",
#        "Principal": {
#          "Service": "apigateway.amazonaws.com"
#        },
#        "Effect": "Allow",
#        "Sid": "iamroletrustpolicy"
#      }
#    ]
#  }
#  EOF
#}

#resource "aws_iam_role_policy" "example_policy" {
#  provider = aws.usergroup
#  name     = "example_policy"
#  role     = aws_iam_role.api_gateway_dynamodb_example.id
#  policy   = data.aws_iam_policy_document.dynamodb_table_policy_example.json
#}