## ASG ###
locals {
  asg_tag_name      = "example"
  asg_tag_type      = "webserver"
  max_instance_size = "1"
  min_instance_size = "1"
  desired_capacity  = "1"
}


## LC ###
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}
locals {
  lc_name          = "webservers"
  instance_type    = "t3.micro"
  user_data        = "${file("userdata.sh")}"
  az_list = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}


### KP ###
locals {
  key_name         = "webservers"
  pub_key          = "${file(".ssh/key.pem.pub")}"
}


### SG for instances ###
data "http" "myip" {
  url = "http://ifconfig.co"
}
locals {
  ssh_allow = [
    "${chomp(data.http.myip.body)}/32",
    "11.22.33.44/32"
  ]
}

### LB rule ###
locals {
  host_headers = ["www.example.com"]
}