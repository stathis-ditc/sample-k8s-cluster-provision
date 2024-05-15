#!/bin/bash

set -euo pipefail

# Helm repos
helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

# Install argocd
helm upgrade --install argocd argo/argo-cd \
  --version "$ARGOCD_VERSION" \
  --values "$BASE_PATH"/argocd-chart-values.yaml \
  --namespace "$ARGOCD_NAMESPACE"
