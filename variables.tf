variable "cidr" {
  default = "10.0.0.0/16"
}
variable "pub_sub_a" {
  description = "Public Subnet-a"
  default     = "10.0.0.0/24"

}
variable "pub_sub_b" {
  description = "Public Subnet-b"
  default     = "10.0.1.0/24"

}

variable "available_zone-a" {
  description = "Available Zone a"
  type        = string
  default     = "us-east-1a"

}

variable "available_zone-b" {
  description = "Available Zone b"
  type        = string
  default     = "us-east-1b"

}

# variable "s3-bucket-name" {
#     type = string
#     description = "Demo S3 bucket name"
#     default = "mydemo-s3-bkt-01"

# }

variable "amis" {
  description = "Ubuntu AMI for webserver"
  type        = string
  default     = "ami-04b70fa74e45c3917"

}


variable "my-alb-name" {
  description = "My application load balancer"
  type        = string
  default     = "my-alb"

}

variable "LB-type" {
  description = "Load balancer Type"
  type        = string
  default     = "application"

}

variable "my-trgp-nmae" {
  description = "My load balancer target group"
  type        = string
  default     = "my-trgp"

}

variable "trgp-port" {
  description = "target Group port"
  type        = string
  default     = "80"

}

variable "trgp-protocol" {
  description = "target Group protocol"
  type        = string
  default     = "HTTP"

}