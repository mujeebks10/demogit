resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "pub_sub_a" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.pub_sub_a
  availability_zone       = var.available_zone-a
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub_sub_b" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.pub_sub_b
  availability_zone       = var.available_zone-b
  map_public_ip_on_launch = true

}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

}

resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_eip" "my-eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "mynatgw" {
  depends_on = [
    aws_eip.my-eip
  ]
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.pub_sub_a.id
}

resource "aws_route_table_association" "public_RT-sbn-a" {
  subnet_id      = aws_subnet.pub_sub_a.id
  route_table_id = aws_route_table.public_RT.id

}

resource "aws_route_table_association" "public_RT-sbn-b" {
  subnet_id      = aws_subnet.pub_sub_b.id
  route_table_id = aws_route_table.public_RT.id

}

resource "aws_security_group" "web-sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "web-sg"
  }

}

resource "aws_s3_bucket" "mydemo-s3-bkt" {

  bucket = "mydemo-s3-bkt-01"



}

resource "aws_instance" "webserver1" {
  ami                    = var.amis
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id              = aws_subnet.pub_sub_a.id
  user_data              = base64encode(file("userdata.sh"))

}

resource "aws_instance" "webserver2" {
  ami                    = var.amis
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id              = aws_subnet.pub_sub_b.id
  user_data              = base64encode(file("userdata1.sh"))

}

#Create ALB

resource "aws_lb" "my-alb" {
  name               = var.my-alb-name
  internal           = false
  load_balancer_type = var.LB-type

  security_groups = [aws_security_group.web-sg.id]
  subnets         = [aws_subnet.pub_sub_a.id, aws_subnet.pub_sub_b.id]

  tags = {
    Name = "web"
  }

}

resource "aws_lb_target_group" "my-tgp" {
  name     = var.my-trgp-nmae
  port     = var.trgp-port
  protocol = var.trgp-protocol
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

}

resource "aws_lb_target_group_attachment" "attach-1" {
  target_group_arn = aws_lb_target_group.my-tgp.arn
  target_id        = aws_instance.webserver1.id
  port             = 80

}

resource "aws_lb_target_group_attachment" "attach-2" {
  target_group_arn = aws_lb_target_group.my-tgp.arn
  target_id        = aws_instance.webserver2.id
  port             = 80

}

resource "aws_lb_listener" "My-listener" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my-tgp.arn
    type             = "forward"
  }

}

output "loadbalancerdns" {
  value = aws_lb.my-alb.dns_name

}



