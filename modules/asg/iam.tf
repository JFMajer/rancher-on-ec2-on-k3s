resource "aws_iam_role" "asg_instance_role" {
  name = "${var.name_prefix}-asg-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "asg_instance_profile" {
  name = "${var.name_prefix}-asg-ec2-profile"
  role = aws_iam_role.asg_instance_role.name
}

resource "aws_iam_policy" "asg_secrets_access" {
  name = "${var.name_prefix}-asg-secrets-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.rancher_admin_password.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "asg_attach_secrets_policy" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = aws_iam_policy.asg_secrets_access.arn
}

resource "aws_iam_role_policy_attachment" "asg_attach_ssm_managed" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
