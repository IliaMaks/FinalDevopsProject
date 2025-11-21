variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "ec2_ami" {
  description = "Amazon Linux 2 AMI for region us-east-1"
  default     = "ami-0c02fb55956c7d316"
}
