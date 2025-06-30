#!/bin/bash

set -e

echo "CONFIGURE_CLUSTER: Checking dependencies..."
bash install_k3d.sh
echo "CONFIGURE_CLUSTER: Creating cluster"
sudo k3d cluster create mycluster

echo "CONFIGURE_CLUSTER: Installing Argo CD..."
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "CONFIGURE_CLUSTER: Waiting for Argo CD pods..."
sudo kubectl wait --for=condition=Ready pods --all -n argocd --timeout=380s
echo "CONFIGURE_CLUSTER: Forwarding Argo CD port"
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 &

echo "CONFIGURE_CLUSER: Installing Argo CD CLI..."
curl -SL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo "CONFIGURE_CLUSTER: Installing NGINX ingress controller..."
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
echo "CONFIGURE_CLUSTER: Waiting for NGINX  pods..."
sudo kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pods \
  -l app.kubernetes.io/component=controller \
  --timeout=380s
echo "CONFIGURE_CLUSTER: Forwarding App port"
sudo kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8888:80 &
echo "CONFIGURE_CLUSTER: Creating dev namespace"
sudo kubectl create namespace dev

echo "CONFIGURE_CLUSTER: Configuring Argo CD..."
bash ./configure_argocd.sh
echo "CONFIGURE_CLUSTER: Done!"
