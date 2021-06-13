# Routing of subnet and Transit Gateway

# Parameters
|  Name  |  Type  | Description  |
| ---- | ---- | ---- |
|  vpc_cidr_block  |  string  | VPC CIDR range  |
| user_vpc.cidr_block |  string  | VPC CIDR range  |
| user_vpc.vpc_name |  string  | VPC name |
| user_vpc.subnet_names |  list  | Subnet names |
| instance.instance_name |  string  | Instance name |
| instance.ami_id |  string  | AMI ID |
| instance.iam_role |  string  | IAM Role for Instance |

# Outputs
|  Name  |  Type  | Description  |
| ---- | ---- | ---- |
| vpc_id | string | VPC ID|
| subnet_ids | list | List of Subnet IDs |
| route_table_ids | list | List of Route Table IDs |
| cidr_block | string | CIDR range |
