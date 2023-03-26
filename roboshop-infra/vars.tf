variable "component" {
  frontend ={
    name="frontend"
    type ="t3.micro"
  }
  mongodb ={
    name="mongodb"
    type ="t3.micro"
  }
  catalogue ={
    name="catalogue"
    type ="t3.micro"
  }
}