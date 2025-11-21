##############################
# Provider configuration
##############################

terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

##############################
# VPC
##############################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "final-devops-vpc"
  }
}

##############################
# Internet Gateway
##############################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "final-devops-igw"
  }
}

##############################
# Subnets (2 public)
##############################

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

##############################
# Route Table
##############################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

##############################
# Security Group
##############################

resource "aws_security_group" "ec2_sg" {
  name        = "final-devops-ec2-sg"
  description = "Allow SSH, HTTP"
  vpc_id      = aws_vpc.main.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "final-devops-ec2-sg"
  }
}

##############################
# EC2 Instances (3 nodes)
##############################

resource "aws_instance" "nodes" {
  count               = 3
  ami                 = var.ec2_ami
  instance_type       = var.ec2_type
  subnet_id           = (count.index % 2 == 0 ? aws_subnet.public_a.id : aws_subnet.public_b.id)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "final-devops-node-${count.index + 1}"
  }
}

##############################
# Load Balancer
##############################

resource "aws_lb" "alb" {
  name               = "final-devops-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "final-devops-alb"
  }
}

##############################
# Target Group
##############################

resource "aws_lb_target_group" "tg" {
  name     = "final-devops-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    protocol = "HTTP"
    path     = "/"
    matcher  = "200"
  }
}

##############################
# Register EC2 to Target Group
##############################

resource "aws_lb_target_group_attachment" "attachments" {
  count            = 3
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.nodes[count.index].id
  port             = 80
}

##############################
# Listener
##############################

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

##############################
# Outputs
##############################

output "alb_dns" {
  value = aws_lb.alb.dns_name
}
