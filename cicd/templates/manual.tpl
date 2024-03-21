{{ range $manual := .Values.manual }}
# {{ $manual.name | title }}
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: appelsin-{{ $manual.name }}
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
            value: "https://github.com/softserve-appelsin/{{ $manual.name }}"
          - name: revision
            value: '{{`{{inputs.parameters.sysenv}}`}}'
          - name: image
            value: 2xnone/appelsin-{{ $manual.name }}
          - name: tag
            value: '{{`{{inputs.parameters.version}}`}}'
          - name: dockerfile
            value: {{ $manual.dockerfile }}
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
            value: apps/{{ $manual.name }}/{{`{{inputs.parameters.sysenv}}`}}.yaml
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
            value: "{{ $manual.name }}: Build completed"
          - name: fail
            value: "{{ $manual.name }}: Build failed"
---
{{ end }}
