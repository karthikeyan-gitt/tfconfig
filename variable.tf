variable "ami" {
 default = "ami-067c21fb1979f0b27"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "tag" {
  type = set(string)
  default = [
     "jenkins",
     "sonar",
     "nexus",
     "tomcat"
]
}

variable "ingress-ports" {
   default = [ 22,80,443,8080,9000,8081 ]
}
