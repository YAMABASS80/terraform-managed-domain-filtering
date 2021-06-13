#
# terraform-managed-domain-filtering/modules/tgw
#

resource aws_ec2_transit_gateway tgw {
  vpn_ecmp_support                = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"
}

resource aws_ec2_transit_gateway_route_table tgw_route {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

