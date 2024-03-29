resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_d" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/25"
  availability_zone = "us-east-1d"
  
  tags = {
    "Name" = "public | us-east-1d"
  }
}

resource "aws_subnet" "private_id" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = "us-east-1d"

  tags = {
    "Name" = "private | us-east-1d"
  }
}

resource "aws_subnet" "public_e" {
  vpc_id            = aws_vpc.app_vpc.id // Fixed from `aws_vpc.app_vpc.if` to `aws_vpc.app_vpc.id`
  cidr_block        = "10.0.1.128/25"
  availability_zone = "us-east-1e"

  tags = {
    "Name" = "public | us-east-1e" // Corrected the tag value for consistency
  }
}

resource "aws_subnet" "private_e" {
  vpc_id            = aws_vpc.app_vpc.id // Fixed from `aws_vpc.app_vpc.vpc_id` to `aws_vpc.app_vpc.id`
  cidr_block        = "10.0.2.128/25"
  availability_zone = "us-east-1d"

  tags = {
    "Name" = "private | us-east-1d"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id // Fixed from `aws_vpc.app_vpc.vpc_id` to `aws_vpc.app_vpc.id`
  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id // Fixed from `aws_vpc.app_vpc.vpc_id` to `aws_vpc.app_vpc.id`
  tags = {
    "Name" = "private"
  }
}

// Fixed the association of subnets to the correct route tables
resource "aws_route_table_association" "public_d_subnet" {
  subnet_id      = aws_subnet.public_d.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_d_subnet" {
  subnet_id      = aws_subnet.private_id.id // Fixed to correctly reference `private_id` subnet
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_e_subnet" {
  subnet_id      = aws_subnet.public_e.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_e_subnet" {
  subnet_id      = aws_subnet.private_e.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_d.id // Fixed from `aws_subnet.public_d.vpc_id` to `aws_subnet.public_d.id`
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic" // Corrected from `descriptiom` to `description`
  vpc_id      = aws_vpc.app_vpc.id // Fixed from `aws_vpc.app_vpc.vpc_id` to `aws_vpc.app_vpc.id`

  ingress {
    from_port   = 80 // Corrected from `fropm_port` to `from_port`
    to_port     =
