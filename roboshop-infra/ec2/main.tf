data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]
}
resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type

  tags = {
    Name = var.component
  }
}

resource "aws_route53_record" "route53" {
  zone_id = aws_instance.ec2.id
  name    = "${var.component}-${var.env}.devops-practice.tech"
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2.private_ip]
}


variable "component" {}
variable "instance_type" {}
variable "env" {
  default = "dev"
}