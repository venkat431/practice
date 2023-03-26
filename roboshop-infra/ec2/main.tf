data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]
}
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_route53_record.route53.id]
  tags                   = {
    Name = var.component
  }
}

resource "aws_route53_record" "route53" {
  zone_id = "Z08931683BP7DV5GJ0PAA"
  name    = "${var.component}-${var.env}.devops-practice.tech"
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2.private_ip]
}

resource "aws_security_group" "sg" {
  name        = "${var.component}-${env}-sg"
  description = "${var.component}-${env}-sg"
  vpc_id      = aws_instance.ec2.private_ip

  ingress {
    description      = "SSH"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${env}-sg"
  }
}


variable "component" {}
variable "instance_type" {}
variable "env" {
  default = "dev"
}