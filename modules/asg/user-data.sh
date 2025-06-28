#!/bin/bash
set -euo pipefail

echo "DEBUG rancher_domain_name: ${rancher_domain_name}"

# Set proper environment
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH=$PATH:/usr/local/bin

# Install K3s with specific version
echo "[INFO] Installing K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.32.4+k3s1" sh -s - server --cluster-init

# Wait for K3s to be fully ready
echo "[INFO] Waiting for K3s to be ready..."
until kubectl get nodes >/dev/null 2>&1; do
  echo "Waiting for K3s API server..."
  sleep 10
done

sleep 30

# Install Helm
echo "[INFO] Installing Helm..."
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Set up kubeconfig for root user (optional, since we're using KUBECONFIG env var)
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
  --create-namespace \
  --wait \
  --timeout=300s || true

# Wait for cert-manager to be ready
echo "[INFO] Waiting for cert-manager..."
kubectl wait --for=condition=Available deployment/cert-manager -n cert-manager --timeout=300s
kubectl wait --for=condition=Available deployment/cert-manager-cainjector -n cert-manager --timeout=300s
kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager --timeout=300s

# Install k9s
echo "[INFO] Installing k9s..."
wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb

# Install Rancher
echo "[INFO] Installing Rancher..."
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname='${rancher_domain_name}' \
  --set replicas=1 \
  --set bootstrapPassword='${rancher_password}' \
  --set ingress.enabled=true \
  --wait \
  --timeout=600s

echo "[DONE] Rancher should now be available at: https://${rancher_domain_name}"

# Optional: Check Rancher pod status
kubectl get pods -n cattle-system