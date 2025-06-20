#!/bin/bash

set -e

echo "SETUP_K3S: Disabling ufw..."
sudo ufw disable

sudo apt update
sudo apt upgrade -y
sudo apt install w3m -y
sudo apt install xauth x11-apps -y

echo "192.168.56.110 app1.com app2.com app3.com" | sudo tee -a /etc/hosts

echo "SETUP_K3S: Installing k3s from direct source script..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-external-ip=192.168.56.110" sh -
#echo "SETUP_K3S: Installing k3s from GitHub install script..."
#curl -vfL https://raw.githubusercontent.com/k3s-io/k3s/master/install.sh | sh -so 
echo "SETUP_K3S: Installed k3s"

echo "SETUP_K3S: Applying Helm Traefik config"
sudo kubectl apply -f /vagrant_shared/traefik-config.yaml

echo "SETUP_K3S: Creating p2 namespace"
sudo kubectl create namespace p2

echo "SETUP_K3S: Deploying app1"
sudo kubectl create -f /vagrant_shared/app1.yaml
echo "SETUP_K3S: Applying app1 service..."
sudo kubectl apply -f /vagrant_shared/service1.yaml

echo "SETUP_K3S: Deploying app2"
sudo kubectl create -f /vagrant_shared/app2.yaml
echo "SETUP_K3S: Applying app2 service..."
sudo kubectl apply -f /vagrant_shared/service2.yaml

echo "SETUP_K3S: Deploying app3"
sudo kubectl create -f /vagrant_shared/app3.yaml
echo "SETUP_K3S: Applying app2 service..."
sudo kubectl apply -f /vagrant_shared/service3.yaml

echo "SETUP_K3S: Waiting for app1 deployment to be available..."
sudo kubectl wait --for=condition=Available deployment/app1 -n p2 --timeout=380s
echo "SETUP_K3S: Waiting for pod1 to be ready..."
sudo kubectl wait --for=condition=Ready pod -l app=app1 -n p2 --timeout=380s

echo "SETUP_K3S: Waiting for app2 deployment to be available..."
sudo kubectl wait --for=condition=Available deployment/app2 -n p2 --timeout=380s
echo "SETUP_K3S: Waiting for pod2 to be ready..."
sudo kubectl wait --for=condition=Ready pod -l app=app2 -n p2 --timeout=380s

echo "SETUP_K3S: Waiting for app3 deployment to be available..."
sudo kubectl wait --for=condition=Available deployment/app3 -n p2 --timeout=380s
echo "SETUP_K3S: Waiting for pod3 to be ready..."
sudo kubectl wait --for=condition=Ready pod -l app=app3 -n p2 --timeout=380s

echo "SETUP_K3S: Applying ingress"
sudo kubectl apply -f /vagrant_shared/p2_ingress.yaml -n p2

echo "SETUP_K3S: Checking deployment status..."
sudo kubectl get deployment -n p2
sudo kubectl get services -n p2
