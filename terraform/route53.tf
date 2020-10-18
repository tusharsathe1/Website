#Import the hosted zone
data "aws_route53_zone" "reg_zone" {
  name         = var.main_domain
}

#Point root domain to CloudFront
resource "aws_route53_record" "main_record" {
  zone_id = data.aws_route53_zone.reg_zone.zone_id
  name = var.main_domain
  type = "A"

  alias {
    name = aws_cloudfront_distribution.my_cf_distro.domain_name
    zone_id = aws_cloudfront_distribution.my_cf_distro.hosted_zone_id
    evaluate_target_health = false
  }
}

#Point sub-domain to CloudFront
resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.reg_zone.zone_id
  name = var.sub_domain
  type = "A"

  alias {
    name = aws_cloudfront_distribution.my_cf_distro.domain_name
    zone_id = aws_cloudfront_distribution.my_cf_distro.hosted_zone_id
    evaluate_target_health = false
  }
}
