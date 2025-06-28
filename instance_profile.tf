# RKE2 All-in-One IAM Role (Control Plane + Worker)
resource "aws_iam_role" "rke2_node" {
  name = "rke2-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "rke2-node-role"
    Type = "kubernetes-node"
  }
}

# Combined IAM Policy for Control Plane + Worker
resource "aws_iam_policy" "rke2_node_policy" {
  name        = "rke2-node-policy"
  description = "IAM policy for RKE2 nodes (control plane + worker)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "ecr:*",
          "route53:*",
          "s3:*",
          "ssm:*",
          "ssmmessages:*",
          "ec2messages:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "elasticloadbalancing.amazonaws.com",
              "spot.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "rke2_node_policy_attachment" {
  role       = aws_iam_role.rke2_node.name
  policy_arn = aws_iam_policy.rke2_node_policy.arn
}

# Instance profile
resource "aws_iam_instance_profile" "rke2_node_profile" {
  name = "rke2-node-profile"
  role = aws_iam_role.rke2_node.name

  tags = {
    Name = "rke2-node-profile"
  }
}

# Outputs
output "node_instance_profile_name" {
  description = "Name of the RKE2 node instance profile"
  value       = aws_iam_instance_profile.rke2_node_profile.name
}

output "node_instance_profile_arn" {
  description = "ARN of the RKE2 node instance profile"
  value       = aws_iam_instance_profile.rke2_node_profile.arn
}
