apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.name }}
data:
  conf.yml: |
  {{- with .Values.config }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
