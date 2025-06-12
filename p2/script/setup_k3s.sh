#!/bin/bash

set -e

echo "SETUP_K3S: Disabling ufw..."
sudo ufw disable

echo "SETUP_K3S: Installing k3s..."
curl -sfL https://get.k3s.io | sh -s
echo "SETUP_K3S: Installed k3s"
echo "SETUP_K3S: Creating p2 namespace"
sudo kubectl create namespace p2
echo "SETUP_K3S: Deploying app1"
sudo kubectl create -f /vagrant_shared/helloworld.yaml
echo "SETUP_K3S: Waiting for helloworld deployement to be available..."
sudo kubectl wait --for=condition=Available deployment/helloworld -n p2 --timeout=380s
echo "SETUP_K3S: Waiting for pod1 to be ready..."
sudo kubectl wait --for=condition=Ready pod -l app=helloworld -n p2 --timeout=380s
echo "SETUP_K3S: Checking deployment status..."
sudo kubectl get deployment helloworld -n p2
echo "SETUP_K3S: Exposing app1 with ClusterIP"
sudo kubectl expose deployment helloworld --type=ClusterIP --name=app1-service --port=8080 --target-port=8080 -n p2
echo "SETUP_K3S: Creating load balancer for app1"
sudo kubectl expose deployment helloworld --type=LoadBalancer --name=app1-service-loadbalancing --port=8080 --target-port=8080 -n p2
echo "SETUP_K3S: Port forwarding app1"
sudo kubectl port-forward deployment/helloworld 8080:8080 -n p2 &
echo "SETUP_K3S: Services created:"
sudo kubectl get services -n p2
