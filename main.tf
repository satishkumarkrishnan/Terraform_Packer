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



resource "aws_instance" "web" {
  ami                         = "ami-0c20d1e87e986f2cc"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.vpc_fe_subnet.id  
  vpc_security_group_ids      = [module.vpc.vpc_fe_sg]
  associate_public_ip_address = true

  tags = {
    Name = "Tokyo-Packer"
  }
  depends_on = [module.vpc]
}