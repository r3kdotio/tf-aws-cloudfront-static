terraform {
  required_version = "~> 1.10"
  backend "s3" {
    bucket       = "r3kio-tf"
    key          = "development/tf-aws-cloudfront-static.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true # S3 native locking
  }
}
