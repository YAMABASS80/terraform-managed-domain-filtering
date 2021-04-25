

// modules/tgw/vpc-attachment.tf

variable vpc_id {}
variable subnet_ids {}
#variable route_table_ids {} 
variable transit_gateway_id {}
variable transit_gateway_route_table_id {}
#variable destination_vpc_cidr {}

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

/*
resource aws_route to-trgw {
  count = length(var.route_table_ids)
  route_table_id         = var.route_table_ids[count.index]
  transit_gateway_id     = var.transit_gateway_id
  destination_cidr_block = var.destination_vpc_cidr

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}
*/


output tgw_attachment_id {
  value = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}
