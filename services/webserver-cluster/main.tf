provider "aws" {
  region = "eu-central-1"
}

locals {
  any_port         = 0
  http_port        = 80
  app_port         = 8080
  any_protocol     = "-1"
  tcp_protocol     = "TCP"
  default_ssh_port = 22
  all_ips          = ["0.0.0.0/0"]
}

resource "aws_launch_template" "example" {
  image_id               = "ami-0b2ac948e23c57071"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sc-instance-example.id]

  user_data = filebase64("${path.module}/user-data-web-server.sh")
  lifecycle {
    create_before_destroy = true
  }
  key_name = var.ssh_key_name
}

resource "aws_security_group" "sc-instance-example" {
  name = "${var.cluster_name}-sc"

  ingress {
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id = aws_launch_template.example.id
  }
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "tf-mng-asg"
    propagate_at_launch = true
  }
}

resource "aws_alb" "example" {
  name               = "${var.cluster_name}-asg-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-asg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-lb"

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
