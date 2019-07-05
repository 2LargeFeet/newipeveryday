variable "ssh_key_name" {}
variable "local_ip" {}
variable "cidr_block" {}
variable "cidr_subnet" {}
variable "private_key" {}
#variable "certificate_email" {}
#variable "subdomain_name" {}

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
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${aws_security_group.restrict.id}"]
  subnet_id               = "${aws_subnet.external.id}"
  associate_public_ip_address = true

#  provisioner "file" {
#    source      = "rsa_vars"
#    destination = "~/rsa_vars"
#  }

  provisioner "remote-exec" {
    inline = [
#      "sudo add-apt-repository -y ppa:certbot/certbot",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install aptitude -y",
      "sudo apt install python-pip -y",
      "sudo pip install ansible",
      "git clone https://github.com/2LargeFeet/tfvpn.git",
      "sudo ansible-playbook tfvpn/ipeveryday.yml --extra-vars='{\"server_ip\": ${aws_instance.vpn.public_ip}',"
#      "sudo apt install software-properties-common openvpnas openssl certbot -y",
#      "sudo service openvpnas stop",
#      "sudo certbot certonly --standalone --non-interactive --agree-tos --email ${var.certificate_email} --domains ${var.subdomain_name} --pre-hook 'service openvpnas stop' --post-hook 'service openvpnas start'",
#      "sudo service openvpnas start",
#      "wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.5/EasyRSA-nix-3.0.5.tgz",
#      "tar xvf EasyRSA-nix-3.0.5.tgz",
#      "cp rsa_vars EasyRSA-3.0.5/vars", # adjust to fit your specifics
#      "echo -en '\n\n\n\n\n\n\n'| ./EasyRSA-3.0.5/easyrsa init-pki",
#      "./EasyRSA-3.0.5/easyrsa build-ca nopass",
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = "${file(var.private_key)}"
    }
  }
}

output "ip" {
  value = "${aws_instance.vpn.public_ip}"
}
