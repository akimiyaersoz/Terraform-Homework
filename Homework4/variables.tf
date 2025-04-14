variable "tags" {
  type    = map(string)
}

variable "vpc_config" {
type = object({
    cidr_block  = string
    enable_dns_support = bool
    enable_dns_hostnames = bool
})
}

variable "subnets" {
type = list(object({
    cidr_block = string
    availability_zone = string
    auto_assign_ip = bool
    name = string
}) ) 
}

variable "internet_gateway_name" {
type = string  
}

variable "route_table_names" {
type =list(string)
}
variable "allowed_ports" {
type    = list(number)
}
variable "ec2_config" {
type = map(string)
}
variable "key_name" {
  type = string
  }