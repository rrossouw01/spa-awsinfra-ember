# Create a resource
resource "aws_api_gateway_resource" "rentals" {
  #  provider    = aws.usergroup
  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  parent_id   = aws_api_gateway_rest_api.spaApi.root_resource_id
  path_part   = "all_rentals"
}
## Create a Method
resource "aws_api_gateway_method" "rentals" {
  #  provider      = aws.usergroup
  rest_api_id   = aws_api_gateway_rest_api.spaApi.id
  resource_id   = aws_api_gateway_resource.rentals.id
  http_method   = "GET"
  authorization = "NONE"
  #request_parameters = {
  #  "method.request.querystring.logtime1" = true
  #  "method.request.querystring.logtime2" = true
  #}

}
## Create an integration with the dynamo db
resource "aws_api_gateway_integration" "rentals" {
  #  provider                = aws.usergroup
  rest_api_id             = aws_api_gateway_rest_api.spaApi.id
  resource_id             = aws_api_gateway_resource.rentals.id
  http_method             = aws_api_gateway_method.rentals.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/Scan"
  #credentials             = aws_iam_role.api_gateway_dynamodb_example.arn
  credentials = "arn:aws:iam::660032875792:role/upmon-ddb-for-apigateway"

  request_templates = {
    "application/json" = <<EOF
      {
      "TableName": "poc_spa_awsinfra"
      }
    EOF
  }
}
#Add a response code with the method
resource "aws_api_gateway_method_response" "rentals-response-200" {
  #  provider    = aws.usergroup
  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  resource_id = aws_api_gateway_resource.rentals.id
  http_method = aws_api_gateway_method.rentals.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Create a response template for dynamo db structure
resource "aws_api_gateway_integration_response" "rentals-response" {
  #  provider    = aws.usergroup
  depends_on  = [aws_api_gateway_integration.query]
  rest_api_id = aws_api_gateway_rest_api.spaApi.id
  resource_id = aws_api_gateway_resource.rentals.id
  http_method = aws_api_gateway_method.rentals.http_method
  status_code = aws_api_gateway_method_response.rentals-response-200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
[
#foreach($elem in $inputRoot.Items)
    {
      "id": "$elem.id.S",
      "type": "$elem.type.S",
      "attributes": {
        "bedroooms": "$elem.attributes.M.bedrooms.S",
        "category": "$elem.attributes.M.category.S",
        "city": "$elem.attributes.M.city.S",
        "description": "$elem.attributes.M.description.S",
        "image": "$elem.attributes.M.image.S",
        "owner": "$elem.attributes.M.owner.S",
        "title": "$elem.attributes.M.title.S",
        "location": {
          "lat": "$elem.attributes.M.location.M.lat.S",
          "lng": "$elem.attributes.M.location.M.lng.S"
        }
      }
    }#if($foreach.hasNext),#end
		
#end
]
    EOF
  }
}
