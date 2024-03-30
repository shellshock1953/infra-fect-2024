apiVersion: argoproj.io/v1alpha1
kind: Deployment
metadata:
  name: {{ .Values.name }}
  annotations:
    reloader.stakater.com/auto: "true"
  labels:
    app: {{ .Values.name }}
spec:
  revisionHistoryLimit: {{ .Values.history }}
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
        - containerPort: {{ .Values.port }}
        volumeMounts:
        - name: config-volume
          mountPath: /app/public/conf.yml
          subPath: conf.yml
        livenessProbe:
          httpGet:
            path: /
            port: {{ .Values.port }}
          initialDelaySeconds: 10
          periodSeconds: 30
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: {{ .Values.port }}
          initialDelaySeconds: 10
          periodSeconds: 30
          failureThreshold: 3
        # resources:
        #   requests:
        #     cpu: "300m"
        #     memory: "1Gi"
        #   limits:
        #     cpu: "500m"
        #     memory: "3Gi"
      volumes:
        - name: config-volume
          configMap:
            name: {{ .Values.name }}
