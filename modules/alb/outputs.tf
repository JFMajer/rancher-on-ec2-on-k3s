output "alb_dns_name" {
  value = aws_lb.rancher_alb.dns_name
}

output "alb_arn" {
  value = aws_lb.rancher_alb.arn
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.rancher_alb.arn
}

output "alb_sg_id" {
  value = aws_security_group.rancher_alb_sg.id
}

output "zone_id" {
  value = aws_lb.rancher_alb.zone_id
}