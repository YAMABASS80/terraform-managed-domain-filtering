module "gw_vpc"{
  source = "../../modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
}

module "user_vpc_A" {
  source = "../../modules/user_vpc"
  user_vpc = {
    cidr_block = "100.64.0.0/20"
    vpc_name = "UserVpcA"
    subnet_names = [
      "private_subnet_A0",
      "private_subnet_A1"
    ]
  }
}

module "user_vpc_B" {
  source = "../../modules/user_vpc"
  user_vpc = {
    cidr_block = "100.64.16.0/20"
    vpc_name = "UserVpcB"
    subnet_names = [
      "private_subnet_B0",
      "private_subnet_B1"
    ]
  }
}

module "network_firewall_with_nat" {
  source = "../../modules/network_firewall_with_nat"
  igw_id = module.gw_vpc.igw_id
  firewall_subnet_az_1 = module.gw_vpc.firewall_subnet_1_id
  firewall_subnet_az_2 = module.gw_vpc.firewall_subnet_2_id
  public_subnet_az_1 = module.gw_vpc.public_subnet_1_id
  public_subnet_az_2 = module.gw_vpc.public_subnet_2_id
  public_subnet_1_route_table_id = module.gw_vpc.public_subnet_1_route_table_id
  public_subnet_2_route_table_id = module.gw_vpc.public_subnet_2_route_table_id
}

module "tgw" {
  source = "../../modules/tgw"
}

module user_A_attachment {
  source = "../../modules/tgw_attach"
  vpc_id                         = module.user_vpc_A.vpc_id
  subnet_ids                     = module.user_vpc_A.subnet_ids
  #route_table_ids                = module.user_vpc_A.route_table_ids
  transit_gateway_id             = module.tgw.tgw_id
  transit_gateway_route_table_id = module.tgw.route_table_id
  #destination_vpc_cidr           = "0.0.0.0/0"

  depends_on = [module.tgw, module.user_vpc_A]
}

module user_B_attachment {
  source = "../../modules/tgw_attach"
  vpc_id                         = module.user_vpc_B.vpc_id
  subnet_ids                     = module.user_vpc_B.subnet_ids
  #route_table_ids                = module.user_vpc_B.route_table_ids
  transit_gateway_id             = module.tgw.tgw_id
  transit_gateway_route_table_id = module.tgw.route_table_id
  #destination_vpc_cidr           = "0.0.0.0/0"

  depends_on = [module.tgw, module.user_vpc_B]
}

module gwvpc_attachment {
  source = "../../modules/tgw_attach"
  vpc_id                         = module.gw_vpc.vpc_id
  subnet_ids                     = module.gw_vpc.subnet_ids
  #route_table_ids                = module.gw_vpc.route_table_ids
  transit_gateway_id             = module.tgw.tgw_id
  transit_gateway_route_table_id = module.tgw.route_table_id
  #destination_vpc_cidr           = module.user_vpc_A.cidr_block

  depends_on = [module.tgw, module.gw_vpc]
}

module routing_from_uservpc_to_gwvpc {
  source = "../../modules/routing"
  route_table_ids                 = concat(module.user_vpc_A.route_table_ids, module.user_vpc_B.route_table_ids)
  transit_gateway_id              = module.tgw.tgw_id
  transit_gateway_route_table_id  = module.tgw.route_table_id
  gw_attachment_id                = module.gwvpc_attachment.tgw_attachment_id
  destination_cidr                = "0.0.0.0/0"

  depends_on = [module.user_A_attachment, module.user_B_attachment, module.gwvpc_attachment]
}

module routing_from_gwvpc_to_user_A {
  source = "../../modules/routing"
  route_table_ids                 = module.gw_vpc.route_table_ids
  transit_gateway_id              = module.tgw.tgw_id
  transit_gateway_route_table_id  = module.tgw.route_table_id
  gw_attachment_id                = module.user_A_attachment.tgw_attachment_id
  destination_cidr                = module.user_vpc_A.cidr_block

  depends_on = [module.user_A_attachment, module.gwvpc_attachment]
}

module routing_from_gwvpc_to_user_B {
  source = "../../modules/routing"
  route_table_ids                 = module.gw_vpc.route_table_ids
  transit_gateway_id              = module.tgw.tgw_id
  transit_gateway_route_table_id  = module.tgw.route_table_id
  gw_attachment_id                = module.user_B_attachment.tgw_attachment_id
  destination_cidr                = module.user_vpc_B.cidr_block

  depends_on = [module.user_B_attachment, module.gwvpc_attachment]
}
