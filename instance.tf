variable "ssh_key_name" {}
variable "local_ip" {}

data "aws_ami" "ubuntu" {
    most_recent           = true

    filter {
        name              = "name"
        values            = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name              = "virtualization-type"
        values            = ["hvm"]
    }

    owners                = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block              = "10.23.0.0/16"
}

resource "aws_subnet" "external" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.23.0.0/24"

  tags = {
    Name                  = "external"
  }
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

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}


#resource "aws_key_pair" "operator" {
#  key_name               = "${var.ssh_key_name}"
#  public_key             = ${file("public.key")
#}

resource "aws_instance" "instance" {
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "t2.micro"
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${aws_security_group.restrict.id}"]
  subnet_id               = "${aws_subnet.external.id}"
  associate_public_ip_address = true
}

output "ip" {
  value = "${aws_instance.instance.public_ip}"
}
