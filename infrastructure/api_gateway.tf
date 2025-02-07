resource "aws_api_gateway_rest_api" "m2m-poc-gateway" {
  name        = "m2m-poc-gateway"
  description = "M2M POC API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "m2m-poc-gateway-root" {
  rest_api_id = aws_api_gateway_rest_api.m2m-poc-gateway.id
  parent_id   = aws_api_gateway_rest_api.m2m-poc-gateway.root_resource_id
  path_part   = "m2m-poc"
}

resource "aws_api_gateway_method" "m2m-poc-gateway-method-read" {
  rest_api_id          = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id          = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.m2m-poc-authorizer.id
  authorization_scopes = ["https://m2m-poc-server/read"]
}

resource "aws_api_gateway_integration" "m2m-poc-gateway-integration-read" {
  rest_api_id             = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id             = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method             = aws_api_gateway_method.m2m-poc-gateway-method-read.http_method
  integration_http_method = "GET"
  type                    = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
  depends_on = [aws_api_gateway_method.m2m-poc-gateway-method-read]
}

resource "aws_api_gateway_method_response" "m2m-poc-gateway-method-response-read" {
  rest_api_id = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method = aws_api_gateway_method.m2m-poc-gateway-method-read.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "m2m-poc-gateway-integration-response-read" {
  rest_api_id = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method = aws_api_gateway_method.m2m-poc-gateway-method-read.http_method
  status_code = aws_api_gateway_method_response.m2m-poc-gateway-method-response-read.status_code
  response_templates = {
    "application/json" = jsonencode({
      message = "successful read"
    })
  }
  depends_on = [aws_api_gateway_method_response.m2m-poc-gateway-method-response-read, aws_api_gateway_integration.m2m-poc-gateway-integration-read]
}

resource "aws_api_gateway_method" "m2m-poc-gateway-method-write" {
  rest_api_id          = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id          = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.m2m-poc-authorizer.id
  authorization_scopes = ["https://m2m-poc-server/write"]
}

resource "aws_api_gateway_integration" "m2m-poc-gateway-integration-write" {
  rest_api_id             = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id             = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method             = aws_api_gateway_method.m2m-poc-gateway-method-write.http_method
  integration_http_method = "POST"
  type                    = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
  depends_on = [aws_api_gateway_method.m2m-poc-gateway-method-write]
}

resource "aws_api_gateway_method_response" "m2m-poc-gateway-method-response-write" {
  rest_api_id = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method = aws_api_gateway_method.m2m-poc-gateway-method-write.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "m2m-poc-gateway-integration-response-write" {
  rest_api_id = aws_api_gateway_rest_api.m2m-poc-gateway.id
  resource_id = aws_api_gateway_resource.m2m-poc-gateway-root.id
  http_method = aws_api_gateway_method.m2m-poc-gateway-method-write.http_method
  status_code = aws_api_gateway_method_response.m2m-poc-gateway-method-response-write.status_code
  response_templates = {
    "application/json" = jsonencode({
      message = "successful write"
    })
  }
  depends_on = [aws_api_gateway_method_response.m2m-poc-gateway-method-response-write, aws_api_gateway_integration.m2m-poc-gateway-integration-write]
}

resource "aws_api_gateway_deployment" "m2m-poc-gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.m2m-poc-gateway.id
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_integration.m2m-poc-gateway-integration-write, aws_api_gateway_integration.m2m-poc-gateway-integration-read]
}

resource "aws_api_gateway_stage" "m2m-poc-gateway-stage" {
  deployment_id = aws_api_gateway_deployment.m2m-poc-gateway-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.m2m-poc-gateway.id
  stage_name    = "prod"
}

resource "aws_api_gateway_authorizer" "m2m-poc-authorizer" {
  name            = "m2m-poc-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.m2m-poc-gateway.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.m2m_poc_user_pool.arn]
}
