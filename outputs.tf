output "api_gateway_rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.api_gateway.id
}

output "api_gateway_rest_api_root_resource_id" {
  description = "Resource ID of the REST API`s root"
  value       = aws_api_gateway_rest_api.api_gateway.root_resource_id
}

output "api_gateway_rest_api_execution_arn" {
  description = "The execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function, e.g. arn:aws:execute-api:eu-west-2:123456789012:z4675bid1j, which can be concatenated with allowed stage, method and resource path"
  value       = aws_api_gateway_rest_api.api_gateway.execution_arn
}

output "aws_api_gateway_rest_api_arn" {
  description = "ARN"
  value       = aws_api_gateway_rest_api.api_gateway.arn
}

output "aws_api_gateway_deployment_id" {
  description = "The ID of the deployment"
  value       = aws_api_gateway_deployment.api_gw_deployment.id
}

output "invoke_url" {
  description = "The URL to invoke the API pointing to the stage, e.g.,"
  value       = aws_api_gateway_deployment.api_gw_deployment.invoke_url
}

output "execution_arn" {
  description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
  value       = aws_api_gateway_deployment.api_gw_deployment.execution_arn
}

output "authorizer_id" {
  value = try(aws_api_gateway_authorizer.cognito_authorizer[*].id, "")
}