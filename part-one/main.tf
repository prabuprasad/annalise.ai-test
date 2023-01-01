## Configure AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

## Creating custom_vpc
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Custom VPC"
  }
}

## Creating Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "1a"

  tags = {
    Name = "Private Subnet"
  }
}

## Attach internet Gateway to VPC
resource "aws_internet_gateway" "test_ig" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "test Internet Gateway"
  }
}

## Create route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.test_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

##Route table association
resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

## Create Security Group to Allow Trafic
resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.some_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Create EC2 instance
## Command to create key pair : aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > ~/.ssh/MyKeyPair.pem
chmod 400  ~/.ssh/MyKeyPair.pem

resource "aws_instance" "web_instance" {
  ami           = "ami-0533f2ba8a1995cf9"
  instance_type = "t2.micro"
  key_name      = "MyKeyPair"

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex

  amazon-linux-extras install nginx1 -y
  echo "<h1>"Hello, World"</h1>" >  /usr/share/nginx/html/index.html 
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    "Name" : "HelloWorld"
  }
}