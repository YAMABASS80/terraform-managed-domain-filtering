#
# terraform-managed-domain-filtering/modules/tgw
#

output tgw_id{
  value=aws_ec2_transit_gateway.tgw.id
}

output route_table_id{
  value=aws_ec2_transit_gateway_route_table.tgw_route.id
}