output "postgres_secret" {
  value = kubernetes_secret.postgres.metadata.0.name
}

output "postgres_cm" {
  value = kubernetes_config_map.postgres.metadata.0.name
}