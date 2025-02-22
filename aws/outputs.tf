output "consul_token_secret" {
  value = random_uuid.nomad_token.result
}

output "kubernetes_cluster_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}
