variable "db" {
  default = {
    instance_count   = 2
    type             = "t2.micro"
    root_volume_size = 8
    var_volume_size  = 20
  }
}

variable "db_security_groups" {
  type    = "list"
  default = []
}


data "aws_subnet" "selected" {
  id = "${var.private_subnet_id}"
}


module "db" {
  source = "../ec2"

  project     = "${var.project}"
  environment = "${var.environment}"
  role        = "DB"

  ami                         = "${data.aws_ami.debian.id}"
  subnet_id                   = "${data.aws_subnet.selected.id}"
  security_group_ids          = "${var.db_security_groups}"
  associate_public_ip_address = "false"

  instance_count   = "${lookup(var.db, "instance_count")}"
  instance_type    = "${lookup(var.db, "type")}"
  key_name         = "${var.key_name}"
  root_volume_size = "${lookup(var.db, "root_volume_size")}"
}

module "var_volume" {
  source      = "../ebs"
  environment = "${var.environment}"
  project     = "${var.project}"
  name_prefix = "${var.project} ${var.environment} DB"

  subnet_id      = "${data.aws_subnet.selected.id}"
  instance_ids   = "${module.db.instance_ids}"
  instance_count = "${lookup(var.db, "instance_count")}"

  device_name = "/dev/xvdb"
  mount_point = "/var"
  size        = "${lookup(var.db, "var_volume_size")}"
  type        = "${lookup(var.db, "var_volume_type")}"

  prevent_destroy = "${lookup(var.db, "var_volume_prevent_destroy")}"
}

output "db_instance_ids" {
  value = "${module.db.instance_ids}"
}

output "db_private_ips" {
  value = "${module.db.private_ips}"
}

output "db_public_ips" {
  value = "${module.db.public_ips}"
}
