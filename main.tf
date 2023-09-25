resource "aws_instance" "server" {
    ami = var.ami
    instance_type = var.instance_type
    tags = {
      "Name" = each.value
}
    for_each = var.tag
    key_name = aws_key_pair.serverkey.id
    vpc_security_group_ids = [aws_security_group.sg_incoming.id]
}



resource "aws_key_pair" "serverkey" {
   key_name = "serverkey"
   public_key = file("/home/karthi/Downloads/serverkey.pub")
}


resource "aws_security_group" "sg_incoming" {
  name = "sg_incoming"
  dynamic "ingress" {
    for_each = var.ingress-ports
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
