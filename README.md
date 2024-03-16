# Infra Repo SoftServe FNEC-2024

|                                                                                            | FE                                                                                                                          | BE                                                                                                                          |   |   |
|--------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|---|---|
| ![prod](https://uptime.dnull.systems/api/badge/13/status?style=for-the-badge&label=prod)   | [![FE](https://argocd.dnull.systems/api/badge?name=fect-fe-prod)](https://argocd.dnull.systems/applications/fect-fe-prod)   | [![BE](https://argocd.dnull.systems/api/badge?name=fect-be-prod)](https://argocd.dnull.systems/applications/fect-be-prod)   |   |   |
| ![stage](https://uptime.dnull.systems/api/badge/15/status?style=for-the-badge&label=stage) | [![FE](https://argocd.dnull.systems/api/badge?name=fect-fe-stage)](https://argocd.dnull.systems/applications/fect-fe-stage) | [![BE](https://argocd.dnull.systems/api/badge?name=fect-be-stage)](https://argocd.dnull.systems/applications/fect-be-stage) |   |   |
|                                                                                            |                                                                                                                             |                                                                                                                             |   |   |


## Install
Gitops included. Managed by ArgoCD.

## Usage
Update YAML-values for BE/FE in related dir.
Changes will be auto-deployed.

## Images
Hosted on public dockerhub registries:

- [Frontend](https://hub.docker.com/r/2xnone/appelsin-fe)
- [Backend](https://hub.docker.com/r/2xnone/appelsin-be)
