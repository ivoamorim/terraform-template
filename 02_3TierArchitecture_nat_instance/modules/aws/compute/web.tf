variable "web" {
  default = {
    instance_count   = 2
    type             = "t2.micro"
    root_volume_size = 8
  }
}

variable "web_security_groups" {
  type    = "list"
  default = []
}

module "web" {
  source = "../ec2"

  project     = "${var.project}"
  environment = "${var.environment}"
  role        = "Web"

  ami                         = "${data.aws_ami.debian.id}"
  subnet_id                   = "${var.private_subnet_id}"
  security_group_ids          = "${var.web_security_groups}"
  associate_public_ip_address = "false"

  instance_count   = "${lookup(var.web, "instance_count")}"
  instance_type    = "${lookup(var.web, "type")}"
  key_name         = "${var.key_name}"
  root_volume_size = "${lookup(var.web, "root_volume_size")}"
}

output "web_instance_ids" {
  value = "${module.web.instance_ids}"
}

output "web_private_ips" {
  value = "${module.web.private_ips}"
}

output "web_public_ips" {
  value = "${module.web.public_ips}"
}
