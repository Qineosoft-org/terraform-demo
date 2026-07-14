variable "environment" {
  default = "mahesh-dev"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block of the vpc"

}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "cidr block for public subnet"

}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "cidr block for public subnet"

}

variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-006f82a1d5a27da54"

}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_key_pair_name" {
  default = "mahesh"
}
