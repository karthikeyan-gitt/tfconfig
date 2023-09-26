############## Installation of Jenkins#######################
resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    "Name" = "Jenkins"
  }
  key_name              = aws_key_pair.serverkey.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    sudo dnf install java-11-amazon-corretto -y
    sudo yum install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
  EOF
}



resource "aws_key_pair" "serverkey" {
   key_name = "serverkey"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFr2P/DeVyECdIQMpyOMNCEIH4zsVYsP4JVA4WwLXT9kgBkQHnSRENGSlCJbdfKNvwfTHGuHcYTnVCAItqy8T+1uWB0cH/9l0ZfRycHi8zZVplQBoRJqpVVIA8j0j2KDiOhV4aShc/Khnr9tD6/oi831gEPv+b5Xi4nBcEujXa/Jn8eCOXThVMy7QaEIY4TLsrkf+f6bq0jGjr8ikW0P99xFogr1COwSInHi1Z1Ki5uzZtWq147hsSu899OzdI3Id0P8E5fFiedhzAa9NJ6iqs3K0bRkbj3OhFk9WLng490GcdJRpqxixO83CHNS+M15YNoNstcDNzE0im6gCTpsOL karthi@karthik-5977"
}


resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"
  dynamic "ingress" {
    for_each = var.jenkinsports
    content {
     from_port = ingress.value
     to_port = ingress.value
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
###########################################
###### Installation of Sonar ############################
resource "aws_instance" "sonar" {
  ami = var.ami
  instance_type = var.sonartype
  tags = {
    "Name" = "SonarQube"
  }
  key_name              = aws_key_pair.serverkey.id
  vpc_security_group_ids = [aws_security_group.sonar_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install java-1.8.0 -y
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.6.zip
    sudo unzip sonarqube-7.6.zip -d /opt/sonar76
    sudo groupadd sonar
    sudo useradd -c "Sonar System User" -d /opt/sonar76 -g sonar -s /bin/bash sonar
    sudo chown -R sonar:sonar /opt/sonar76
    sudo cd /opt/sonar76/sonarqube-7.6/bin/linux-x86-64/
    sudo su sonar
    ./sonar.sh start
  EOF
}
resource "aws_security_group" "sonar_sg" {
  name = "sonar_sg"
  dynamic "ingress" {
    for_each = var.jenkinsports
    content {
     from_port = ingress.value
     to_port = ingress.value
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}
}
  egress = local.outbound
}

locals {
  outbound = {
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      }
  }
}
##########################################################
