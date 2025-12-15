# terraform/variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
}

variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_image_path" {
  description = "Path to the container image (e.g., youruser/simplet imeservice:latest)"
  type        = string
}