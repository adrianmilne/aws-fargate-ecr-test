variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "route_table_ids" {
  type = list(string)
}

variable "private_dns_enabled" {
  type = bool
}
