

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

variable user_vpc {
/*
    cidr_block
    vpc_name
    subnet_names[]
*/
}

resource "aws_vpc" "user_vpc" {
  cidr_block = var.user_vpc.cidr_block
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

output vpc_id{
  value=aws_vpc.user_vpc.id
}
output subnet_ids{
  value=[aws_subnet.user_private_subnets[0].id, aws_subnet.user_private_subnets[1].id]
}
output route_table_ids{
  value=[aws_route_table.user_private_routes[0].id,aws_route_table.user_private_routes[1].id]
}
