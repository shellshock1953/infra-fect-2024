apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ .Values.name }}
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: aws-param-store
  data:
    {{- toYaml .Values.secrets | nindent 4 }}
