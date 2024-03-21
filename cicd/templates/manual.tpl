{{ range $app := .Values.apps }}
# {{ $app.name | upper }}
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: appelsin-{{ $app.name }}
spec:
  serviceAccountName: appelsin-workflow-sa
  entrypoint: main
  arguments:
    parameters:
      - name: version
      - name: sysenv
        enum: ['stage', 'prod']
  onExit: notify
  volumes:
  - name: docker-config
    secret:
      secretName: docker-config
      items:
      - key: .dockerconfigjson
        path: config.json
  - name: push-key
    secret:
      secretName: deployment-key
      items:
        - key: ssh-privatekey
          path: infra
  templates:
  - name: main
    inputs:
      parameters:
        - name: version
        - name: sysenv
    dag:
      tasks:
      - name: build-image
        templateRef:
          name: kaniko
          template: main
        arguments:
          parameters:
          - name: repo
            value: "https://github.com/softserve-appelsin/{{ $app.name }}"
          - name: revision
            value: '{{`{{inputs.parameters.sysenv}}`}}'
          - name: image
            value: 2xnone/appelsin-{{ $app.name }}
          - name: tag
            value: '{{`{{inputs.parameters.version}}`}}'
          - name: dockerfile
            value: {{ $app.dockerfile }}
      - name: deploy
        depends: build-image
        templateRef:
          name: deploy
          template: main
        arguments:
          parameters:
          - name: repo
            value: "git@github.com:softserve-appelsin/infra.git"
          - name: revision
            value: main
          - name: manifest 
            value: apps/{{ $app.name }}/{{`{{inputs.parameters.sysenv}}`}}.yaml
          - name: yaml_path
            value: image.tag
          - name: tag
            value: '{{`{{inputs.parameters.version}}`}}'
  - name: notify
    dag:
      tasks:
      - name: ntfy
        templateRef:
          name: ntfy
          template: main
        arguments:
          parameters:
          - name: channel
            value: appelsin
          - name: status
            value: '{{`{{workflow.status}}`}}'
          - name: success
            value: "{{ $app.name }}: Build completed"
          - name: fail
            value: "{{ $app.name }}: Build failed"
---
{{ end }}
