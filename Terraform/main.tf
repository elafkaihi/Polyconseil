# main.tf

provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "wordpress-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wordpress-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Change this as needed

  tags = {
    Name = "wordpress-public-subnet"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"  # Change this as needed

  tags = {
    Name = "wordpress-private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"  # Change this as needed

  tags = {
    Name = "wordpress-private-subnet-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "wordpress-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "efs" {
  name        = "wordpress-efs-sg"
  description = "Allow NFS traffic for EFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-efs-sg"
  }
}

resource "aws_efs_file_system" "wordpress" {
  creation_token = "wordpress-efs"

  tags = {
    Name = "wordpress-efs"
  }
}

resource "aws_efs_mount_target" "public" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "private1" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "private2" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = aws_subnet.private2.id
  security_groups = [aws_security_group.efs.id]
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private2.id
}

output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}