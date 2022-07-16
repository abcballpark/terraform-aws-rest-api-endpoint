output "function_name" {
  value = aws_lambda_function.endpoint_fn.function_name
}

output "sha1_output" {
  value = sha1(jsonencode([
    aws_api_gateway_method.endpoint,
    aws_api_gateway_method_response.endpoint,
    aws_api_gateway_integration.redirect,
    aws_api_gateway_integration_response.response_200,
  ]))
}
