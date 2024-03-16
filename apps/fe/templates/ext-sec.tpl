apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ .Values.name }}
  annotations:
    argocd.argoproj.io/compare-options: IgnoreExtraneous
    argocd.argoproj.io/sync-options: Prune=false
    argocd.argoproj.io/hook: PreSync
  labels: {}
  refreshInterval: 1h
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: aws-param-store
  data:
    {{- toYaml .Values.secrets | nindent 4 }}
