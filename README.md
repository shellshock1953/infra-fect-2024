# Infra Repo SoftServe FNEC-2024
![prod](https://uptime.dnull.systems/api/badge/13/status?style=for-the-badge&label=prod)


![stage](https://uptime.dnull.systems/api/badge/15/status?style=for-the-badge&label=stage)

[![BE](https://argocd.dnull.systems/api/badge?name=fect-be-stage&revision=true)](https://argocd.dnull.systems/applications/fect-be-stage)

## Install
Gitops included. Managed by ArgoCD.

## Usage
Update YAML-values for BE/FE in related dir.
Changes will be auto-deployed.

## Images
Hosted on public dockerhub registries:

- [Frontend](https://hub.docker.com/r/2xnone/appelsin-fe)
- [Backend](https://hub.docker.com/r/2xnone/appelsin-be)
