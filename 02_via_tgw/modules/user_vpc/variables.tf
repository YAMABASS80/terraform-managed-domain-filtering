#
# terraform-managed-domain-filtering/modules/user_vpc
#

variable user_vpc {
/*
    cidr_block
    vpc_name
    subnet_names[]
*/
}

variable "instance" {
  /*
    instance_name=<Instance name>
    ami_id=<AMI ID>
    iam_role=<IAM Role for Instance>
  */
}
