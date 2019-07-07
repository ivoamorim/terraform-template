module "db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.17.0"

  name        = "${var.project} ${var.environment} DB"
  description = "Security group for MySQL"
  vpc_id      = "${var.vpc_id}"

  ingress_with_self = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL from DB"
    },
  ]

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow MySQL from Web"
      source_security_group_id = "${module.web.this_security_group_id}"
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Terraform   = "true"
  }
}
