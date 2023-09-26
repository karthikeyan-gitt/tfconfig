variable "ami" {
 default = "ami-067c21fb1979f0b27"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "jenkinsports" {
   default = [ 22,8080 ]
}

variable "sonarport" {
   default = [ 22,9000 ]
}

variable "nexusport" {
   default = [ 22,8081 ]
}

variable "tomcatport" {
   default = [ 80,443,22,8080 ]
}
