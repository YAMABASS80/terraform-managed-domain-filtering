#
# terraform-managed-domain-filtering/modules/user_vpc
#

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

resource "aws_vpc" "user_vpc" {
  cidr_block = var.user_vpc.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.user_vpc.vpc_name
  }
}

resource "aws_subnet" "user_private_subnets" {
  // count = length(data.aws_availability_zones.available.zone_ids)
  count = 2

  cidr_block = cidrsubnet(var.user_vpc.cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = var.user_vpc.subnet_names[count.index]
  }
  vpc_id = aws_vpc.user_vpc.id
}

resource "aws_route_table" "user_private_routes" {
  // count = length(var.production-vpc-private.public_subnets)
  count = 2
  vpc_id = aws_vpc.user_vpc.id
}

resource "aws_route_table_association" "user_route_association" {
  // count = length(var.production-vpc-private.public_subnets)
  count = 2
  subnet_id = aws_subnet.user_private_subnets[count.index].id
  route_table_id = aws_route_table.user_private_routes[count.index].id
}


## SSM Session Manager Endpoints

resource "aws_security_group" "endpoint_sg" {
  name = "uservpc_endpoint_sg"
  description = "Endpoint Security Group for HTTPS"
  vpc_id = aws_vpc.user_vpc.id
  ingress {
      cidr_blocks = [ aws_vpc.user_vpc.cidr_block ]
      description = "Allow https within VPC"
      protocol = "tcp"
      from_port = 443
      to_port = 443
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.user_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids = [aws_subnet.user_private_subnets[0].id, aws_subnet.user_private_subnets[1].id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.user_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids = [aws_subnet.user_private_subnets[0].id, aws_subnet.user_private_subnets[1].id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.user_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids = [aws_subnet.user_private_subnets[0].id, aws_subnet.user_private_subnets[1].id]
}


