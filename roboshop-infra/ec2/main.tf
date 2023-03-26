data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]
}
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags                   = {
    Name = var.component
  }
}

resource "null_resource" "provisioner" {
  provisioner "remote-exec" {

    host     = aws_instance.ec2.private_ip
    user     = "centos"
    password = "DevOps321"

 /*   inline [
      "git clone https://github.com/venkat431/practice"
      "cd roboshop-shell"
      "sudo bash ${var.component}.sh"
      ]*/
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
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"

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
    Name = "${var.component}-${var.env}-sg"
  }
}


variable "component" {}
variable "instance_type" {}
variable "env" {
  default = "dev"
}