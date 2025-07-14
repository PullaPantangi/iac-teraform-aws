terraform {
  backend "s3" {
    bucket = "iac-aws-backend"
    key    = "aws-backend/remote-datasource-tf.tfstate"
    region = "us-east-1"
  }
}
