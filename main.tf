terraform {
   backend "remote" {
     organization = "9incloud"

      workspaces {
        name = "dev-workspace"
      }
   }
}

variable "awsprops" {
    type = map
    default = {
      region = "ap-northeast-1"
      profile = "dev"
      vpc = "vpc-0e30a506ba92b3912"
      ami = "ami-0ecb2a61303230c9d"
      itype = "t2.micro"
      subnet = "subnet-0c3348ffc23de5584"
      publicip = true
      keyname = "myseckey"
      secgroupname = "IAC-Sec-Group"
   }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
  # profile only for local
#   profile = lookup(var.awsprops, "profile")
}

module "vpc" {
  source = "./modules/vpc"
  region = lookup(var.awsprops, "region")
}


resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
#   key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]

  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}


output "ec2instanceip" {
  value = aws_instance.project-iac.public_ip
}