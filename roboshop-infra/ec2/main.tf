resource "aws_ami" "ami" {
  name   = "centos-8-devops-practice"
  owners = "973714476881"

}
resource "aws_instance" "ec2" {
  ami           = aws_ami.ami.id
  instance_type = var.instance_type

  tags = {
    name="${var.component}"
  }


}

variable "component" {}
variable "instance_type" {}
