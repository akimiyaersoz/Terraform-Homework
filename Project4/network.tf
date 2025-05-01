resource "aws_vpc" "group4" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "group-4"
  }
}

resource "aws_internet_gateway" "gw-aysel" {
  vpc_id = aws_vpc.group4.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "aysel-sub" {
  count                   = 3
  vpc_id                  = aws_vpc.group4.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "group-4-public-${count.index + 1}"
  }
}

resource "aws_route_table" "rt-ays" {
  vpc_id = aws_vpc.group4.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-aysel.id
  }
}

resource "aws_route_table_association" "rt-aso" {
  count          = 3
  subnet_id      = aws_subnet.aysel-sub[count.index].id
  route_table_id = aws_route_table.rt-ays.id
}

resource "aws_security_group" "group4" {
  name        = "allow_group4"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.group4.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_group4"
  }
}

resource "aws_lb" "alb" {
  name               = "group4-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.aysel-sub[*].id
  security_groups    = [aws_security_group.group4.id]
}

resource "aws_lb_target_group" "blue-group4" {
  name        = "blue-group4"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.group4.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "green-group4" {
  name        = "green-group4"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.group4.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue-group4.arn
        weight = 50
      }

      target_group {
        arn    = aws_lb_target_group.green-group4.arn
        weight = 50
      }

      stickiness {
        enabled = false
        duration = 1  # Required even if stickiness is disabled; minimum is 1 second
      }
    }
  }
}

resource "aws_lb_target_group_attachment" "blue-group4" {
  target_group_arn = aws_lb_target_group.blue-group4.arn
  target_id        = aws_instance.blue-group4.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "green-group4" {
  target_group_arn = aws_lb_target_group.green-group4.arn
  target_id        = aws_instance.green-group4.id
  port             = 80
}
