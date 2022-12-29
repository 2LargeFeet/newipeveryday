data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vpn" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.private_key
  vpc_security_group_ids      = [var.security_group]
  subnet_id                   = var.subnet
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo add-apt-repository ppa:deadsnakes/ppa -y",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install aptitude -y",
      "sudo apt install python3-pip -y",
      "sudo pip install ansible",
      "git clone https://github.com/2LargeFeet/newipeveryday.git",
      "sudo ansible-playbook newipeveryday/modules/instance/configs/ipeveryday.yml --extra-vars='{\"server_ip\": ${aws_instance.vpn.public_ip}}'",
    ]

    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_file)
    }
  }

  provisioner "local-exec" {
    command     = "scp -i vpn.pem -o 'StrictHostKeyChecking no' ubuntu@${aws_instance.vpn.public_ip}:newipeveryday/client-config/client.ovpn client.ovpn"
    interpreter = ["PowerShell", "-Command"]
  }
}

output "ip" {
  value = aws_instance.vpn.public_ip
}