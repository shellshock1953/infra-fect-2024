#!/bin/bash
SYSENV="${1}"

if [ -z "${SYSENV}" ]; then
  echo "Please provide the SYSENV name: stage/prod"
  exit 1
fi

echo "Installing fect-${SYSENV}"
sleep 4

helm upgrade --install "fect-${SYSENV}" ./ --values "${SYSENV}".yaml --namespace argocd
