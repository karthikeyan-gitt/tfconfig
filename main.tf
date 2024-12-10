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
    sudo dnf install java-17-amazon-corretto -y
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
resource "aws_security_group" "sonar_sg" {
  name = "sonar_sg"
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
##########################################################
########## Installation of nexus artifact ##########

resource "aws_instance" "nexus" {
  ami = var.ami
  instance_type = var.instance_type
  tags = {
    "Name" = "Nexus"
  }
  key_name              = aws_key_pair.serverkey.id
  vpc_security_group_ids = [aws_security_group.nexus_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install java-1.8.0 -y
    cd /opt
    sudo wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.0.2-02-unix.tar.gz
    sudo tar -zxvf nexus-3.0.2-02-unix.tar.gz
    sudo mv /opt/nexus-3.0.2-02 /opt/nexus
    sudo adduser nexus
    echo "nexus ALL=(ALL) NOPASSWD: ALL" | sudo tee --append /etc/sudoers
    sudo chown -R nexus:nexus /opt/nexus
    sudo cp /dev/null /opt/nexus/bin/nexus.rc
    echo 'run_as_user="nexus"' | sudo tee --append /opt/nexus/bin/nexus.rc
    sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus
    sudo su - nexus
    service nexus start
  EOF
}
resource "aws_security_group" "nexus_sg" {
  name = "nexus_sg"
  dynamic "ingress" {
    for_each = var.nexusport
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
##################################################################
########### Installation of Tomcat ###########################
resource "aws_instance" "tomcat" {
  ami = var.ami
  instance_type = var.instance_type
  tags = {
    "Name" = "Tomcat"
  }
  key_name              = aws_key_pair.serverkey.id
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install java-1.8* -y
    sudo su -
    cd /opt
    wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz
    tar -xzvf apache-tomcat-9.0.80.tar.gz 
    chmod +x apache-tomcat-9.0.80/bin/startup.sh
    chmod +x apache-tomcat-9.0.80/bin/shutdown.sh
    ln -s /opt/apache-tomcat-9.0.80/bin/startup.sh /usr/local/bin/tomcatup
    ln -s /opt/apache-tomcat-9.0.80/bin/shutdown.sh /usr/local/bin/tomcatdown
    cd apache-tomcat-9.0.80/
    sed -i "/<Valve/{N; d;}" ./webapps/docs/META-INF/context.xml
    sed -i "/<Valve/{N; d;}" ./webapps/host-manager/META-INF/context.xml
    sed -i "/<Valve/{N; d;}" ./webapps/manager/META-INF/context.xml
    sed -i -e '$i\
    <role rolename="manager-gui"/>\
    <role rolename="manager-script"/>\
    <role rolename="manager-jmx"/>\
    <role rolename="manager-status"/>\
    <user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status"/>\
    <user username="deployer" password="deployer" roles="manager-script"/>\
    <user username="tomcat" password="s3cret" roles="manager-gui"/>' /opt/apache-tomcat-9.0.80/conf/tomcat-users.xml
    tomcatdown
    tomcatup
  EOF
}
resource "aws_security_group" "tomcat_sg" {
  name = "tomcat_sg"
  dynamic "ingress" {
    for_each = var.tomcatport
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
################################################################################

