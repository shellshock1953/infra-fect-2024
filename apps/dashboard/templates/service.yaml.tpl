apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.name }}
spec:
  selector:
    app: {{ .Values.name }}
  ports:
    - protocol: TCP
      port: {{ .Values.port }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.name }}-preview
spec:
  selector:
    app: {{ .Values.name }}
  ports:
    - protocol: TCP
      port: {{ .Values.port }}
