resource "aws_vpc" "main" {
cidr_block = var.vpc_config.cidr_block
enable_dns_support = var.vpc_config.enable_dns_support
enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
tags = var.tags
}

resource "aws_subnet" "subnets" {
count = length(var.subnets)
vpc_id = aws_vpc.main.id
cidr_block = var.subnets[count.index].cidr_block
availability_zone = var.subnets[count.index].availability_zone
map_public_ip_on_launch = var.subnets[count.index].auto_assign_ip
tags = merge(var.tags, {
Name = var.subnets[count.index].name
})
}

resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main.id

tags = merge(var.tags, {
Name = var.internet_gateway_name
})
}

resource "aws_security_group" "main" {
name = "kaizen-sg"
description = "Allow ports"
vpc_id = aws_vpc.main.id

dynamic "ingress" {
for_each = var.allowed_ports
content {
from_port = ingress.value
to_port = ingress.value
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = var.tags
}
resource "aws_instance" "aws" {
ami = var.ec2_config["ami_id"]
instance_type = var.ec2_config["instance_type"]
subnet_id = aws_subnet.subnets[0].id
key_name = "my-laptop-key"
vpc_security_group_ids = [aws_security_group.main.id]
tags = var.tags
}