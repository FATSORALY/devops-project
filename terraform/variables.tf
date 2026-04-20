variable "region" {
  description = "Région AWS"
  default     = "eu-west-3"
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  default     = "devops-cluster"
}

variable "project_name" {
  description = "Nom du projet"
  default     = "devops-project"
}