# Rancher on AWS EC2 with Terraform (LAB/Non-HA Setup)

This project provisions a **lab/demo environment** for Rancher on AWS using EC2, Network Load Balancer (NLB), Application Load Balancer (ALB), and Route53, all managed by Terraform. It aims to provide a **one-click deployment** of Rancher for experimentation, running in **non-HA mode** (single K3s instance, no production guarantees).

## Features
- VPC with public and private subnets
- EC2 Auto Scaling Group (set to 1 instance) for Rancher server
- Network Load Balancer (NLB) for TCP traffic
- Route53 DNS records for Rancher domain
- SSM access for EC2 instances (no SSH needed)
- Automated K3s and Rancher installation via user-data

## ⚠️ Lab/Non-HA Disclaimer
- This setup is **not for production**. It runs Rancher in single-node (non-HA) mode for learning, testing, or demos.
- All stateful data is on a single EC2 instance. If the instance is lost, so is your Rancher data.
- For production, use Rancher HA deployed on something like EKS.

## Module Structure
- `modules/vpc`: VPC, subnets, and networking resources
- `modules/nlb`: Network Load Balancer and target group
- `modules/asg`: Auto Scaling Group (set to 1), EC2 launch template, IAM, and user-data for Rancher

## Customization
- Change the K3s or Rancher version in `modules/asg/user-data.sh` if needed.
- Adjust instance types, scaling parameters, or disk sizes in module variables.

## Security
- EC2 instance is only accessible via the NLB.
- SSM access is enabled for management without SSH.

## Cleanup
To destroy all resources:
```sh
terraform destroy
```
