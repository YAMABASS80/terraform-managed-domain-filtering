#
# terraform-managed-domain-filtering/modules/tgw_attach/
# 

output tgw_attachment_id {
  value = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
}
