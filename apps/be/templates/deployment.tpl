apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.name }}-{{ .Valuses.sysenv }}
  labels:
    app: {{ .Values.name }}-{{ .Valuses.sysenv }}
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.name }}-{{ .Valuses.sysenv }}
  template:
    metadata:
      labels:
        app: {{ .Values.name }}-{{ .Valuses.sysenv }}
    spec:
      containers:
      - name: {{ .Values.name }}
        image: {{ .Values.image.repo }}:{{ .Values.image.tag }}
        imagePullPolicy: Always
        ports:
        - containerPort: {{ .Values.port }}
