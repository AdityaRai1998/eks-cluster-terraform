# Output the health of the EKS cluster
output "eks_cluster_health" {
  value = aws_eks_cluster.my_cluster[*].health_status
}