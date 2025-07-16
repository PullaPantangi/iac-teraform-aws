resource "aws_vpc" "pulla-main" {
  cidr_block = var.vpc_cidr

  tags = {
    name = "Pulla-main"
  }
}
resource "aws_subnet" "public-1" {
  vpc_id = aws_vpc.pulla-main.id
  cidr_block = var.pub_cidr
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
    cidr_blocks = [var.igw_route]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.igw_route]
  }
}
resource "aws_route_table" "pulla-main-RT" {
  vpc_id = aws_vpc.pulla-main.id

  route {
    cidr_block = var.igw_route
    gateway_id = aws_internet_gateway.pulla-main-igw.id
  }
}

resource "aws_route_table_association" "public-associan" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.pulla-main-RT.id
}

resource "aws_instance" "Pub1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.pulla-main_sg1.id]
  subnet_id                   = aws_subnet.public-1.id
  associate_public_ip_address = true
  tags = {
      Name = "Public_Server_1"
    }
}