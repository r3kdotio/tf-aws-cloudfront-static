# AWS CloudFront Static Website with Terraform (Modular)

This repository now uses a reusable Terraform module for deploying a static website to AWS CloudFront. You can deploy separate environments (development and production) using the same module.

## Structure
- `modules/static-site/`: The reusable module containing all resources.
- `development/`: Environment-specific configuration for development.
- `production/`: Environment-specific configuration for production.

## Prerequisites
- [Terraform](https://www.terraform.io/) >= 1.10
- AWS credentials with permissions for S3, CloudFront, ACM, and Route53
- A registered domain in Route53

## Usage

1. **Configure variables**
   - Edit `development/variables.tf` and `production/variables.tf` as needed.
   - Provide values for `s3_bucket_name`, `domain_name`, and `subject_alternative_name` in a `.tfvars` file (e.g., `development.tfvars`).
2. **Initialize Terraform**
   ```sh
   cd development # or production
   terraform init
   ```
3. **Plan and apply**
   ```sh
   terraform plan
   terraform apply
   ```
4. **Upload your static site files**
   ```sh
   aws s3 cp ./public/ s3://<your-bucket-name>/ --recursive
   ```

Repeat the above steps in the `production` directory for production deployment.

## Clean URLs
S3 rewrites URLs so `/about` and `/about/` both serve `/about/index.html`.
There is a cost associated with this CloudFront functions: $0.10 per 1 million invocations.

## License
MIT
