variable "aws_region" {
  type        = string
  description = "The AWS region to deploy infrastructure"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance type required for the project"
  default     = "m7i.flex-large"
}

variable "project_name" {
  type        = string
  default     = "devops-final-lab"
}
