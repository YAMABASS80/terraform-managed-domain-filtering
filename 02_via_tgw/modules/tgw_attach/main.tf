#
# terraform-managed-domain-filtering/modules/tgw_attach/
# 

resource aws_ec2_transit_gateway_vpc_attachment vpc_attachment {
  subnet_ids                                      = var.subnet_ids
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = var.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}
resource aws_ec2_transit_gateway_route_table_association association {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
resource aws_ec2_transit_gateway_route_table_propagation propagation {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
