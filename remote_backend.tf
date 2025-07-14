data "terraform_remote_state" "base_infra" {
  backend = "s3"
  config = {
    bucket = "iac-aws-backend"
    key    = "aws-backend/aws-tf.tfstate"
    region = "us-east-1"
    }
  }

provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "iac-aws-backend"
    key    = "aws-backend/remote.tfstate"
    region = "us-east-1"
  }
}
