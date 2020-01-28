# Setting a provider
provider "aws" {
  region = "eu-west-1"
}

# Creating a VPC
resource "aws_vpc" "python_app_vpc"{
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.tags
  }
}

# Internet Gateway
resource "aws_internet_gateway" "python_app_gw" {
  vpc_id = aws_vpc.python_app_vpc.id
  tags = {
    Name = var.tags
  }
}

# Creating a Subnet
resource "aws_subnet" "python_app_subnet" {
  vpc_id = aws_vpc.python_app_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = var.tags
  }
}

# Route Table
resource "aws_route_table" "python_app_route" {
  vpc_id = aws_vpc.python_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.python_app_gw.id
  }

  tags = {
    Name = var.tags
  }
}

# Route Table Association
resource "aws_route_table_association" "python_app_assoc" {
  subnet_id = aws_subnet.python_app_subnet.id
  route_table_id = aws_route_table.python_app_route.id
}

# Creating a Security Group
resource "aws_security_group" "python_app_sg" {
  name = var.tags
  vpc_id = aws_vpc.python_app_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["212.161.55.68/32", "86.141.168.180/32"]
  }
}


# Launching an Instance
resource "aws_instance" "python_app_instance" {
  ami = var.ami-id
  subnet_id = aws_subnet.python_app_subnet.id
  vpc_security_group_ids = [aws_security_group.python_app_sg.id]
  instance_type = "t2.micro"
  associate_public_ip_address = true
  user_data = data.template_file.app_init.rendered
  tags = {
    Name = var.tags
  }
}

# Send template sh file to instance
data "template_file" "app_init" {
  template = "${file("./scripts/init_script.sh.tpl")}"
}
