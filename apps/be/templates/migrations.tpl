kind: Job
apiVersion: batch/v1
metadata:
  name: {{ .Values.name }}-migrate
  labels:
    app: {{ .Values.name }}
  annotations:
    argocd.argoproj.io/sync-options: Prune=false
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/sync-wave: "1"
spec:
  template:
    metadata:
      name: {{ .Values.name }}
    spec:
      containers:
      - name: {{ .Values.name }}
        image: {{ .Values.image.repo }}:{{ .Values.image.tag }}
        command: ["python", "manage.py", "migrate"]
      restartPolicy: Never
  backoffLimit: 2
