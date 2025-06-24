#!/bin/bash

set -e

echo "CONFIGURE_CLUSTER: Checking dependencies..."
bash install_k3d.sh
echo "CONFIGURE_CLUSTER: Creating cluster"
sudo k3d cluster create mycluster
echo "CONFIGURE_CLUSTER: Installing argocd..."
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "CONFIGURE_CLUSTER: Waiting for argocd pods..."
sudo kubectl wait --for=condition=Ready pods --all -n argocd --timeout=380s
echo "CONFIGURE_CLUSTER: Forwarding port"
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 &
echo "CONFIGURE_CLUSTER: Installing Wil app..."
sudo kubectl create namespace dev
sudo kubectl apply -n dev -f k8s/
echo "CONFIGURE_CLUSTER: Waiting for dev pods..."
sudo kubectl wait --for=condition=Ready pods --all -n dev --timeout=100s
echo "CONFIGURE_CLUSTER: Done!"
