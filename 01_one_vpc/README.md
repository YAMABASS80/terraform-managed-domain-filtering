# Managed with domain filtering for outbound traffic from AWS VPC

## Overview

![Architecture](./img/arch.svg)


## Description
When running an application on a VPC, enterprise companies often limit inbound HTTP traffic as part of company's security measures. This is primarily to prevent applications from accessing malicious domains. 

Traditionally, in this situation, many companies build and operate an explicit forward proxy server, however there are always two problems.

1. Scalability  
   Outbound traffic used across the enterprise requires a large amount of bandwidth, which requires a lot of resources and traffic shaping on proxy servers.
2. Application compatibility  
   As not all application allows users to specify proxy servers for outbound access, those "proxy-unaware" applications were not available on the corporate network.

## Solution
With [AWS Network Firewall](https://aws.amazon.com/network-firewall/?nc1=h_ls&whats-new-cards.sort-by=item.additionalFields.postDateTime&whats-new-cards.sort-order=desc), you can build managed domain filtering solution **without having any proxy servers**. Network Firewall allows you to filter the outbound traffic from your VPC to unfavorable domains. Addition to the wider bandwidth, it provides application transparent domain filtering, where applications are no longer required to configure any explicit proxy servers.  

## Quick Starts
This solution is build on top of [Terraform](https://www.terraform.io/), so you need to have some familiarity to deploy it.

1. Get AWS Account
2. Setup IAM user and access, secret keys
3. Install [tfenv](https://github.com/tfutils/tfenv)
4. Install terraform cli tool version `0.14.7` or above, via tfevn
   ```bash
   tfenv install 0.14.7
   ```
5. set Terraform version
   ```bash
   tfenv use 0.14.7
   ```
6. Configure your Terraform state backend  
   In order to make the deployment stable, it is highly recommend to store your Terraform state file in Amazon S3, or equivalent cloud storage. in `envs/dev/backend.tf` file, you can specify your own amazon S3 bucket.
   ```HCL
    terraform {
        backend "s3" {
            bucket = "<YOUR OWN S3 BUCKET NAME>"
            key    = "<STATE FILE NAME>"
            region = "<S3 REGION>"
        }
    }   
   ```
7. Configure your the AWS region to deploy  
   In `envs/dev/provider.tf` file, 
   ```HCL
   provider "aws" {
      region = "<YOUR REGION TO DEPLOY>"
   }
   ```   
     
8. Initialize Terraform  
   ```bash
   cd envs/dev
   terraform init
   ```
9.  Configure **Allowed Domain List**  
   Now this is the most fun part. In `envs/dev`, you will see `allowed_domains.yml` file. This file is the list to which the application on private subnet to access. You can add, delete the domain list as you want.   
   `IMPORTANT`
   This solution is basically "Allowed List", so the domains that is not on the `allowed_domains.yml`, they are going to be `DENIED`.
11. Deploy it.
    ```bash
    terraform apply
    ```
## How do you play with it
Once you spin up your resources defined by this Terraform files, you can create your EC2 instance to play with. Now this network assumes EC2 instances are not connected to the internet, you should utilize [AWS SSM Session Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/session-manager.html) to jump in to your test instance.

1. [Install SSM Session Manager Plugin to your AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

2. [Set your AWS credential to your environment](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

3. [Create IAM Role for EC2 Instance](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html)  
You just create EC2 IAM Role and attache AWS Managed Policy **AmazonSSMManagedInstanceCore**

4. Create your EC2 instances on **private subnet**  
Note that you don't need to open security group for any SSH port. You can use **default** security group in this case. 

5. Jump in to the test instance
```bash
aws ssm start-session --target <YOUR EC2 INSTANCE ID>
```

Now this is the moment you are probably excited. Once you can jump in to your test box, the easiest way to test it out is to use *curl* command


```bash
curl -vvvv https://www.microsoft.com
```
It works. You can get contents from the server but, 

```bash
curl -vvvv https://www.twitter.com
```
In this case you won't get any response from the server. This is because the network firewall blocks the traffic. You can also check the CloudWatch Logs if your traffic is allowed or denied. 

Happy Traffic Control! :-)

## Solution Specific Resources

### Firewall Gateway
Firewall gateway is a gateway that handle the traffic. It's pretty unique so if you want to more dive deep you should check [this blog](https://aws.amazon.com/jp/blogs/aws/aws-network-firewall-new-managed-firewall-service-in-vpc/).

### SSM Endpoints
Why is here? Because it prevent from being disconnected from your EC2 located on private subnet.   
If you added some domain related to AWS endpoint in `allowed_domains.yml`, what would happened? You would lose your connection to your app because Firewall Gateway would block the traffic too. In order to prevent this situation, SSM endpoints allow your to bypass Network firewall, so you can keep your connection whatever you did wrong. 

# I/O for each components

Please follow Input and Output following.

## `main.tf` 

<details>

### Variables

| Variable | Type | Description |
| ------------- | ------------- | ------------- |
| vpc_cidr_block  | `String`  | Automatically create `/24` subnets in the VPC, so please specify larger CIDR range.  |

### Outputs

| Output | Type | Description |
| ------------- | ------------- | ------------- |
| igw  | `String`  | Internet Gateway (IGW) ID. |
| firewall_subnet_1_id  | `String`  | Firewall subnet ID located in first availability zone. |
| firewall_subnet_2_id  | `String`  | Firewall subnet ID located in second availability zone. |
| public_subnet_1_id  | `String`  | Public subnet ID located in first available zone. |
| public_subnet_2_id  | `String`  | Public subnet ID located in second available zone. |
| public_subnet_1_route_table_id  | `String`  | Route table ID for public subnet ID located in first available zone. |
| public_subnet_2_route_table_id  | `String`  | Route table ID for public subnet ID located in second available zone. |

</details>

## `modules/network_firewall_with_nat`

<details>

### Variables

| Variables | Type | Description |
| ------------- | ------------- | ------------- |
| igw  | `String`  | Internet Gateway (IGW) ID. |
| firewall_subnet_az_1  | `String`  | Firewall subnet ID located in first availability zone. |
| firewall_subnet_az_2  | `String`  | Firewall subnet ID located in second availability zone. |
| public_subnet_az_1  | `String`  | Public subnet ID located in first available zone. |
| public_subnet_az_2  | `String`  | Public subnet ID located in second available zone. |
| public_subnet_1_route_table_id  | `String`  | Route table ID for public subnet ID located in first available zone. |
| public_subnet_1_route_table_id  | `String`  | Route table ID for public subnet ID located in second available zone. |

### Output

No output defined.

</details>

