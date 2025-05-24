variable "s3_bucket_name" {
  type    = string
  default = "rjdkolb-static-site"
}
variable "domain_name" {
  type    = string
  default = "rjdkolb.com"
}
variable "subject_alternative_name" {
  type    = string
  default = "www.rjdkolb.com"
}
