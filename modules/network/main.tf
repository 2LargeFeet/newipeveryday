data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "external" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "external"
  }
}

resource "aws_subnet" "external" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_subnet

  tags = {
    Name = "external"
  }
}

resource "aws_route_table" "external" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.external.id
  }

  tags = {
    Name = "external"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.external.id
  route_table_id = aws_route_table.external.id
}

resource "aws_security_group" "restrict" {
  name        = "restrict"
  description = "restrict access to server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}