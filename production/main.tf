
module "static_site" {
  source = "../modules/static-site"
  s3_bucket_name            = "r3kio-static-site"
  domain_name               = "r3k.io"
  subject_alternative_name  = "www.r3k.io"
}
