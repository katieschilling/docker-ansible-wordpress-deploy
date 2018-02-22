provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_key_pair" "auth" {
  key_name   = "MyNVKeyPair"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_security_group" "default" {
  name        = "default_sg"
  description = "Default security group for ssh and http access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "http" {
  name        = "http_sg"
  description = "Security group for http access only"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_elb" "web" {
  name = "terraform-elb"
  availability_zones = ["${aws_instance.web.*.availability_zone}"]
  security_groups    = ["${aws_security_group.http.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.web.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags {
    Name = "blog-terraform-elb"
  }
}

resource "aws_instance" "web" {
  instance_type   = "${var.server_size}"
  ami             = "${lookup(var.aws_amis, var.aws_region)}"
  security_groups = ["${aws_security_group.default.name}"]
  count           = "${var.number_servers}"
  key_name = "MyNVKeyPair"
  tags {
    Name = "blog-terraform-elb-${count.index}"
  }
  provisioner "remote-exec" {
    #use local ssh agent
    inline = ["echo Connection success!"]
    connection {
      user = "ubuntu"
    }
  }

}


output "ip" {
  value = "${aws_elb.web.dns_name}"
}
