variable "home" {
  default = "/home/mcahill"
}

variable "excella_aws_profile" {
  default = "excella"
}

variable "excella_aws_pubkey_name" {
  default = "mcahill2"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "availability_zone" {
  default = "us-east-2b"
}

variable "ami" {
  default = "ami-31c7f654"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "docker_version" {
  default = "17.06.0.ce-1.el7.centos"
}
