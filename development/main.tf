
module "static_site" {
  source                   = "../modules/static-site"
  s3_bucket_name           = var.s3_bucket_name
  domain_name              = var.domain_name
  subject_alternative_name = var.subject_alternative_name
}

