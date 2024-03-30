{{ if .Values.be }}
# BACKEND
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fect-be-{{ .Values.be.env }}
  namespace: argocd
spec:
  destination:
    namespace: fect-{{ .Values.be.env }}
    server: https://kubernetes.default.svc
  project: fect-{{ .Values.be.env }}
  source:
    path: apps/be
    repoURL: https://github.com/softserve-appelsin/infra
    targetRevision: {{ .Values.be.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.be.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
{{ end }}
{{ if .Values.fe }}
# FRONTEND
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fect-fe-{{ .Values.fe.env }}
  namespace: argocd
spec:
  destination:
    namespace: fect-{{ .Values.fe.env }}
    server: https://kubernetes.default.svc
  project: fect-{{ .Values.fe.env }}
  source:
    path: apps/fe
    repoURL: https://github.com/softserve-appelsin/infra
    targetRevision: {{ .Values.fe.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.fe.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
{{ end }}
{{ if .Values.infra }}
# CICD
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fect-cicd
  namespace: argocd
spec:
  destination:
    namespace: fect-{{ .Values.infra.env }}
    server: https://kubernetes.default.svc
  project: fect-{{ .Values.infra.env }}
  source:
    path: cicd
    repoURL: https://github.com/softserve-appelsin/infra
    targetRevision: {{ .Values.infra.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.infra.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
# WORKFLOWS
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fect-workflows
  namespace: argocd
spec:
  destination:
    namespace: fect-{{ .Values.infra.env }}
    server: https://kubernetes.default.svc
  project: fect-{{ .Values.infra.env }}
  source:
    path: workflows
    repoURL: https://github.com/softserve-appelsin/infra
    targetRevision: {{ .Values.infra.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.infra.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
# SYS
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fect-sys
  namespace: argocd
spec:
  destination:
    namespace: fect-{{ .Values.infra.env }}
    server: https://kubernetes.default.svc
  project: fect-{{ .Values.infra.env }}
  source:
    path: apps/sys
    repoURL: https://github.com/softserve-appelsin/infra
    targetRevision: {{ .Values.infra.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.infra.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
# Dash
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fect-dashboard
  namespace: argocd
spec:
  destination:
    namespace: fect-{{ .Values.infra.env }}
    server: https://kubernetes.default.svc
  project: fect-{{ .Values.infra.env }}
  source:
    path: apps/dashboard
    repoURL: https://github.com/softserve-appelsin/infra
    targetRevision: {{ .Values.infra.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.infra.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
{{ end }}
