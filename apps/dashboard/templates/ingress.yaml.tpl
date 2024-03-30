apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Values.domain }}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/tls-acme: "true"
spec:
  ingressClassName: {{ .Values.ingressClass | default "nginx" }}
  tls:
  - hosts:
    - "{{ .Values.domain }}"
    - "preview.{{ .Values.domain }}"
    secretName: "{{ .Values.domain }}"
  rules:
  - host: "{{ .Values.domain }}"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: {{ .Values.name }}
            port:
              number: {{ .Values.port }}
  - host: "preview.{{ .Values.domain }}"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: {{ .Values.name }}-preview
            port:
              number: {{ .Values.port }}
