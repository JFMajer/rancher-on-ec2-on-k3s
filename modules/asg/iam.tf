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

resource "aws_iam_policy" "asg_ssm_access" {
  name = "${var.name_prefix}-asg-ssm-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Effect   = "Allow"
      Resource = aws_ssm_parameter.rancher_admin_password.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "asg_attach_ssm_policy" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = aws_iam_policy.asg_ssm_access.arn
}

resource "aws_iam_role_policy_attachment" "asg_attach_ssm_managed" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
