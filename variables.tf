variable "tf_org" {
  type = string
  description = "Terraform Cloud workspace"
  default = "abcballpark"
}

variable "api_name" {
  type = string
  description = "Human-readable name for API Gateway REST API"
}

variable "parent_resource_id" {
  type = string
}

variable "endpoint_name" {
  type = string
  description = "Name of the endpoint on the API. Must be URL-safe"
}

variable "http_method" {
  type = string
}

variable "src_bucket" {
  type = string
  description = "Bucket name for "
}

variable "src_key" {
  type = string
}

variable "handler" {
  type = string
}

variable "src_hash" {
  type = string
}

variable "api_id" {
  type = string
}

variable "route_key" {
  type = string
}

variable "execution_arn" {
  type = string
}
