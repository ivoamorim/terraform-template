variable "project" {}
variable "environment" {}

variable "vpc_cidr" {}

variable "availability_zones" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

variable "db" {
  type = "map"
}

variable "loadbalancer" {
  type = "map"
}

variable "web" {
  type = "map"
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = [379101102735]

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
}

module "network" {
  source = "../../../modules/aws/network"

  project     = "${var.project}"
  environment = "${var.environment}"

  vpc_cidr           = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"
  public_subnets     = "${var.public_subnets}"
}

module "security_groups" {
  source = "../../../modules/aws/security_groups"

  project     = "${var.project}"
  environment = "${var.environment}"

  vpc_id = "${module.network.vpc_id}"

  bastion_security_group_id = "${module.bastion.bastion_security_group_id}"
}

module "bastion" {
  source = "../../../modules/aws/bastion"

  name_prefix = "${var.project} ${var.environment} Bastion"
  ami         = "${data.aws_ami.debian.id}"
  subnet_id   = "${module.network.public_subnets[0]}"
  key_name    = "TestKey"
}

module "compute" {
  source = "../../../modules/aws/compute"

  project     = "${var.project}"
  environment = "${var.environment}"

  subnet_id = "${module.network.public_subnets[0]}"

  key_name = "TestKey"

  db           = "${var.db}"
  loadbalancer = "${var.loadbalancer}"
  web          = "${var.web}"

  db_security_groups           = ["${module.security_groups.common_id}", "${module.security_groups.db_id}"]
  loadbalancer_security_groups = ["${module.security_groups.common_id}", "${module.security_groups.loadbalancer_id}"]
  web_security_groups          = ["${module.security_groups.common_id}", "${module.security_groups.web_id}"]
}
