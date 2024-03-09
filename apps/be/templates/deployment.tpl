apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.name }}-{{ .Values.sysenv }}
  labels:
    app: {{ .Values.name }}-{{ .Values.sysenv }}
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.name }}-{{ .Values.sysenv }}
  template:
    metadata:
      labels:
        app: {{ .Values.name }}-{{ .Values.sysenv }}
    spec:
      containers:
      - name: {{ .Values.name }}
        image: {{ .Values.image.repo }}:{{ .Values.image.tag }}
        imagePullPolicy: Always
        ports:
        - containerPort: {{ .Values.port }}
