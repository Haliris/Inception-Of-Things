#!/bin/bash

set -o allexport
source .env
set +o allexport

echo "CONFIGURE_ARGOCD: Setting kubectl context"
sudo kubectl config set-context --current --namespace=argocd
echo "CONFIGURE_ARGOCD: Setting password"
DEFAULT_PASSWORD=$(sudo argocd admin initial-password -n argocd)
DEFAULT_PASSWORD=${DEFAULT_PASSWORD%%$'\n'*}
sudo argocd login $ARGOCD_SERVER \
	--username admin \
	--password "$DEFAULT_PASSWORD" \
	--insecure
sudo argocd account update-password \
	--current-password "$DEFAULT_PASSWORD" \
	--new-password "$ARGOCD_PASSWORD"
echo "CONFIGURE_ARGOCD: Done."
