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
        env:
        - name: POSTGRESQL_DATABASE
          value: appelsin
        - name: POSTGRESQL_USERNAME
          value: appelsin
        - name: POSTGRESQL_PASSWORD
          value: appelsin
        - name: POSTGRESQL_HOST
          value: postgresql
        - name: POSTGRESQL_PORT
          value: 5432
