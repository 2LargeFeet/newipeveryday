variable "local_ip" {}
variable "cidr_block" {}
variable "cidr_subnet" {}
variable "private_key" {}
variable "private_key_file" {}
variable "transfer_pass" {}

data "aws_ami" "ubuntu" {
  most_recent           = true
  owners                = ["099720109477"] # Canonical
  filter {
    name              = "name"
    values            = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name              = "virtualization-type"
    values            = ["hvm"]
  }
}


resource "aws_vpc" "main" {
  cidr_block              = "${var.cidr_block}"
  enable_dns_hostnames    = true
}

resource "aws_internet_gateway" "external" {
  vpc_id                  = "${aws_vpc.main.id}"

  tags = {
    Name                  = "external"
  }
}

resource "aws_subnet" "external" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.cidr_subnet}"

  tags = {
    Name                  = "external"
  }
}

resource "aws_route_table" "external" {
  vpc_id                    = "${aws_vpc.main.id}"

  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = "${aws_internet_gateway.external.id}"
  }

  tags = {
    Name                    = "external"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id                 = "${aws_subnet.external.id}"
  route_table_id            = "${aws_route_table.external.id}"
}


resource "aws_security_group" "restrict" {
  name                    = "restrict"
  description             = "restrict access to server"
  vpc_id                  = "${aws_vpc.main.id}"

  ingress {
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = ["${var.local_ip}"]
  }

  ingress {
    from_port             = 1194
    to_port               = 1194
    protocol              = "udp"
    cidr_blocks           = ["${var.local_ip}"]
  }

  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["${var.local_ip}"]
  }

  ingress {
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
    cidr_blocks           = ["${var.local_ip}"]
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "t2.micro"
  key_name                = "${var.private_key}"
  vpc_security_group_ids  = ["${aws_security_group.restrict.id}"]
  subnet_id               = "${aws_subnet.external.id}"
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install aptitude -y",
      "sudo apt install python-pip -y",
      "sudo pip install ansible",
      "git clone https://github.com/2LargeFeet/newipeveryday.git",
      "sudo ansible-playbook newipeveryday/ipeveryday.yml --extra-vars='{\"server_ip\": ${aws_instance.vpn.public_ip}, \"transfer_pass\": ${var.transfer_pass}}'"
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = "${file(var.private_key_file)}"
    }
  }

  provisioner "local-exec" {
    command = "scp -i vpn.pem -o 'StrictHostKeyChecking no' ubuntu@${aws_instance.vpn.public_ip}:newipeveryday/client-config/client.ovpn client.ovpn"
    interpreter = ["PowerShell", "-Command"]
  }
}

output "ip" {
  value = "${aws_instance.vpn.public_ip}"
}
