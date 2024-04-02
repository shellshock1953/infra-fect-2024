apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.name }}
  labels:
    app: {{ .Values.name }}
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.name }}
    spec:
      containers:
      - name: {{ .Values.name }}
        image: {{ .Values.image.repo }}:{{ .Values.image.tag }}
        imagePullPolicy: Always
        ports:
        - containerPort: {{ .Values.ingress.port }}
        envFrom:
        - secretRef:
            name: {{ .Values.name }}
        command:
          - "ng"
          - "serve"
          - "--configuration={{ .Values.sysenv }}"
          - "--host=0.0.0.0"
          - "--port=80"
