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
    repoURL: https://github.com/shellshock1953/infra-fect-2024
    targetRevision: {{ .Values.be.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.be.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
---
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
  project: fect-{{ .Values.be.env }}
  source:
    path: apps/fe
    repoURL: https://github.com/shellshock1953/infra-fect-2024
    targetRevision: {{ .Values.fe.branch }}
    helm:
      valueFiles:
        {{- toYaml .Values.fe.values | nindent 8 }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
