module "vpc" {
  app_name = "dev-vpc"
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  env      = "dev"
  public_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
  private_subnet_cidrs = [
    "10.0.20.0/24",
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
  multi_az_nat_gateway = false
}

module "alb" {
  source          = "./modules/alb"
  name_prefix     = "rancher"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets_ids
  certificate_arn = aws_acm_certificate_validation.rancher_cert_validation.certificate_arn
  domain_name     = var.rancher_domain_name
  http_node_port  = var.http_node_port
}

module "rancher_server" {
  source               = "./modules/asg"
  name_prefix          = "rancher"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets_ids
  rancher_domain_name  = var.rancher_domain_name
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  alb_target_group_arn = module.alb.alb_target_group_arn
  alb_sg_id            = module.alb.alb_sg_id
  http_node_port       = var.http_node_port
}