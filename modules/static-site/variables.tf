variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store the static site files."
  type        = string
}
variable "domain_name" {
  description = "The domain name for the static site."
  type        = string
}
variable "subject_alternative_name" {
  description = "The subject alternative name for the static site."
  type        = string
}

