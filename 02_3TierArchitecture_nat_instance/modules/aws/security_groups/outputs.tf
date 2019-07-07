output "common_id" {
  value = "${module.common.this_security_group_id}"
}

output "db_id" {
  value = "${module.db.this_security_group_id}"
}

output "loadbalancer_id" {
  value = "${module.loadbalancer.this_security_group_id}"
}

output "web_id" {
  value = "${module.web.this_security_group_id}"
}
