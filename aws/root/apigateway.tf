resource "aws_api_gateway_rest_api" "profile" {
  name = local.profile_name
  description = "Serverless backend for online profile"

  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }
}

resource "aws_api_gateway_domain_name" "profile" {
  domain_name = "api.${local.domain_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  regional_certificate_arn = data.aws_acm_certificate.domain.arn
}
