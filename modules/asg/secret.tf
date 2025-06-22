resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}

resource "aws_secretsmanager_secret" "rancher_admin_password" {
  name = "${var.name_prefix}-rancher-admin-password-${random_pet.suffix.id}"
}

resource "aws_secretsmanager_secret_version" "rancher_admin_password_version" {
  secret_id     = aws_secretsmanager_secret.rancher_admin_password.id
  secret_string = random_password.rancher_admin_password.result
}

resource "random_password" "rancher_admin_password" {
  length  = 20
  special = true
}
