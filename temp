###### Installation of Sonar ############################
resource "aws_instance" "sonar2" {
  ami = var.ami
  instance_type = var.sonartype
  tags = {
    "Name" = "SonarQube1"
  }
  key_name              = aws_key_pair.serverkey.id
  vpc_security_group_ids = [aws_security_group.sonar1_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install java-1.8.0*  -y
    cd /home/ec2-user
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.6.zip
    sudo unzip sonarqube-7.6.zip -d /opt/sonar76
    sudo groupadd sonar
    sudo useradd -c "Sonar System User" -d /opt/sonar76 -g sonar -s /bin/bash sonar
    sudo chown -R sonar:sonar /opt/sonar76
    cd /opt/sonar76/sonarqube-7.6/bin/linux-x86-64/
    sudo -u sonar sh  sonar.sh start
  EOF
}
resource "aws_security_group" "sonar1_sg" {
  name = "sonar1_sg"
  dynamic "ingress" {
    for_each = var.sonarport
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
