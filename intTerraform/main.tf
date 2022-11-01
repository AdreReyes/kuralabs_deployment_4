variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
  
}

resource "aws_instance" "web_server01" {
  ami                     = "ami-08c40ec9ead489470"
  instance_type           = "t2.micro"
  key_name                = "adrekeytoherheart"
  subnet_id               = "${aws_subnet.prod-subnet-public-1.id}"
  vpc_security_group_ids  = [aws_security_group.web_ssh.id]

  user_data = "${file("deploy.sh")}"

  tags = {
    "Name" : "Webserver001"
  }
  
}

output "instance_ip" {
  value = aws_instance.web_server01.public_ip
  
}

module "vpc" {
      resource "aws_vpc" "prod-vpc" {
       cidr_block           = "10.0.0.0/16"
       enable_dns_support   = "true" #gives you an internal domain name
       enable_dns_hostnames = "true" #gives you an internal host name
       instance_tenancy     = "default"    
    
    tags = {
        "Name" : "prod-vpc"
    }
}
}

module "network" {
     resource "aws_internet_gateway" "prod-igw" {
         vpc_id = "${aws_vpc.prod-vpc.id}"
         
    tags = {
         "Name" : "prod-igw"
     }
     }
}
     resource "aws_subnet" "prod-subnet-public-1" {
    vpc_id                  = "${aws_vpc.prod-vpc.id}"
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone       = "us-east-1a"
    tags = {
      "Name" : "prod-subnet-public-1"
      }
      }

     resource "aws_route_table" "public-crt" {
     vpc_id = "${aws_vpc.main-vpc.id}"
    
     resource "aws_route_table_association" "crta-public-subnet-1"{
     subnet_id      = "${aws_subnet.crta-public-subnet-1.id}"
     route_table_id = "${aws_route_table.public-crt.id}"
     }

     route {
         //associated subnet can reach everywhere
         cidr_block = "10.0.0.0/16" 
         //CRT uses this IGW to reach internet
         gateway_id = "${aws_internet_gateway.prod-igw.id}" 
     }
    
     tags = {
         "Name" : "prod-public-crt"
     }

        }
