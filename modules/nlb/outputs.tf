output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.rancher_nlb.arn
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.rancher_nlb.dns_name
}

output "nlb_zone_id" {
  description = "Zone ID of the Network Load Balancer"
  value       = aws_lb.rancher_nlb.zone_id
}

output "nlb_target_group_arn" {
  description = "ARN of the NLB target group"
  value       = aws_lb_target_group.rancher_nlb.arn
}

output "nlb_sg_id" {
  description = "Security Group ID associated with the NLB (if any)"
  value       = aws_security_group.rancher_nlb_sg.id
}
