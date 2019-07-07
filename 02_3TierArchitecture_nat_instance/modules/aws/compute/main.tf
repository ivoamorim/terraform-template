data "aws_ami" "debian" {
  most_recent = true
  owners      = [379101102735]

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
}
