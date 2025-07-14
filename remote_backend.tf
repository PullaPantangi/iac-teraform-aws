data "terraform_remote_state" "base_infra" {
  backend = "s3"
  config = {
    bucket = "iac-aws-backend"
    key    = "aws-backend/aws-tf.tfstate"
    region = "us-east-1"
    }
  }
