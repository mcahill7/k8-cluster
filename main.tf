#######
# AWS #
#######

provider "aws" {
  region  = "${var.aws_region}"
  shared_credentials_file = "${var.home}/.aws/credentials"
  profile = "${var.excella_aws_profile}"
}

##########
# CONFIG #
##########

terraform {
  backend "s3" {
    bucket = "mason"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
    encrypt = "True"
  }
}

##################
# Security Group #
##################

resource "aws_security_group" "bastion" {
  name = "bastion"
  description = "Bastion Host Port Rules"
}

resource "aws_security_group_rule" "allow_all" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "egress-port_80" {
  type            = "egress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "egress-port_443" {
  type            = "egress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "egress-port_22" {
  type            = "egress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.drone_ci.id}"
}

#############
# Instances #
#############

resource "aws_instance" "k8Bastion" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  root_block_device {
      delete_on_termination = "True"
    }
  tags {
    Name = "k8 Bastion"
  }

  security_groups = [ "${aws_security_group.bastion.name}" ]
  key_name        = "${var.excella_aws_pubkey_name}"
  provisioner "file" {
    # source = "docker-compose.yml"
    # destination = "/home/centos/docker-compose.yml"

    connection {
      type = "ssh"
      user = "centos"
      private_key = "${file("~/.ssh/${var.excella_aws_pubkey_name}")}"
    }
  }
}



resource "null_resource" "provision" {
  triggers {
    rerun = "${uuid()}"
  }
  connection {
    type = "ssh"
    user = "centos"
    private_key = "${file("~/.ssh/${var.excella_aws_pubkey_name}")}"
    host = "${aws_instance.k8bastion.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
      "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo yum install -y epel-release",
      "sudo yum install -y python-pip",
      "sudo pip install --upgrade pip",
      "sudo pip install docker-compose",
      "sudo yum upgrade python* -y",
    ]
  }
}
