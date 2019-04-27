provider "aws" {
}

resource "aws_key_pair" "kp" {
  key_name    = "${local.key_name}"
  public_key  = "${local.pub_key}"
}

resource "aws_security_group" "sg4instances" {
  name        = "sg4instances"
  description = "Security group for instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.ssh_allow}"]
  }

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
    Name = "sg4instances"
  }
}

resource "aws_launch_configuration" "lc" {
  name                        = "${local.lc_name}"
  image_id                    = "${data.aws_ami.ami.id}"
  instance_type               = "${local.instance_type}"
  security_groups             = ["${aws_security_group.sg4instances.id}"]
  key_name                    = "${aws_key_pair.kp.key_name}"
  user_data                   = "${local.user_data}"
}

resource "aws_autoscaling_group" "asg" {
  name                        = "${local.asg_tag_name}"
  max_size                    = "${local.max_instance_size}"
  min_size                    = "${local.min_instance_size}"
  desired_capacity            = "${local.desired_capacity}"
  launch_configuration        = "${aws_launch_configuration.lc.name}"
  availability_zones          = ["${local.az_list}"]
  target_group_arns           = ["${aws_lb_target_group.tg.arn}"]
  tags = [{
    key                       = "Name"
    value                     = "${local.asg_tag_name}"
    propagate_at_launch       = true
  },{
    key                       = "Type"
    value                     = "${local.asg_tag_type}"
    propagate_at_launch       = true
  }]
}


