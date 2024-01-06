# API Gateway for dynamodb
resource "aws_api_gateway_rest_api" "spaApi" {
  #  provider    = aws.usergroup
  name        = "poc-spa-api"
  description = "poc api"
  
  # could also use Edge for production depending on our use case
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Deploying API Gateway
resource "aws_api_gateway_deployment" "ApiDeployment" {
  #  provider   = aws.usergroup
  depends_on = [aws_api_gateway_integration.query]

  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  stage_name  = var.stage_name

  variables = {
    "deployedAt" = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}


## not used below

# get one id
# Create a resource
#resource "aws_api_gateway_resource" "get-one" {
#  #  provider    = aws.usergroup
#  rest_api_id = aws_api_gateway_rest_api.upmonApi.id
#  parent_id   = aws_api_gateway_rest_api.upmonApi.root_resource_id
#  path_part   = "{val}"
#}
## Create a Method
#resource "aws_api_gateway_method" "get-method" {
#  #  provider      = aws.usergroup
#  rest_api_id   = aws_api_gateway_rest_api.upmonApi.id
#  resource_id   = aws_api_gateway_resource.get-one.id
#  http_method   = "GET"
#  authorization = "NONE"
#}
## Create an integration with the dynamo db
#resource "aws_api_gateway_integration" "get-integration" {
#  #  provider                = aws.usergroup
#  rest_api_id             = aws_api_gateway_rest_api.upmonApi.id
#  resource_id             = aws_api_gateway_resource.get-one.id
#  http_method             = aws_api_gateway_method.get-method.http_method
#  type                    = "AWS"
#  integration_http_method = "POST"
#  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/Query"
#  #credentials             = aws_iam_role.api_gateway_dynamodb_example.arn
#  credentials = "arn:aws:iam::660032875792:role/upmon-ddb-for-apigateway"
#
#  request_templates = {
#    "application/json" = <<EOF
#      {
#        "TableName": "${data.aws_dynamodb_table.history.name}",
#        "KeyConditionExpression": "id = :val",
#        "ExpressionAttributeValues": {
#          ":val": {
#              "S": "$input.params('val')"
#          }
#        }
#      }
#    EOF
#  }
#}
##Add a response code with the method
#resource "aws_api_gateway_method_response" "get-response-200" {
#  #  provider    = aws.usergroup
#  rest_api_id = aws_api_gateway_rest_api.upmonApi.id
#  resource_id = aws_api_gateway_resource.get-one.id
#  http_method = aws_api_gateway_method.get-method.http_method
#  status_code = "200"
#  response_parameters = {
#    "method.response.header.Access-Control-Allow-Origin" = true
#  }
#}
#
## Create a response template for dynamo db structure
#resource "aws_api_gateway_integration_response" "get-response" {
#  #  provider    = aws.usergroup
#  depends_on  = [aws_api_gateway_integration.get-integration]
#  rest_api_id = aws_api_gateway_rest_api.upmonApi.id
#  resource_id = aws_api_gateway_resource.get-one.id
#  http_method = aws_api_gateway_method.get-method.http_method
#  status_code = aws_api_gateway_method_response.get-response-200.status_code
#  response_parameters = {
#    "method.response.header.Access-Control-Allow-Origin" = "'*'"
#  }
#
#  response_templates = {
#    "application/json" = <<EOF
#      #set($inputRoot = $input.path('$'))
#      {
#        #foreach($elem in $inputRoot.Items)
#        "id": "$elem.id.S",
#        "fu": "$elem.fu.S"
#        #if($foreach.hasNext),#end
#        #end
#      }
#    EOF
#  }
#}