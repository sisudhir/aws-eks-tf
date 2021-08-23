variable "region" {
  type = string
  description = "AWS region"
}

variable "access_key" {
  type = string
  description = "AWS access key"
}

variable "secret_key" {
  type = string
  description = "AWS access key id"
}

 variable "cluster_name" {
  type = string
  description = "Name of the K8s cluster to be created"
}
variable "vpc_name" {
  type = string
  description = "Name of the vpc name to be created"
}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.cluster_name}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "${var.vpc_name}"
  cidr                 = "10.100.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24", "10.100.4.0/24"]
  public_subnets       = ["10.100.5.0/24", "10.100.6.0/24", "10.100.7.0/24", "10.100.8.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
