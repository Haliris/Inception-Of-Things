#!/bin/bash

set -e

DOCKER_VERSION=$(docker --version)
K3D_VERSION=$(k3d version)
KUBECTL_VERSIOn=$(kubectl --version)

if [[ -n $K3D_VERSION ]]; then
	echo "INSTALL_K3D: K3D already installed."
	exit 0
fi

if [[ -z $DOCKER_VERSION ]]; then
	echo "INSTALL_K3D: Installing Docker..."
	echo "INSTALL_K3D: Removing conflicting packages..."
	for pkg in  docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
	echo "INSTALL_K3D: Setting up Docker's apt repos..."
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo \
	   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	     $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	echo "INSTALL_K3D: Installing Docker package..."
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	echo "INSTALL_K3D: Testing Docker install..."
	sudo docker run hello-world
fi

if [[ -z $KUBECTL_VERSION ]]; then
	echo "INSTALL_K3D: Downloading kubectl..."
	curl -LO  "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
	echo "INSTALL_K3D: Downloading kubectl checksum..."
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl.sha256"
	echo "INSTALL_K3D: Validating kubectl install file"
	echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
	echo "INSTALL_K3D: Installing kubectl..."
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	echo "INSTALL_K3D: Installing kubectl install"
	kubectl version --client
fi

echo "INSTALL_K3D: Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
echo "INSTALL_K3D: Done!"
