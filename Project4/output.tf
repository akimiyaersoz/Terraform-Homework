output "load_balancer_dns" {
  value = aws_lb.alb.dns_name
}

output "blue_instance_ip" {
  value = aws_instance.blue-group4.public_ip
}

output "green_instance_ip" {
  value = aws_instance.green-group4.public_ip
}