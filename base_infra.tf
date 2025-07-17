locals {
  comman_tags = {
    Env     = "Platinum"
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
  count             = length(var.pub_subnet_cidr)
  vpc_id            = aws_vpc.platinum_aws.id
  cidr_block        = element(var.pub_subnet_cidr, count.index)
  availability_zone = element(var.region, count.index)
  tags = merge(
    local.comman_tags,
    {
      Name = "pb_subnet_platinum_${count.index + 1}"
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
  count          = length(var.pub_subnet_cidr)
  subnet_id      = element(aws_subnet.pb_subnet_platinum_aws[*].id, count.index)
  route_table_id = aws_route_table.platinum_pub_RT.id
}

resource "aws_subnet" "pvt_subnet_platinum_aws" {
  count             = length(var.pvt_subent_cidr)
  vpc_id            = aws_vpc.platinum_aws.id
  cidr_block        = element(var.pvt_subent_cidr, count.index)
  availability_zone = element(var.region, count.index)
  tags = merge(
    local.comman_tags,
    {
      Name = "pvt-subnet-platinum-${count.index + 1}"
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
  count          = length(var.pvt_subent_cidr)
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
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_instance" "Pub" {
  count                       = length(var.pub_subnet_cidr)
  #count                       = 1
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.platinum_sg1.id]
  subnet_id                   = element(aws_subnet.pb_subnet_platinum_aws[*].id, count.index)
  availability_zone           = element(var.region, count.index)
  associate_public_ip_address = true
  tags = merge(
    local.comman_tags,
    {
      Name = "${var.Env}-pub-server-${count.index + 1}"
    }
  )
  user_data = <<-EOF
#!/bin/bash
sudo yum install git* wget nginx* -y
sudo echo "Copying the SSH Key Of Jenkins to the server"
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCPo9tb2e6PERHaf3gMG6TozhIKqNbhkR5T/5KNI3hDHO1KnIlw8or0kYoeSSMX4K00byxSn4DgOarknj4ZuINgfbmyNk81DJlTBBBHHU7duxsnHCiggFz9JhgpcyhqprLHh3EqBn9N3qRPOs9Ic7tVtXDRKtUt3P1/tJV1Jx2usBjlXa9MC6BsoOzdyauN5N/HOrslkO2KXR22sACfk5ccF/bHIKBROfiY9BEBuiCLeD6V8mRbNzb1169WuBFpQtYUofrKGEAmTJzjo957q8M/lRAOkxsxh95mgxwLi1SKamhKSB6RiutdsDopRHc18cmq560OJSCVaKEbEjQlDhXTyQ38w+2pQa4DDGC1NYOYnN4x4FNd7n0wtPfBU1dWoQvvQHWcW6t9ezuCQ3sgUoLKjlzbfDAEgn6RLGrkR7IbFdv2Ux4xuBbtG6Kc4Bp61b+xLC82XlOojDhz12kgkt3AaKJsQC4jgpicT6RI/9B4d/FLQaV4Whg8v9sMEBBFr0s= raoli@Bhuvika" >> /home/ec2-user/.ssh/authorized_keys
EOF
  
}
# resource "aws_instance" "Pvt" {
#   count                       = length(var.pvt_subent_cidr)
#   ami                         = var.ami
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   vpc_security_group_ids      = [aws_security_group.platinum_sg1.id]
#   subnet_id                   = element(aws_subnet.pvt_subnet_platinum_aws[*].id, count.index)
#   availability_zone           = element(var.region, count.index)
#   associate_public_ip_address = true
#   tags = merge(
#     local.comman_tags,
#     {
#       Name = "${var.Env}-pvt-server-${count.index + 1}"
#     }
#   )
#   user_data = <<EOF
#      yum install git* wget nginx* -y
#      echo "Copying the SSH Key Of Jenkins to the server"
#      echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCPo9tb2e6PERHaf3gMG6TozhIKqNbhkR5T/5KNI3hDHO1KnIlw8or0kYoeSSMX4K00byxSn4DgOarknj4ZuINgfbmyNk81DJlTBBBHHU7duxsnHCiggFz9JhgpcyhqprLHh3EqBn9N3qRPOs9Ic7tVtXDRKtUt3P1/tJV1Jx2usBjlXa9MC6BsoOzdyauN5N/HOrslkO2KXR22sACfk5ccF/bHIKBROfiY9BEBuiCLeD6V8mRbNzb1169WuBFpQtYUofrKGEAmTJzjo957q8M/lRAOkxsxh95mgxwLi1SKamhKSB6RiutdsDopRHc18cmq560OJSCVaKEbEjQlDhXTyQ38w+2pQa4DDGC1NYOYnN4x4FNd7n0wtPfBU1dWoQvvQHWcW6t9ezuCQ3sgUoLKjlzbfDAEgn6RLGrkR7IbFdv2Ux4xuBbtG6Kc4Bp61b+xLC82XlOojDhz12kgkt3AaKJsQC4jgpicT6RI/9B4d/FLQaV4Whg8v9sMEBBFr0s= raoli@Bhuvika" >> /home/ec2-user/.ssh/authorized_keys
#     EOF
# }
resource "null_resource" "remote_usedata" {
  count      = length(aws_instance.Pub[*].id)
  depends_on = [aws_instance.Pub]
  provisioner "file" {
    source      = "userdata.sh"
    destination = "/home/ec2-user/userdata.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/userdata.sh",
      "sudo /home/ec2-user/userdata.sh"
    ]
  }
  connection {
    type        = "ssh"
    host        = aws_instance.Pub[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.key_path)
  }
}
resource "local_file" "foo" {
  content  = templatefile("${var.tftpl}", { 
    pub_ip = aws_instance.Pub[*].public_ip
  })
  filename = var.local_file
}
resource "null_resource" "remote" {
  count      = length(aws_instance.Pub[*].id)
  depends_on = [aws_instance.Pub]
  provisioner "local-exec" {
    command = "echo ${aws_instance.Pub[count.index].public_ip} >> C:/Users/raoli/ip.txt"
  }
}