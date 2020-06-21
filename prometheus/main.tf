data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name          = "prometheus"
  ami           = "ami-085925f297f89fce1"
  instance_type = "m4.large"
  subnet_id     = var.subnetid
  vpc_security_group_ids      = var.securitygroupids
  associate_public_ip_address = true
  key_name = var.key_name
  

  user_data = user_data = "${file("install.sh")}"
  

  tags = {
    "Env"      = "Private"
    "Location" = "Secret"
  }
}