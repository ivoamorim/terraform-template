region = "us-east-2"

project = "3TierArchitecture"

environment = "Devel"

vpc_cidr = "192.168.0.0/23"

availability_zones = ["us-east-2a"]

public_subnets = ["192.168.1.0/24"]

db = {
  instance_count             = 0
  type                       = "t2.micro"
  root_volume_type           = "gp2"
  root_volume_size           = 8
  var_volume_size            = 20
  var_volume_type            = "gp2"
  var_volume_prevent_destroy = false
}

loadbalancer = {
  instance_count   = 0
  type             = "t2.micro"
  root_volume_type = "gp2"
  root_volume_size = 8
}

web = {
  instance_count   = 0
  type             = "t2.micro"
  root_volume_type = "gp2"
  root_volume_size = 8
}
