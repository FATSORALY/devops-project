output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint API du cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "URL du dépôt ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "jenkins_public_ip" {
  description = "IP publique de l'instance Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "kubeconfig_command" {
  description = "Commande pour configurer kubectl"
  value       = "aws eks update-kubeconfig --region eu-west-3 --name ${module.eks.cluster_name}"
}
