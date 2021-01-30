# === /visitor POST count
resource "aws_lambda_function" "record-visit" {
  function_name    = "visitor_record_visit"
  description      = "Record visit"
  handler          = "handlers.create"
  role             = aws_iam_role.lambda-execution-role.arn
  runtime          = "python3.8"
  filename         = data.archive_file.record_visit.output_path
  source_code_hash = data.archive_file.record_visit.output_base64sha256
}

# === Authorize Api gateway to invoke lambda
resource "aws_lambda_permission" "record_visit" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.record-visit.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.profile.execution_arn}*/${aws_api_gateway_method.visitor-post.http_method}${aws_api_gateway_resource.visitor.path}"
}