The website is designed using Hugo template. It is hosted on AWS S3 and it is provisioned using Terraform.

The terraform directory contains configuration files that are used to deploy the website on AWS S3. The repo can provision a static website on AWS S3 using Terraform. Besides S3, the website utilizes other AWS services such as CloudFront, Lambda Function and Route53.

# Details

- [bucket.tf](terraform/bucket.tf): This file creates 1 bucket each for the root and sub-domain and uploads relevant files to the root domain bucket.

- [cloudfront.tf](terraform/cloudfront.tf): This file creates a CloudFront distribution for the website using an Amazon issued certificate and a Lambda function. CloudFront by design only allows defining default page for the root directory. Lambda function rewrites all the requests for the default page of subdirectories to include "index.html" before forwarding it to S3.

- [route53.tf](terraform/route53.tf): This file creates an alias for the domain and points it to CloudFront distribution.

## Deployment instructions:

In the terraform directory, execute below commands:

1. Initialize terraform using **"terraform init"**

2. Plan and review the changes using **"terraform plan"**

3. Apply the changes using **"terraform apply"**

**Note**: Any changes to the contents of the file requires taining of S3 resources and invalidation of CloudFront cache.
