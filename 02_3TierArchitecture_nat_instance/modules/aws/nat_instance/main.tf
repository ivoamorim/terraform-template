data "aws_subnet" "privates" {
  count = "${var.instance_count}"
  id    = "${var.private_subnet_ids[count.index]}"
}

data "aws_subnet" "publics" {
  count = "${var.instance_count}"
  id    = "${var.public_subnet_ids[count.index]}"
}

data "aws_route_table" "selected" {
  count     = "${var.instance_count}"
  subnet_id = "${data.aws_subnet.privates.*.id[count.index]}"
}


resource "aws_security_group" "nat" {
  count = "${var.instance_count}"

  name        = "${var.name_prefix}${count.index + 1} Security Group"
  description = "Enable internal traffice to go to external"
  vpc_id      = "${data.aws_subnet.publics.*.vpc_id[count.index]}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all incoming traffic from private subnet"
    cidr_blocks = ["${data.aws_subnet.privates.*.cidr_block[count.index]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outgoing traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.name_prefix} Security Group"
    Terraform = "true"
  }
}

resource "aws_instance" "nat_instances" {
  count = "${var.instance_count}"

  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${data.aws_subnet.publics.*.id[count.index]}"

  vpc_security_group_ids = ["${aws_security_group.nat.*.id[count.index]}"]

  disable_api_termination = "${var.disable_api_termination}"
  key_name                = "${var.key_name}"
  source_dest_check       = "false"

  root_block_device = {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    ignore_changes        = ["ami"]
    create_before_destroy = true
  }

  tags {
    Name      = "${var.name_prefix}${count.index + 1}"
    Terraform = "true"
  }
}

resource "aws_route" "nat" {
  count                  = "${var.instance_count}"
  instance_id            = "${aws_instance.nat_instances.*.id[count.index]}"
  route_table_id         = "${data.aws_route_table.selected.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
}