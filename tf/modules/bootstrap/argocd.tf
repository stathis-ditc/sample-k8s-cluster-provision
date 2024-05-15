locals {
  argocd_chart_version = "6.7.17"
  argocd_config = {
    controller = {
      replicas = 1
    }
    server = {
      replicas = 1
    }
    repoServer = {
      replicas = 1
    }
    applicationSet = {
      replicaCount = 1
    }
    configs = {
      params = {
        "server.insecure" = true
      }
    }
  }
  argocd_chart_values = yamlencode(local.argocd_config)

  tmp_argocd_config_path = "${path.root}/tmp/argocd"
  argocd_install_script_path = "${path.module}/scripts/argocd.sh"
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
      shared-gateway-access = "true"
    }
  }
}

resource "null_resource" "argocd" {

  triggers = {
    base_path = local.tmp_argocd_config_path
    argocd_install_script_path = filesha256(local.argocd_install_script_path)
    argocd_chart_version = local.argocd_chart_version
    argocd_chart_values = local.argocd_chart_values
  }

  provisioner "local-exec" {
    command = "rm -rf ${local.tmp_argocd_config_path} && mkdir -p ${local.tmp_argocd_config_path}"
  }

  provisioner "local-exec" {
    command = "cat <<EOF > ${local.tmp_argocd_config_path}/argocd-chart-values.yaml\n${local.argocd_chart_values}\n"
  }

  provisioner "local-exec" {
    command = local.argocd_install_script_path
    environment = merge({
      BASE_PATH = self.triggers.base_path
      ARGOCD_VERSION = self.triggers.argocd_chart_version
      ARGOCD_NAMESPACE = "argocd"
    })
  }

  depends_on = [kubernetes_namespace_v1.argocd]
}
