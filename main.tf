terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "iac-aws-backend"
    key    = "aws-backend/aws-tf.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}
