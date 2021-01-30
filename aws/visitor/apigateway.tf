data "aws_api_gateway_rest_api" "profile" {
  name = "profile"
}

data "aws_api_gateway_domain_name" "profile" {
  domain_name = "api.${local.domain}"
}

# ==== /visitor
resource "aws_api_gateway_resource" "visitor" {
  parent_id   = data.aws_api_gateway_rest_api.profile.root_resource_id
  path_part   = "visitor"
  rest_api_id = data.aws_api_gateway_rest_api.profile.id
}

# ==== /visitor POST
resource "aws_api_gateway_method" "visitor-post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.visitor.id
  rest_api_id   = data.aws_api_gateway_rest_api.profile.id
}

resource "aws_api_gateway_integration" "visitor-post" {
  http_method             = aws_api_gateway_method.visitor-post.http_method
  resource_id             = aws_api_gateway_resource.visitor.id
  rest_api_id             = data.aws_api_gateway_rest_api.profile.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.record-visit.invoke_arn
}

# ==== deploy the api gateway
resource "aws_api_gateway_deployment" "profile" {
  rest_api_id = data.aws_api_gateway_rest_api.profile.id

  depends_on = [
    aws_api_gateway_integration.visitor-post
  ]
}

resource "aws_api_gateway_stage" "profile" {
  deployment_id = aws_api_gateway_deployment.profile.id
  rest_api_id   = data.aws_api_gateway_rest_api.profile.id
  stage_name    = "development"

  lifecycle {
    ignore_changes = [
      cache_cluster_size
    ]
  }
}

resource "aws_api_gateway_base_path_mapping" "profile" {
  api_id      = data.aws_api_gateway_rest_api.profile.id
  stage_name  = aws_api_gateway_stage.profile.stage_name
  domain_name = data.aws_api_gateway_domain_name.profile.domain_name
}
