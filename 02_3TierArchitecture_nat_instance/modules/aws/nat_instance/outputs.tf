output "instance_ids" {
  value = "${aws_instance.nat_instances.*.id}"
}

output "private_ips" {
  value = "${aws_instance.nat_instances.*.private_ip}"
}

output "public_ips" {
  value = "${aws_instance.nat_instances.*.public_ip}"
}

output "security_group_ids" {
  value = "${aws_security_group.nat.*.id}"
}
