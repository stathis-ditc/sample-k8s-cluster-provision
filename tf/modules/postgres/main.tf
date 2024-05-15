#Sample postgres - only image and minimal resources
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name = "postgres"
          image = "postgres:15"
          port {
            name = "db"
            container_port = 5432
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgres-data"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key = "postgres-password"
                name = kubernetes_secret.postgres.metadata.0.name
              }
            }
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "postgres-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
    service_name = ""
  }
}

# Use this service if you use Kind cluster to establish connection outside the cluster
resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres"
    }
    port {
      port = 5432
      protocol = "TCP"
      target_port = 5432
      node_port = 31000
    }

    type = "NodePort"
  }
}

resource "kubernetes_config_map" "postgres" {
  metadata {
    name = "postgres-config-map"
    namespace = var.namespace
  }

  data = {
    postgres-db = "currencies"
  }
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name = "postgres-credentials"
    namespace = var.namespace
  }

  data = {
    postgres-username = "postgres"
    postgres-password = "postgres"
  }
}