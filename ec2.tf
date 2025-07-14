resource "aws_instance" "Public_server_1" {
  ami                         = var.ami
  instance_type               = var.type
  key_name                    = "test"

  vpc_security_group_ids      = [data.terraform_remote_state.base_infra.outputs.sg1]
  subnet_id                   = data.terraform_remote_state.base_infra.outputs.sub_id
  associate_public_ip_address = true
  #availability_zone = "us-east-1a"
  #    user_data = <<  EOF
  #    #!/bin/bash
  #sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
  #sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  #sudo systemctl restart sshd.service
  #sudo sed -i 's/disable_root: true/disable_root: false/g' /etc/cloud/cloud.cfg
  #sudo echo "root:abc123" | sudo chpasswd
  #EOF

  tags = {
    Name    = "Public_server_1"
    Account = "RR"
  }
}
