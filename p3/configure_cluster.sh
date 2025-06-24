#!/bin/bash

set -e

echo "Creating cluster..."
sudo k3d cluster create mycluster
echo "Installing argocd..."
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "Done!"
