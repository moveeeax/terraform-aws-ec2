terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region to deploy the example instance into."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

module "ec2" {
  source = "../.."

  name          = "example-instance"
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "instance_id" {
  value = module.ec2.id
}
