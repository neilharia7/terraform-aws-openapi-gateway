resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.name
  description = var.description
  body        = var.body
  endpoint_configuration {
    types            = var.types
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }
}

data "aws_iam_policy_document" "api_gw_private_data" {
  count = var.vpc_endpoint_ids != null ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["*"]
  }
  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = var.vpc_endpoint_ids
    }
  }
}

resource "aws_api_gateway_rest_api_policy" "api_gateway_policy" {
  count       = var.vpc_endpoint_ids != null ? 1 : 0
  policy      = data.aws_iam_policy_document.api_gw_private_data[0].json
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  count                            = var.enable_authorizer ? 1 : 0
  name                             = var.name
  rest_api_id                      = aws_api_gateway_rest_api.api_gateway.id
  authorizer_uri                   = var.authorizer_invoke_arn
  identity_source                  = var.identity_source
  type                             = var.authorizer_type
  authorizer_result_ttl_in_seconds = var.caching_ttl
}

# Invoke permission for authorizer lambda
resource "aws_lambda_permission" "auth_lambda_invoke_permission" {
  count               = var.enable_authorizer ? 1 : 0
  action              = "lambda:InvokeFunction"
  function_name       = var.authorizer_function_name
  principal           = "apigateway.amazonaws.com"
  statement_id_prefix = "AllowAPIGatewayInvoke"
}

# Invoke permission for endpoint lambda
resource "aws_lambda_permission" "lambda_invoke_permission" {
  action              = "lambda:InvokeFunction"
  function_name       = var.lambda_handler_function_name
  principal           = "apigateway.amazonaws.com"
  statement_id_prefix = "AllowAPIGatewayInvoke"
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  triggers    = var.triggers
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_gateway_response" "unauthorized" {
  count         = var.enable_unauthorized_response ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  status_code   = "401"
  response_type = "UNAUTHORIZED"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "method.request.header.origin"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  count         = var.enable_access_denied_response ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  status_code   = "403"
  response_type = "ACCESS_DENIED"

  response_templates = {
    "application/json" = "{\"title\":$context.authorizer.title, \"message\": $context.authorizer.message, \"detail\":$context.authorizer.detail}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "method.request.header.origin"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }
}