# terraform-aws-openapi-gateway
Terraform module that creates an API Gateway using OpenAPI YAML file with an optional authorizer 

## Usage

```hcl

data "github_repository_file" "workspace_open_api_file" {
  repository = "<repository name>"
  branch     = "<branch name>"
  file       = "<file path to your openapi.yaml>"
}

locals {
  open_api_file = data.github_repository_file.workspace_open_api_file.content
  temp1         = replace(local.open_api_file, "$${AWS::Region}", var.region)
  temp2         = replace(local.temp1, "Fn::Sub:", "")
  temp3         = replace(local.temp2, "$${Lambda.Arn}", aws_lambda_function.pet_function.function_arn)  # replace with your function arn
  final         = replace(local.temp3, "$${CognitoLambda.Arn}", aws_lambda_function.cognito_function.function_arn)  # replace with your cognito function arn
}

module "openapi_gateway" {
  source                       = "git::git@github.com:neilharia7/terraform-aws-openapi-gateway"
  name                         = "api-gw"
  enable_authorizer            = true
  authorizer_function_name     = aws_lambda_function.cognito_function.function_name  # replace with your cognito function arn
  lambda_handler_function_name = aws_lambda_function.pet_function.function_name  # replace with your function name
  triggers                     = {
    redeployment = local.final
  }
  types = ["REGIONAL"]
  body  = local.final
}
```