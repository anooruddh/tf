# Define AWS as our provider
provider "aws" {
  shared_credentials_file = "/root/.aws/credentials"
  region     = "ap-south-1"
}
# Define our VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "anoo-vpc"
  }
}
# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "ap-south-1b"

  tags {
    Name = "anoo-subnet"
  }
}
# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "anoo-igw"
  }
}
# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "anoo-route-table"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sg" {
  name = "anoo-sec-group"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.vpc.id}"

  tags {
    Name = "anoo-sec-group"
  }
}
# Define webserver inside the public subnet
resource "aws_instance" "awsinstance" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name   = "ag1KeyPair"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sg.id}"]
   associate_public_ip_address = true
   source_dest_check = false
  tags {
    Name = "guddu-instance-1"
  }
}
