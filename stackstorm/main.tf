locals {
  user_data = <<EOF
#!/bin/bash
curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=st2admin --password='Ch@ngeMe'
EOF
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name          = "stackstorm"
  ami           = "ami-085925f297f89fce1"
  instance_type = "m4.xlarge"
  subnet_id     = var.subnet
  vpc_security_group_ids      = var.securitygroupids
  associate_public_ip_address = true
  key_name = var.keyname
  

  user_data = local.user_data

  

  tags = {
    "Env"      = "Private"
    "Location" = "Secret"
  }
}