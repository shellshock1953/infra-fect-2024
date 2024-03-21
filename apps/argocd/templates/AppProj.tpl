{{ if .Values.infra }}
{{ range .Values.infra.projects }}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: fect-{{ . }}
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  description: FECT-LNU 2024
  destinations:
  - name: '*'
    namespace: '*'
    server: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - https://github.com/softserve-appelsin/infra
---
{{ end }}
{{ end }}
