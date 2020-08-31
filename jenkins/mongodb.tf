resource "aws_key_pair" "mongodb" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtqGS3ZvH1SqYzSZ3u+86Rf07xAzvY+Ba4pv/NBCexx8MmlcQE+TxeYeTMowLcHCSM5A4eY5vrwbWjJLtIZ+LH9zkqT/LptZVM49nBLmw7VCq8H+zO0QkSlZnoPILvJNNbVazZDgQPzAK4U/3PgUwlALitbNrCJn74A9b28O1ciEOwDLDgN+xqDGGVlmKOll8OCNiOUU/7K20OVU+CT2CrjTPZRbECFGDB9ShJcdwjy2VtBzvR7ja/8vlb8zZUDsKCUXZNelwUPqHLKc7EAXNDeTNZPHaIHsFxiVAzi7OVA3NKaYx7UsvLSvHLNzRInE553ib8aD0GnB7O7nQbDldGw== Jorge Flores"
}

resource "aws_security_group" "mongodb" {
  name        = "mongodb"
  description = "Allow all inbound SSH and MongoDB traffic."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    description = "MongoDB access"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "MongoDB"
  }
}

module "mongodb" {
  source = "../../"

  aws_region        = "us-east-2"
  availability_zone = "us-east-2a"
  instance_type     = "t2.micro"
  volume_size       = "10"
  key_name          = "${aws_key_pair.mongodb.key_name}"
  private_key       = "${file("${path.module}/keys/mongodb")}"
  security_groups   = ["${aws_security_group.mongodb.name}"]
}