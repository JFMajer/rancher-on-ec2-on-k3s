output "asg_name" {
  value = aws_autoscaling_group.rancher_asg.name
}

output "asg_lt_id" {
  value = aws_launch_template.rancher_lt.id
}
