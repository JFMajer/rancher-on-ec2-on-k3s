resource "aws_iam_user" "rancher_provisioner" {
  name = "rancher-provisioner"
}

resource "aws_iam_user_policy_attachment" "rancher_provisioner_ec2_admin" {
  user       = aws_iam_user.rancher_provisioner.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}