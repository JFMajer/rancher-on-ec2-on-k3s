# Rancher on AWS EC2 with Terraform (LAB/Non-HA Setup)

This project provisions a **lab/demo environment** for Rancher on AWS using EC2, Application Load Balancer (ALB), and Route53, all managed by Terraform. It aims to provide a **one-click deployment** of Rancher for experimentation, running in **non-HA mode** (single K3s instance, no production guarantees).

## Features
- VPC with public and private subnets
- EC2 Auto Scaling Group (set to 1 instance) for Rancher server
- Application Load Balancer (ALB) with HTTPS termination
- Route53 DNS records for Rancher domain
- ACM certificate with DNS validation
- Secure secrets management with AWS Secrets Manager
- SSM access for EC2 instances (no SSH needed)
- Automated K3s and Rancher installation via user-data
- Configurable NodePort for Rancher HTTP service

## ⚠️ Lab/Non-HA Disclaimer
- This setup is **not for production**. It runs Rancher in single-node (non-HA) mode for learning, testing, or demos.
- All stateful data is on a single EC2 instance. If the instance is lost, so is your Rancher data.
- For production, use Rancher HA with an external database and at least 3 nodes.

## Module Structure
- `modules/vpc`: VPC, subnets, and networking resources
- `modules/alb`: Application Load Balancer and target group
- `modules/asg`: Auto Scaling Group (set to 1), EC2 launch template, IAM, and user-data for Rancher

## Customization
- Change the K3s or Rancher version in `modules/asg/user-data.sh` if needed.
- Adjust instance types, scaling parameters, or disk sizes in module variables.
- To use a different NodePort, set `http_node_port` in `variables.tf` and ensure your security groups and ALB target group use this value.

## Security
- EC2 instance is only accessible via the ALB on the configured NodePort.
- SSM access is enabled for management without SSH.
- Secrets are managed via AWS Secrets Manager.

## Cleanup
To destroy all resources:
```sh
terraform destroy
```
