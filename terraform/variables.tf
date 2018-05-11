####################################
# Variables for the AWS platform
####################################
variable "org" {
  type = "string"
  default = "ORG"
}

variable "project" {
  type = "string"
  default = "PROJECT"
}

variable "env" {
  type = "map"
  default = {
    "aws" = "aws"
    "aws2" = "aws2"
    "open" = "open"
  }
}

variable "aws" {
  type = "map"
  default = {
    "count" = "1"
    "instance_type" = "t2.micro"
    "region" = "us-east-1"
    "zone" = "us-east-1b"
    "vpc_id" = ""
    "ami" = "ami-"
    "subnet_id" = "subnet-"
    "ssh_user_name" = "newuser"
    "ssh_user_password" = ""
  }
}

variable "aws_security_groups" {
  type = "list"
  default = ["sg-"]
}

variable "aws2" {
  type = "map"
  default = {
    "count" = "1"
    "instance_type" = "t2.micro"
    "region" = "us-east-1"
    "zone" = "us-east-1a"
    "vpc_id" = ""
    "ami" = "ami-"
    "subnet_id" = "subnet-"
    "address_consul" = ""
    "address_vault" = ""
    "ca_cert" = ""
    "ssh_key_file" = ""
    "ssh_user_name" = "newuser"
    "ssh_user_password" = ""
  }
}

variable "aws2_security_groups" {
  type = "list"
  default = ["sg-"]
}

variable "open" {
  type = "map"
  default = {
    "count" = "1"
    "instance_type" = ""
    "address_consul" = ""
    "address_vault" = ""
    "ca_cert" = ""
    "ssh_key_file" = ""
    "ssh_user_name" = "newuser"
    "ssh_user_password" = ""
  }
}