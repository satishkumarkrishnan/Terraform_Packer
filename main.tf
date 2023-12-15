terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.2.0"
    }
  }
}

module "vpc" {
  source ="git@github.com:satishkumarkrishnan/terraform-aws-vpc.git?ref=main"
}


resource "aws_vpc" "vpc" {
  cidr_block           = module.vpc.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  #vpc_id = aws_vpc.vpc.id
  vpc_id = module.vpc.vpc_id
  
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = module.vpc.vpc_fe_subnet
  
}

resource "aws_route_table" "rtb_public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.vpc_ig
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = module.vpc.vpc_fe_subnet.id
  route_table_id = module.vpc.vpc_rt
}

resource "aws_security_group" "sg_22_80" {
  name   = "sg_22"
  vpc_id = module.vpc.vpc_id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0c20d1e87e986f2cc"
  instance_type               = "t2.micro"
  #subnet_id                   = aws_subnet.subnet_public.id  
  subnet_id                   = module.vpc.vpc_fe_subnet.id  
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  associate_public_ip_address = true

  tags = {
    Name = "Learn-Packer"
  }
}