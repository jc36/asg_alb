data "aws_vpcs" "default" {
  filter {
    name = "isDefault"
    values = ["true"]
  }
}
data "aws_subnet_ids" "default" {
  vpc_id = "${element(data.aws_vpcs.default.ids,0)}"
}

resource "aws_security_group" "sg4lb" {
  name        = "sg4lb"
  description = "Security group for LoaadBalancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg4lb"
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sg4lb.id}"]
  subnets            = ["${data.aws_subnet_ids.default.ids}"]
  tags {
    Name = "lb"
  }
}

resource "aws_lb_target_group" "tg" {
  name               = "tg"
  port               = 80
  protocol           = "HTTP"
  vpc_id             = "${element(data.aws_vpcs.default.ids,0)}"
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn  = "${aws_lb.alb.arn}"
  port               = "80"
  protocol           = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type   = "text/plain"
      status_code    = "500"
    }
  }
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = "${aws_lb_listener.lb_listener.arn}"
  condition {
    field            = "host-header"
    values           = ["${local.host_headers}"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg.arn}"
  }
}
