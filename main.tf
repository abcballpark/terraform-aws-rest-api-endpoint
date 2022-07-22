///////////////////////////////////////////////////////////////////////////////
// Lambda Definition 
resource "aws_lambda_function" "endpoint_fn" {
  function_name = "${var.api_name}-${var.endpoint_name}"

  s3_bucket = var.src_bucket
  s3_key    = var.src_key

  runtime = "nodejs16.x"
  handler = var.handler

  source_code_hash = var.src_hash

  role = aws_iam_role.exec_role.arn
}

resource "aws_cloudwatch_log_group" "endpoint_fn_exec_log" {
  name = "/aws/lambda/${var.api_name}=${var.endpoint_name}"
}

///////////////////////////////////////////////////////////////////////////////
// Lambda Permissions

data "aws_iam_policy_document" "lambda_exec_policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "exec_role" {
  name               = "${var.api_name}-${var.endpoint_name}-executor"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "exec_role_policy_1" {
  role       = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = aws_lambda_function.endpoint_fn.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
}

///////////////////////////////////////////////////////////////////////////////
// API Gateway

resource "aws_api_gateway_resource" "endpoint" {
  path_part   = var.endpoint_name
  parent_id   = var.parent_resource_id
  rest_api_id = var.api_id
}

resource "aws_api_gateway_method" "endpoint" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.endpoint.id
  http_method   = var.http_method
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "redirect" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.endpoint.id
  http_method             = aws_api_gateway_method.endpoint.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.endpoint_fn.invoke_arn
}

resource "aws_api_gateway_integration_response" "response_200" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.endpoint.id
  http_method = aws_api_gateway_method.endpoint.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "endpoint" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.endpoint.id
  http_method = aws_api_gateway_method.endpoint.http_method
  status_code = aws_api_gateway_integration_response.response_200.status_code
}
