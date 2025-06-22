# Rancher on AWS EC2 with Terraform (LAB/Non-HA Setup)

This project provisions a **lab/demo environment** for Rancher on AWS using EC2, Application Load Balancer (ALB), and Route53, all managed by Terraform. It is designed for quick bootstrapping and experimentation, running Rancher in **non-HA mode** (single K3s instance, no production guarantees).

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

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- A registered domain in Route53

## Usage

1. **Clone the repository:**
   ```sh
   git clone <this-repo-url>
   cd rancher_ec2
   ```

2. **Configure variables:**
   - Edit `variables.tf` to set your domain, region, and other parameters as needed.
   - The default NodePort for Rancher HTTP is `31069` (can be changed via `http_node_port` variable).
   - By default, only **one** Rancher instance is created (non-HA).

3. **Initialize Terraform:**
   ```sh
   terraform init
   ```

4. **Plan the deployment:**
   ```sh
   terraform plan
   ```

5. **Apply the configuration:**
   ```sh
   terraform apply
   ```

6. **Access Rancher:**
   - After deployment, Rancher will be available at `https://<your-domain>`
   - The admin password is stored in AWS Secrets Manager.

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
