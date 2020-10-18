#Import the bucket for logging
data "aws_s3_bucket" "logging" {
  bucket = var.log_bucket
}

#Import the certificate
data "aws_acm_certificate" "site_cert" {
  domain = var.main_domain
  types = ["AMAZON_ISSUED"]
}

#CloudFront distribution
resource "aws_cloudfront_distribution" "my_cf_distro" {
  aliases = [var.main_domain, var.sub_domain]
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.main_bucket.bucket_regional_domain_name
    origin_id = "MyOrigin"
  }

  enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "MyOrigin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      cookies {
        forward = "none"
      }
    query_string = false
    }
  }

  ordered_cache_behavior {
    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.CF_Lambda_IndexPages.qualified_arn
    }

    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "MyOrigin"
    viewer_protocol_policy = "redirect-to-https"
    path_pattern = "*"

    forwarded_values {
      cookies {
        forward = "none"
      }
    query_string = false
    }
  }

  logging_config {
    bucket = data.aws_s3_bucket.logging.bucket_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.site_cert.arn
    ssl_support_method = "sni-only"
  }
}

#IAM role for Lambda
resource "aws_iam_role" "Role_For_Lambda" {
  name = "IAM_For_Lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#IAM Policy for the role
resource "aws_iam_policy" "Policy_For_Lambda" {
  name = "LambdaRolePolicy"
  policy = file("iam_policy.json")
}

#IAM Policy attachment
resource "aws_iam_role_policy_attachment" "Policy_Role_Attachment_Lambda" {
  role = aws_iam_role.Role_For_Lambda.name
  policy_arn = aws_iam_policy.Policy_For_Lambda.arn
}

#Lambda for CloudFront
resource "aws_lambda_function" "CF_Lambda_IndexPages" {
  filename = "index.zip"
  function_name = "CF_Lambda_IndexPages"
  role = aws_iam_role.Role_For_Lambda.arn
  handler = "index.handler"
  runtime = "nodejs12.x"
  publish = true
}
