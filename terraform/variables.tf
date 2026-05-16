variable "aws_region" {
  default = "eu-west-3"  # Paris
}

variable "cluster_name" {
  default = "devops-free-tier"
}

variable "environment" {
  default = "dev"
}

variable "aws_account_id" {
  type = string
}