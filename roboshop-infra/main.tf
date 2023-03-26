module "ec2" {
  source = "./ec2"
  component= [var.component]["name"]
  instance_type= var.component["type"]
}