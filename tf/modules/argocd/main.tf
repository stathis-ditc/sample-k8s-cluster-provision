locals {
  kubectl_apply_script_path = "${path.module}/scripts/kubectl-apply.sh"
  sample_project_manifest_path = "${path.module}/manifests/projects/sample.yaml"
  sample_app_repo_manifest_path = "${path.module}/manifests/repositories/sample.yaml"
  sample_manifest_path = "${path.module}/manifests/applications/apps.yaml"
}

resource "null_resource" "projects" {

  triggers = {
    manifest_path = filesha256(local.sample_project_manifest_path)
  }

  provisioner "local-exec" {
    command = local.kubectl_apply_script_path
    environment = merge({
      MANIFEST_PATH = local.sample_project_manifest_path
    })
  }
}

resource "null_resource" "repositories" {

  triggers = {
    manifest_path = filesha256(local.sample_app_repo_manifest_path)
  }

  provisioner "local-exec" {
    command = local.kubectl_apply_script_path
    environment = merge({
      MANIFEST_PATH = local.sample_app_repo_manifest_path
    })
  }
  depends_on = [null_resource.projects]
}

resource "null_resource" "k8s-config-app" {

  triggers = {
    manifest_path = filesha256(local.sample_manifest_path)
  }

  provisioner "local-exec" {
    command = local.kubectl_apply_script_path
    environment = merge({
      MANIFEST_PATH = local.sample_manifest_path
    })
  }
  depends_on = [null_resource.repositories]
}