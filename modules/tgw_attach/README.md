#  Attachment of Transit Gateway

# Parameters
|  Name  |  Type  | Description  |
| ---- | ---- | ---- |
| vpc_id | string | VPC ID |
| subnet_ids | list | List of subnet IDs |
| transit_gateway_id | string | Transit Gateway ID |
| transit_gateway_route_table_id | string | Route Table ID of Transit Gateway |

# Outputs
|  Name  |  Type  | Description  |
| ---- | ---- | ---- |
| tgw_attachment_id | string | Attachment ID of Transit Gateway |
