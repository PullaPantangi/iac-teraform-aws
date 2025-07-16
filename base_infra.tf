locals {
 comman_tags = {
  Env = "Platinum"
  Product = "Core"
  Apptype = "AWS"
 }
}
resource "aws_vpc" "platinum_aws" {
  cidr_block = var.vpc_cidr

  tags = merge(
    local.comman_tags,
   {
    Name = var.vpc_name
   }
  )
}
resource "aws_internet_gateway" "platinum_igw" {
  vpc_id = aws_vpc.platinum_aws.id

  tags = merge(
    local.comman_tags,
   {
    Name = "platinum-aws-igw"
   }
  )
}
resource "aws_subnet" "pb_subnet_platinum_aws" {
  count = length(var.pub_subnet_cidr)
  vpc_id = aws_vpc.platinum_aws.id
  cidr_block = element(var.pub_subnet_cidr, count.index)
  availability_zone = element(var.region,count.index)
  tags = merge(
    local.comman_tags,
   {
    Name = "pb_subnet_platinum_${count.index +1 }"
   }
  )
}
resource "aws_route_table" "platinum_pub_RT" {
  vpc_id = aws_vpc.platinum_aws.id

  route {
    cidr_block = var.igw_route
    gateway_id = aws_internet_gateway.platinum_igw.id
  }
  tags = merge(
    local.comman_tags,
   {
    Name = "pub_platinum_aws_RT"
   }
  )
}

resource "aws_route_table_association" "public-associan" {
  count = length(var.pub_subnet_cidr)
  subnet_id      = element(aws_subnet.pb_subnet_platinum_aws[*].id, count.index)
  route_table_id = aws_route_table.platinum_pub_RT.id
}

resource "aws_subnet" "pvt_subnet_platinum_aws" {
  count = length(var.pvt_subent_cidr)
  vpc_id = aws_vpc.platinum_aws.id
  cidr_block = element(var.pvt_subent_cidr, count.index)
  availability_zone = element(var.region,count.index)
  tags = merge(
    local.comman_tags,
   {
    Name = "pvt-subnet-platinum-${count.index +1 }"
   }
  )
}

resource "aws_route_table" "platinum_pvt_RT" {
  vpc_id = aws_vpc.platinum_aws.id
  tags = merge(
    local.comman_tags,
   {
    Name = "pvt_platinum_aws_RT"
   }
  )
}
resource "aws_route_table_association" "pvt-associan" {
  count = length(var.pvt_subent_cidr)
  subnet_id      = element(aws_subnet.pvt_subnet_platinum_aws[*].id, count.index)
  route_table_id = aws_route_table.platinum_pvt_RT.id
}

resource "aws_security_group" "platinum_sg1" {
  vpc_id = aws_vpc.platinum_aws.id
  dynamic "ingress" {
    for_each = toset(var.ports_in)
    content {
      cidr_blocks = [var.igw_route]
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"       
    }
  } 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "Pub" {
  count = length(var.pub_subnet_cidr)
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.platinum_sg1.id]
  subnet_id                   = element(aws_subnet.pb_subnet_platinum_aws[*].id, count.index)
  availability_zone           = element(var.region,count.index)
  associate_public_ip_address = true
  tags = merge(
    local.comman_tags,
   {
    Name = "${var.Env}-pub-server-${count.index + 1}"
   }
  )
}
resource "aws_instance" "Pvt" {
  count = length(var.pvt_subent_cidr)
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.platinum_sg1.id]
  subnet_id                   = element(aws_subnet.pvt_subnet_platinum_aws[*].id, count.index)
  availability_zone           = element(var.region,count.index)
  associate_public_ip_address = true
  tags = merge(
    local.comman_tags,
   {
    Name = "${var.Env}-pvt-server-${count.index + 1}"
   }
  )
}