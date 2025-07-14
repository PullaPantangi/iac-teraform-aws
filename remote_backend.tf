data "terraform_remote_state" "base_infra" {
  backend = "remote"
  config = {
    bucket = "iac-aws-backend"
    key    = "aws-backend/aws-tf.tfstate"
    region = "us-east-1"
    }
  }
