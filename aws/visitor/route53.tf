data "aws_route53_zone" "profile" {
  name = local.domain
}

resource "aws_route53_record" "profile" {
  name    = "api.${local.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.profile.zone_id

  alias {
    name                   = data.aws_api_gateway_domain_name.profile.regional_domain_name
    zone_id                = data.aws_api_gateway_domain_name.profile.regional_zone_id
    evaluate_target_health = false
  }
}
