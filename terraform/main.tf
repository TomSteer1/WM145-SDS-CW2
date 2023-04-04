terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Variables used throughout the config, these can be changed in the terraform.tfvars file
variable "vpc_cidr" {
  description = "cidr block for the VPC"
  default = "10.28.0.0/28"
  type = string
}


variable "subnet_cidr" {
  description = "cidr block for the subnet"
  default = "10.28.0.0/28"
   type = string
}

variable "server-availability-zone" {
  description = "Availbility zone useed for our instanance"
  default = "eu-west-2a"
   type = string
}

variable "server-instance-type" {
  description =  "Instance type used for the notes server"
  default = "t2.micro"
   type = string
}

variable "server-region" {
  description = "Region that the server will be deployed in"
  default = "eu-west-2"
   type = string
}

variable "ssh-ec2-key" {
 description = "Name of the ssh key created for the ec2 instance"
 type = string
}

variable "eip-allocation-id" {
	description = "Elastic IP allocation ID"
	type = string
}


provider "aws" {
  region = var.server-region
}


# 1. Create VPC 
resource "aws_vpc" "notes-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "tom-oscar-notes-vpc"
  }
}


# 2. Create Internet Gateway
resource "aws_internet_gateway" "notes-igw" {
  vpc_id = aws_vpc.notes-vpc.id

  tags = {
    Name = "tom-oscar-notes-igw"
  }
}


# 3. Create a Route Table
resource "aws_route_table" "notes-route-table" {
  vpc_id = aws_vpc.notes-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.notes-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.notes-igw.id
  }

  tags = {
    Name = "tom-oscar-notes-rt"
  }
}


# 4. Create Subnet
resource "aws_subnet" "pub-subnet-a" {
  vpc_id            = aws_vpc.notes-vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.server-availability-zone

  tags = {
    Name = "tom-oscar-pub-subnet-a"
  }
}


# 5. Assign route table to subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub-subnet-a.id
  route_table_id = aws_route_table.notes-route-table.id
}


# 6. Create security group to allow ssh, http & https
resource "aws_security_group" "allow-ssh-http-s" {
  name        = "allow_web_ssh"
  description = "Allow TLS inbound traffic & HTTP(s)"
  vpc_id      = aws_vpc.notes-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
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
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tom-oscar-Security-Group"
  }
}


# 7. Create a network interface in the subnet
resource "aws_network_interface" "notes-server-nic" {
  subnet_id       = aws_subnet.pub-subnet-a.id
  private_ips     = ["10.28.0.10"]
  security_groups = [aws_security_group.allow-ssh-http-s.id]
}


# 8. Assign elastic IP to the NIC
#resource "aws_eip" "one" {
#  vpc                       = true
#  network_interface         = aws_network_interface.notes-server-nic.id
#  associate_with_private_ip = "10.28.0.10"
#  depends_on                = [aws_internet_gateway.notes-igw]
#}

resource "aws_eip_association" "one" {
	allocation_id = var.eip-allocation-id
	network_interface_id = aws_network_interface.notes-server-nic.id
}

# 9. Create ec2 instance to host app
resource "aws_instance" "notes-server-instance" {
  ami               = "ami-0ad97c80f2dfe623b"
  instance_type     = var.server-instance-type
  availability_zone = var.server-availability-zone
  key_name          = "oscar-sharpe-ssh"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.notes-server-nic.id
  }

  user_data = "${file("user-data.sh")}"
	tags = {
    Name = "tom-oscar-notes-server"
  }
}


# Outputs server information after provisioning infrastructure
output "server_private_ip" {
  value = aws_instance.notes-server-instance.private_ip

}
#output "server_public_ip" {
#  value = aws_eip.one.public_ip
#}

output "server_id" {
  value = aws_instance.notes-server-instance.id
}

