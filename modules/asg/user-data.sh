#!/bin/bash
set -euo pipefail

# Install K3s with specific version
echo "[INFO] Installing K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.32.4+k3s1" sh -s - server --cluster-init

sleep 30

# Install Helm
echo "[INFO] Installing Helm..."
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Set up kubeconfig
echo "[INFO] Configuring kubectl access..."
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config

# Add Rancher Helm repo
echo "[INFO] Adding Rancher Helm repo..."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

# Create namespaces
echo "[INFO] Creating namespaces..."
kubectl create namespace cattle-system || true

# Install cert-manager CRDs and Helm chart
echo "[INFO] Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace || true

# Install Rancher
echo "[INFO] Installing Rancher..."
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname="${rancher_domain_name}" \
  --set replicas=1 \
  --set bootstrapPassword="${rancher_password}"

echo "[DONE] Rancher should now be available at: https://${rancher_domain_name}"