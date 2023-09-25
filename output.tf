output "jenkins" {
   value = aws_instance.server["jenkins"].public_ip
#  value = [ for instance in aws_instance.server: instance.public_ip ]
}

output "tomcat" {
    value = aws_instance.server["tomcat"].public_ip
}

output "sonar" {
    value = aws_instance.server["sonar"].public_ip
}

output "nexus" {
   value = aws_instance.server["nexus"].public_ip
}