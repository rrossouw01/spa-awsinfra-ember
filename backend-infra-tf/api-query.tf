# Create a resource
resource "aws_api_gateway_resource" "query" {
  #  provider    = aws.usergroup
  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  parent_id   = aws_api_gateway_rest_api.spaApi.root_resource_id
  path_part   = "{query}"
}
## Create a Method
resource "aws_api_gateway_method" "query" {
  #  provider      = aws.usergroup
  rest_api_id   = aws_api_gateway_rest_api.spaApi.id
  resource_id   = aws_api_gateway_resource.query.id
  http_method   = "GET"
  authorization = "NONE"
  #request_parameters = {
  #  "method.request.querystring.logtime1" = true
  #  "method.request.querystring.logtime2" = true
  #}

}
## Create an integration with the dynamo db
resource "aws_api_gateway_integration" "query" {
  #  provider                = aws.usergroup
  rest_api_id             = aws_api_gateway_rest_api.spaApi.id
  resource_id             = aws_api_gateway_resource.query.id
  http_method             = aws_api_gateway_method.query.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/Query"
  #credentials             = aws_iam_role.api_gateway_dynamodb_example.arn
  credentials = "arn:aws:iam::660032875792:role/upmon-ddb-for-apigateway"

#{
#  "TableName": "upmon-history",
#  "KeyConditionExpression": "endpointurl = :url and begins_with(logtime, :logtime)",
#  "FilterExpression": "#c <> :ex_code",
#  "ExpressionAttributeNames": {"#c": "statuscode"},
#  "ExpressionAttributeValues": {
#    ":url": {"S": "$input.params('endpointurl')"},
#    ":logtime": {"S": "$input.params('logtime')"},
#    ":ex_code": {"S": "$input.params('ex_code')"}
#  }
#}
  request_templates = {
    "application/json" = <<EOF
      {
        "TableName": aws_dynamodb_table.table01.name,
        "KeyConditionExpression": "id = :id and begins_with(type, :type)",
        "FilterExpression": "#c <> :category",
        "ExpressionAttributeNames": {"#c": "category"},
        "ExpressionAttributeValues": {
          ":id": {"S": "$input.params('id')"},
          ":type": {"S": "$input.params('type')"},
          ":category": {"S": "$input.params('category')"}
        }
      }
    EOF
  }
}
#Add a response code with the method
resource "aws_api_gateway_method_response" "query-response-200" {
  #  provider    = aws.usergroup
  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  resource_id = aws_api_gateway_resource.query.id
  http_method = aws_api_gateway_method.query.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Create a response template for dynamo db structure
resource "aws_api_gateway_integration_response" "query-response" {
  #  provider    = aws.usergroup
  depends_on  = [aws_api_gateway_integration.query]
  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  resource_id = aws_api_gateway_resource.query.id
  http_method = aws_api_gateway_method.query.http_method
  status_code = aws_api_gateway_method_response.query-response-200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    {
      "items": [
    #foreach($elem in $inputRoot.Items)
        {
          "id": "$elem.id.S",
          "type": "$elem.type.S",
          "category": "$elem.category.S"
        }#if($foreach.hasNext),#end

    #end
      ]
    }
    EOF
  }
}

