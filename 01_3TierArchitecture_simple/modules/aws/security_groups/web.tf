module "web" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.17.0"

  name        = "${var.project} ${var.environment} Web"
  description = "Security group for HTTP Server"
  vpc_id      = "${var.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Allow HTTP from Loadbalancer"
      source_security_group_id = "${module.loadbalancer.this_security_group_id}"
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Allow HTTPS from Loadbalancer"
      source_security_group_id = "${module.loadbalancer.this_security_group_id}"
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Terraform   = "true"
  }
}
