variable "environment" {
  default     = "tools"
  type        = string
  description = "Environment name"
}

variable "service" {
  default     = "web-server"
  type        = string
  description = "Service name"
}

variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "type of instance"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "ID of the private subnet"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "ID of the subnet subnet"
}

variable "max" {
  default     = 6
  type        = number
  description = "Maximum number of autoscaling group instances"
}

variable "min" {
  default     = 3
  type        = number
  description = "Minimum number of autoscaling groups instances"
}

variable "desired_capacity" {
  default     = 3
  type        = number
  description = "Desired number of Autoscaling Groups"
}

variable "log_expire_days" {
  default     = 7
  type        = number
  description = "value"
}

variable "available_zones" {
  type = list(string)
}

variable "company_name" {
  default     = "Change this to the client"
  type        = string
  description = "Name of the company"
}

variable "lb_ingress_rules" {
  default     = ["null"]
  type        = list(string)
  description = "allowed ips to web-server"
}

variable "create_load_balancer" {
  default     = true
  type        = bool
  description = "whether to create resource"
}

variable "external_target_group_arns" {
  type    = list(string)
  default = []
}

variable "project_name" {
  type    = string
  default = "Medium"
}

variable "external_lb_listener_arn" {
  type        = string
  default     = ""
  description = "Listener arn for the external load balancer"
}

variable "external_lb_name" {
  type        = string
  description = "Name of external load balancer"
  default     = "medium-lb"
}

variable "external_lb_zone_id" {
  type        = string
  description = "Zone ID of external load balancer"
}

variable "external_lb_security_group_id" {
  type        = string
  description = "Security group of external load balancer"
}