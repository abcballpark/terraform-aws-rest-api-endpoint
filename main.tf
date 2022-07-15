resource "aws_lambda_function" "endpoint_fn" {
  function_name = "${var.api_name}-${var.endpoint_name}"

  s3_bucket = var.src_bucket
  s3_key    = var.src_key

  runtime = "nodejs16.x"
  handler = var.handler

  source_code_hash = var.src_hash

  role = aws_iam_role.exec_role.arn
}

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
  name               = "api-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "exec_role_policy_1" {
  role       = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_route" "endpoint" {
  api_id    = var.api_id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.endpoint.id}"
}

resource "aws_apigatewayv2_integration" "endpoint" {
  api_id = var.api_id

  integration_uri    = aws_lambda_function.endpoint_fn.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_lambda_permission" "endpoint" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.endpoint_fn.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${var.execution_arn}/*/*"
}
