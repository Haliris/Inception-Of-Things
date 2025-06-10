#!/bin/bash

sudo apt-get update
sudo apt-get upgrade

UFW_STATUS="$(sudo ufw status)"
if [ $(UFW_STATUS) -eq "Status: active" ]; then
	echo "Disabling UFW"
	sudo ufw disable
fi


# Kubectl
echo "Downloading kubectl install"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" || { echo "Install download failed"; exit 1; }

echo "Downloading kubectl checksum"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" || { echo "Checksum download failed"; exit 1; }

echo "Validating checksum"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --jcheck

echo "Installing kubectl..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl || { echo "Installation failed"; exit 1; }
kubectl version --client

# Kube


