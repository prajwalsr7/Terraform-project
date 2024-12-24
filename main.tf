terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

#create a VPC
resource "aws_vpc" "prajwal-prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Prajwal-vpc"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prajwal-prod-vpc.id
}

# Create a custom route table
resource "aws_route_table" "prajwal-route-table" {
  vpc_id = aws_vpc.prajwal-prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prajwal-route-table"
  }
}

#create a subnet
resource "aws_subnet" "prajwal-subnet" {
  vpc_id     = aws_vpc.prajwal-prod-vpc.id
  cidr_block = var.subnet_prefix[0].cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

resource "aws_subnet" "prajwal-subnet2" {
  vpc_id     = aws_vpc.prajwal-prod-vpc.id
  cidr_block = var.subnet_prefix[1].cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[1].name
  }
}

#Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prajwal-subnet.id
  route_table_id = aws_route_table.prajwal-route-table.id
}

#create security group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prajwal-prod-vpc.id

  ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

    ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
  
    ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#create a network interface
resource "aws_network_interface" "prajwal-nic" {
  subnet_id       = aws_subnet.prajwal-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

#create a ubuntu server and instll/enable apache2
resource "aws_instance" "prajwal-ec2" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "prajwal-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.prajwal-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "Your very first web server" | sudo tee /var/www/html/index.html
                EOF
  tags = {
    Name = "prajwal web server"
  }
}

#Create an elastic ip for public access
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.prajwal-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gw ]
}

output "public_ip" {
  value = aws_eip.one.public_ip
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"

}










