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
  update_region = replace(local.open_api_file, "$${AWS::Region}", var.region)
  cleanup       = replace(local.update_region, "Fn::Sub:", "")
  update_lambda = replace(local.cleanup, "$${Lambda.Arn}", aws_lambda_function.pet_function.function_arn)  # replace with your function arn
  final         = replace(local.update_lambda, "$${CognitoLambda.Arn}", aws_lambda_function.cognito_function.function_arn)  # replace with your cognito function arn
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

## Requirements

| Name | Version   |
|------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.69.0 |

## Providers

| Name | Version   |
|------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.69.0 |

