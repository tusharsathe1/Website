resource "aws_s3_bucket" "main_bucket" {
  bucket = var.main_domain
  policy = file("MainBucketPolicy.json")
  force_destroy = true
  acl = "public-read"
  website {
    index_document = "index.html"
  }
    provisioner "local-exec" {
      command = "aws s3 sync ${path.cwd}/public/ s3://${aws_s3_bucket.main_bucket.id}"
    }
}

resource "aws_s3_bucket" "redirect_bucket" {
  bucket = var.sub_domain
  policy = file("RedirectBucketPolicy.json")
  acl = "public-read"
  website {
    redirect_all_requests_to = var.main_domain
  }
}
