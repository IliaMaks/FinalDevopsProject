variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ec2_type" {
  default = "t2.medium"
}

variable "ec2_ami" {
  description = "Ubuntu Server 22.04 LTS (HVM), SSD Volume Type — us-east-1"
  default     = "ami-0c398cb65a93047f2"
}
