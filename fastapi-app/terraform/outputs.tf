# terraform/outputs.tf
output "application_url" {
  description = "The public DNS name for the application Load Balancer."
  value = data.kubernetes_service.fastapi_service.status[0].load_balancer[0].ingress[0].hostname
}

output "kubeconfig_command" {
  description = "Command to configure your local kubectl to connect to the cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}