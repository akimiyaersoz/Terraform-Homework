data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # use this image ami in every region

    }
}


resource "aws_instance" "blue-group4" {
    instance_type = "t2.micro"
    ami = data.aws_ami.ubuntu.id
    subnet_id = aws_subnet.aysel-sub[0].id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.group4.id]
    tags = {
        Name = "Blue-group-4"
    }

    user_data = <<-EOF
                #!/bin/bash
                apt update
                apt install -y apache2
                echo "BLUE version Kiz Aysel" > /var/www/html/index.html
                systemctl start apache2
                systemctl enable apache2
                EOF 
}

resource "aws_instance" "green-group4" {
    instance_type = "t2.micro"
    ami = data.aws_ami.ubuntu.id
    subnet_id = aws_subnet.aysel-sub[1].id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.group4.id]
    tags = {
        Name = "Green-group-4"
    }

    user_data = <<-EOF
                #!/bin/bash
                apt update
                apt install -y apache2
                echo "Green version Kiz Aysel" > /var/www/html/index.html
                systemctl start apache2
                systemctl enable apache2
                EOF 
}