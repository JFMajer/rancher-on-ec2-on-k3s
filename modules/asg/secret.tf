resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}

resource "random_password" "rancher_admin_password" {
  length  = 20
  special = true
}

resource "aws_ssm_parameter" "rancher_admin_password" {
  name  = "/${var.name_prefix}/rancher-admin-password-${random_pet.suffix.id}"
  type  = "SecureString"
  value = random_password.rancher_admin_password.result
}
