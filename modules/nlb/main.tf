resource "aws_lb" "rancher_nlb" {
  name               = "${var.name_prefix}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.rancher_nlb_sg.id]
}

resource "aws_lb_target_group" "rancher_nlb" {
  name     = "${var.name_prefix}-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    path                = "/ping"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTPS"
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.rancher_nlb.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_nlb.arn
  }
}


resource "aws_security_group" "rancher_nlb_sg" {
  name        = "${var.name_prefix}-nlb-sg"
  description = "Allow HTTPS traffic to NLB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}