#!/bin/bash

set -e

#sudo apt update -y
#sudo apt upgrade -y

# Setup
if [[ -z "$1" ]]; then
	echo "INSTALL_K3S: No mode specified"
	exit 1;
fi

UFW_STATUS="$(sudo ufw status)"
if echo "$UFW_STATUS" | grep -q "Status: active"; then
	echo "INSTALL_K3S: Disabling UFW"
	sudo ufw disable
fi

# K3s
MODE="$1"
SERVER_IP="192.168.56.110"
if  [ "$MODE" = "server" ]; then
	echo "INSTALL_K3S: Installing k3s server"
	sudo curl -sfL https://get.k3s.io |INSTALL_K3S_SKIP_START=true sh -s - --node-ip=$SERVER_IP --advertise-address=$SERVER_IP
	sudo systemctl enable k3s
	sudo systemctl start k3s
	echo "SERVER:INSTALL_K3S: Copying token"
	sudo cp /var/lib/rancher/k3s/server/node-token /vagrant_shared/node-token
	echo "SERVER:INSTALL_K3S: Done!"
elif [ "$MODE" = "agent" ]; then
	for i in {1..30}; do
		if mount | grep -q "/vagrant_shared"; then
			break
		fi
		echo "SERVER:INSTALL_K3S: Waiting for /vagrant_shared to be mounted..."
		sleep 1
	done
	echo "SERVER:INSTALL_K3S: Installing k3s agent"
	for i in {1..100}; do
		if [ -f /vagrant_shared/node-token ]; then
			break
		fi
		echo "SERVER:INSTALL_K3S: Waiting for node-token..."
		sleep 2
	done
	if [ ! -f /vagrant_shared/node-token ]; then
		echo "SERVER:INSTALL_K3S: Timeout waiting for server token"
		exit 1
	fi
	echo "SERVER:INSTALL_K3S: Found token, installing"
	export K3S_URL=https://$SERVER_IP:6443
	export K3S_TOKEN=$(cat /vagrant_shared/node-token)
	sudo rm -rf /vagrant_shared/*
	sudo curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.111 
	echo "SERVER:INSTALL_K3S: Done!"
else
	echo "SERVER:INSTALL_K3S: Unrecognized installation mode: $MODE"
	exit 1;
fi
