#
# terraform-managed-domain-filtering/modules/routing
#


resource aws_route route_from_subnet_to_tgw {
  count = length(var.route_table_ids)

  route_table_id         = var.route_table_ids[count.index]
  transit_gateway_id     = var.transit_gateway_id
  destination_cidr_block = var.destination_cidr

  # depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment] 呼び出しの方で依存関係を定義、ルーティングのほうにtgw、subnetを
}

resource aws_ec2_transit_gateway_route route_from_tgw_to_subnet {
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = var.gw_attachment_id
  destination_cidr_block         = var.destination_cidr
}
