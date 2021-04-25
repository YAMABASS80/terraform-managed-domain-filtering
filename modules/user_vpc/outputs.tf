#
# terraform-managed-domain-filtering/modules/user_vpc
#

output vpc_id{
  value=aws_vpc.user_vpc.id
}
output subnet_ids{
  value=[aws_subnet.user_private_subnets[0].id, aws_subnet.user_private_subnets[1].id]
}
output route_table_ids{
  value=[aws_route_table.user_private_routes[0].id,aws_route_table.user_private_routes[1].id]
}
output cidr_block{
  value=aws_vpc.user_vpc.cidr_block
}
