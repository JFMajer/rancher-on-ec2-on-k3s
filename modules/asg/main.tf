data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_launch_template" "rancher_lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    rancher_password    = aws_ssm_parameter.rancher_admin_password.value,
    rancher_domain_name = var.rancher_domain_name,
    http_node_port      = var.http_node_port
  }))

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-asg"
    }
  }
}

resource "aws_autoscaling_group" "rancher_asg" {
  name                      = "${var.name_prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  target_group_arns         = [var.alb_target_group_arn]
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.rancher_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.name_prefix}-asg-sg"
  description = "Security group for ASG EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.http_node_port
    to_port         = var.http_node_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
