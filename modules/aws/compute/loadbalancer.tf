variable "loadbalancer" {
  default = {
    instance_count   = 1
    type             = "t2.micro"
    root_volume_size = 8
  }
}

variable "loadbalancer_security_groups" {
  type    = "list"
  default = []
}

module "loadbalancer" {
  source = "../ec2"

  project     = "${var.project}"
  environment = "${var.environment}"
  role        = "Loadbalancer"

  ami                = "${data.aws_ami.debian.id}"
  subnet_id          = "${var.subnet_id}"
  security_group_ids = "${var.loadbalancer_security_groups}"

  instance_count   = "${lookup(var.loadbalancer, "instance_count")}"
  instance_type    = "${lookup(var.loadbalancer, "type")}"
  key_name         = "${var.key_name}"
  root_volume_size = "${lookup(var.loadbalancer, "root_volume_size")}"
}

module "eips" {
  source = "../eip"

  project     = "${var.project}"
  environment = "${var.environment}"
  name_prefix = "${var.project} ${var.environment} Loadbalancer"

  instance_ids   = "${module.loadbalancer.instance_ids}"
  instance_count = "${lookup(var.loadbalancer, "instance_count")}"
}

output "gateway_instance_ids" {
  value = "${module.loadbalancer.instance_ids}"
}

output "gateway_private_ips" {
  value = "${module.loadbalancer.private_ips}"
}

output "gateway_public_ips" {
  value = "${module.loadbalancer.public_ips}"
}
