provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

locals {
  s3_origin_id = "${var.s3_bucket_name}-s3-static-site"
}


resource "aws_cloudfront_origin_access_control" "static_site" {
  name                              = "${var.s3_bucket_name}-static-site-oac"
  description                       = "OAC for static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "rewrite_index" {
  name    = "${var.s3_bucket_name}-rewrite-index-html"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite URLs ending with / or no extension to /index.html"
  publish = true
  code    = <<EOT
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } else if (!uri.includes('.') && !uri.endsWith('/')) {
        request.uri += '/index.html';
    }
    return request;
}
EOT
}

resource "aws_cloudfront_cache_policy" "static_site_cache_policy" {
  name        = "${var.s3_bucket_name}-static-site-cache-policy"
  comment     = "Cache policy for static site with function processing"
  default_ttl = 60    # 1 minute in seconds
  max_ttl     = 600 # 5 minutes in seconds
  min_ttl     = 60   # 1 minute in seconds

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_distribution" "static_site_distribution" {
  enabled             = true
  default_root_object = "index.html"
  origin {
    domain_name              = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.static_site.id
  }
  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["CN", "RU"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_index.arn
    }

    cache_policy_id = aws_cloudfront_cache_policy.static_site_cache_policy.id
    compress = true
  }
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.site_cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
  aliases = [var.domain_name, var.subject_alternative_name]
}

