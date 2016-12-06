provider "aws" {
  region = "${var.region}"
}

# Elastic IPs for OpenSwan VPN instance

resource "aws_eip" "server_openswan" {
  vpc = true
  instance = "${aws_instance.server_openswan.id}"
}

# OpenSwan production instance related resources

resource "aws_security_group" "server_openswan" {
  name = "server_openswan_sg"
  description = "Security group for OpenSwan VPN instance"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "${var.vpc_cidr["non_production"]}",
      "${var.vpc_cidr["production"]}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${var.vpc["production"]}"

  tags {
    Name = "server-openswan-sg"
  }
}

resource "aws_instance" "server_openswan" {
  ami = "${var.ami["production_openswan"]}"
  availability_zone = "us-west-2a"
  instance_type = "${var.instance_type["openswan"]}"
  key_name = "${var.key}"
  security_groups = ["${aws_security_group.server_openswan.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  tags {
    Name = "NAT instance - openswan"
  }
}
