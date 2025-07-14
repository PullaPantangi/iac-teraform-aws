resource "aws_vpc" "pulla-main" {
  cidr_block = "10.1.0.0/16"

  tags = {
    name = "Pulla-main"
  }
}
resource "aws_subnet" "public-1" {
  vpc_id = aws_vpc.pulla-main.id
  cidr_block = "10.1.1.0/24"
  tags = {
    Name = "Main"
  }
}
resource "aws_internet_gateway" "pulla-main-igw" {
  vpc_id = aws_vpc.pulla-main.id

  tags = {
    Name = "pulla-main-igw"
  }
}
resource "aws_security_group" "pulla-main_sg1" {
  vpc_id = aws_vpc.pulla-main.id
  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}