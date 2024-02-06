variable "name" {
  type        = string
  description = "Name (e.g. `my-api-gateway`)"
}

variable "description" {
  type        = string
  description = "(Optional) Description of the REST API. If importing an OpenAPI specification via the `body` argument, this corresponds to the `info.description` field. If the argument value is provided and is different than the OpenAPI value, the argument value will override the OpenAPI value."
  default     = null
}

variable "body" {
  description = "(Required) JSON/YAML formatted definition file using OpenAPI 3.x specification. This definition contains all API configuration inputs. Any inputs used in Terraform will override inputs in the definition."
  default     = null
}

variable "types" {
  type        = list(string)
  description = "(Required) List of endpoint types. This resource currently only supports managing a single value. Valid values: `EDGE`, `REGIONAL` or `PRIVATE`. If unspecified, defaults to `EDGE`. Must be declared as `REGIONAL` in non-Commercial partitions. If set to `PRIVATE` recommend to set put_rest_api_mode = merge to not cause the endpoints and associated Route53 records to be deleted. Refer to the documentation for more information on the difference between edge-optimized and regional APIs."
  default     = ["EDGE"]
}

variable "vpc_endpoint_ids" {
  type        = list(string)
  description = "(Optional) Set of VPC Endpoint identifiers. It is only supported for PRIVATE endpoint type"
  default     = null
}

variable "enable_authorizer" {
  type        = bool
  description = "Flag for attaching an cognito authorizer"
  default     = false
}

variable "authorizer_invoke_arn" {
  type        = string
  description = "Invoke ARN for Authorizer"
  default     = null
}

variable "identity_source" {
  type        = string
  description = "Source of the identity in an incoming request."
  default     = "method.request.header.X-Forwarded-For"
}

variable "authorizer_type" {
  type        = string
  description = "Type of the authorizer."
  default     = "REQUEST"
}

variable "caching_ttl" {
  type        = number
  description = "If 0, caching will be disabled. Values greater than 0 will enable caching and set the value of TTL"
  default     = 0
}

variable "authorizer_function_name" {
  type        = string
  description = "(Required) Name of the Lambda function whose resource policy you are updating"
}

variable "lambda_handler_function_name" {
  type        = string
  description = "(Required) Name of the Lambda function which is going to be invoked for the routes"
}

variable "triggers" {
  type        = map(any)
  description = "(Required) Map of arbitrary keys and values that, when changed, will trigger a redeployment"
}

variable "enable_unauthorized_response" {
  type        = bool
  description = "to enable UNAUTHORIZED response from api gw"
  default     = true
}

variable "enable_access_denied_response" {
  type        = bool
  description = "to enable ACCESS_DENIED response from api gw"
  default     = true
}
