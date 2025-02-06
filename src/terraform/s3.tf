resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  acl    = "private"  # Define o acesso ao bucket (pode ser "public-read", "private", etc.)

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}