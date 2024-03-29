{{ range $app := .Values.apps }}
# MERGE: {{ $app.name | upper }}
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: appelsin-{{ $app.name }}-merge
spec:
  template:
    serviceAccountName: appelsin-workflow-sa
  dependencies:
    - name: merge
      eventSourceName: github
      eventName: all-events
      filters:
        data:
          - path: headers.X-Github-Event
            type: string
            value:
              - push
          - path: body.ref
            type: string
            value:
              - refs/heads/main
              - refs/heads/stage
          - path: body.repository.name
            type: string
            value:
              - {{ $app.name }}

  triggers:
    - template:
        name: github-workflow-trigger
        k8s:
          operation: create
          source:
            resource:
              apiVersion: argoproj.io/v1alpha1
              kind: Workflow
              metadata:
                generateName: github-
              spec:
                entrypoint: main
                onExit: exit-handler
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
                arguments:
                  parameters:
                    - name: repo-owner  # 0
                    - name: repo-name   # 1
                    - name: repo-url    # 2
                    - name: repo-ssh    # 3
                    - name: branch      # 4
                    - name: sha         # 5
                    - name: short-sha   # 6
                templates:
                  - name: main
                    inputs:
                      parameters:
                        - name: repo-name
                        - name: repo-owner
                        - name: repo-url
                        - name: repo-ssh
                        - name: branch
                        - name: sha
                        - name: short-sha
                    dag:
                      tasks:
                      - name: status-pending
                        templateRef:
                          name: github-status
                          template: main
                        arguments:
                          parameters:
                          - name: name 
                            value: argo-events
                          - name: description 
                            value: Build and Deploy
                          - name: repo
                            value: '{{`{{inputs.parameters.repo-owner}}`}}/{{`{{inputs.parameters.repo-name}}`}}'
                          - name: sha
                            value: '{{`{{inputs.parameters.sha}}`}}'
                          - name: status
                            value: pending

                      - name: build-image
                        depends: status-pending
                        templateRef:
                          name: kaniko
                          template: main
                        arguments:
                          parameters:
                          - name: repo
                            value: "{{`{{inputs.parameters.repo-url}}`}}"
                          - name: revision
                            value: '{{`{{inputs.parameters.sha}}`}}'
                          - name: image
                            value: 2xnone/appelsin-{{ $app.name }}
                          - name: tag
                            value: '{{`{{inputs.parameters.short-sha}}`}}'
                          - name: dockerfile
                            value: {{ $app.dockerfile }}
                          {{- if $app.buildArg }}
                          - name: buildarg
                            value: 'SYSENV={{`{{inputs.parameters.branch}}`}}'
                          {{- end }}

                      - name: deploy
                        depends: build-image
                        templateRef:
                          name: deploy
                          template: main
                        arguments:
                          parameters:
                          - name: repo
                            value: git@github.com:softserve-appelsin/infra.git
                          - name: revision
                            value: main
                          - name: manifest 
                            value: apps/{{ $app.name }}/{{`{{inputs.parameters.branch}}`}}.yaml
                          - name: yaml_path
                            value: image.tag
                          - name: tag
                            value: '{{`{{inputs.parameters.short-sha}}`}}'

                  - name: exit-handler
                    inputs:
                      parameters:
                        - name: repo-name
                        - name: repo-owner
                        - name: branch
                        - name: sha
                    dag:
                      tasks:
                      # SUCCESS
                      - name: github-status-success
                        when: "'{{`{{workflow.status}}`}}' == 'Succeeded'"
                        templateRef:
                          name: github-status
                          template: main
                        arguments:
                          parameters:
                          - name: name 
                            value: argo-events
                          - name: description 
                            value: Deploy successful
                          - name: repo
                            value: '{{`{{inputs.parameters.repo-owner}}`}}/{{`{{inputs.parameters.repo-name}}`}}'
                          - name: sha
                            value: '{{`{{inputs.parameters.sha}}`}}'
                          - name: status
                            value: success
                      - name: telegram-status-success
                        when: "'{{`{{workflow.status}}`}}' == 'Succeeded'"
                        templateRef:
                          name: telegram-send
                          template: main
                        arguments:
                          parameters:
                          - name: message
                            value: '✅ {{`{{inputs.parameters.repo-owner}}`}}/{{`{{inputs.parameters.repo-name}}`}} {{`{{inputs.parameters.branch }}`}} deployed'

                    # FAILURE
                      - name: github-status-failure
                        when: "'{{`{{workflow.status}}`}}' != 'Succeeded'"
                        templateRef:
                          name: github-status
                          template: main
                        arguments:
                          parameters:
                          - name: name
                            value: argo-events
                          - name: description
                            value: Deploy failed
                          - name: repo
                            value: '{{`{{inputs.parameters.repo-owner}}`}}/{{`{{inputs.parameters.repo-name}}`}}'
                          - name: sha
                            value: '{{`{{inputs.parameters.sha}}`}}'
                          - name: status
                            value: failure
                      - name: telegram-status-failure
                        when: "'{{`{{workflow.status}}`}}' != 'Succeeded'"
                        templateRef:
                          name: telegram-send
                          template: main
                        arguments:
                          parameters:
                          - name: message
                            value: '❌ {{`{{inputs.parameters.repo-owner}}`}}/{{`{{inputs.parameters.repo-name}}`}} {{`{{inputs.parameters.branch}}`}} deployment failed'
          parameters:
            # Workflow name  <owner>-<repo>-pr-<pr-no>-<short-sha>
            - src:
                dependencyName: merge
                dataTemplate: "{{`{{ .Input.body.repository.owner.login }}`}}-{{`{{ .Input.body.repository.name }}`}}-push-{{`{{ .Input.body.after | substr 0 7 }}`}}"
              dest: metadata.name
              operation: append
            # repo owner
            - src:
                dependencyName: merge
                dataKey: body.repository.owner.login
              dest: spec.arguments.parameters.0.value
            # repo name
            - src:
                dependencyName: merge
                dataKey: body.repository.name
              dest: spec.arguments.parameters.1.value
            # repo url
            - src:
                dependencyName: merge
                dataTemplate: "https://github.com/{{`{{ .Input.body.repository.owner.login }}`}}/{{`{{ .Input.body.repository.name }}`}}"
              dest: spec.arguments.parameters.2.value
            # repo ssh
            - src:
                dependencyName: merge
                dataTemplate: "git@github.com:{{`{{ .Input.body.repository.owner.login }}`}}/{{`{{ .Input.body.repository.name }}`}}"
              dest: spec.arguments.parameters.3.value
            # branch
            - src:
                dependencyName: merge
                dataTemplate: '{{`{{ index (splitList "/" .Input.body.ref ) 2 }}`}}'
              dest: spec.arguments.parameters.4.value
            # sha
            - src:
                dependencyName: merge
                dataTemplate: "{{`{{ .Input.body.after }}`}}"
              dest: spec.arguments.parameters.5.value
            # short-sha
            - src:
                dependencyName: merge
                dataTemplate: "{{`{{ .Input.body.after | substr 0 7 }}`}}"
              dest: spec.arguments.parameters.6.value

      retryStrategy:
        steps: 3
---
{{ end }}
