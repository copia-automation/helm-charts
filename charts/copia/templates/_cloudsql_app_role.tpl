{{/*
Chart-owned Windsor Cloud SQL app-role (same mechanics as
kustomize/provisioning/resources/crossplane/gcp-cloudsql/app-role).
*/}}
{{- define "copia.cloudsql.appRole.enabled" -}}
{{- if eq "true" (include "copia.cloudsql.enabled" .) -}}
{{- $off := and .Values.cloudsql .Values.cloudsql.appRole (eq .Values.cloudsql.appRole.enabled false) -}}
{{- if not $off -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "copia.cloudsql.appRole.namespace" -}}
{{- if and .Values.cloudsql .Values.cloudsql.appRole .Values.cloudsql.appRole.namespace }}
{{- .Values.cloudsql.appRole.namespace }}
{{- else -}}
system-provisioning
{{- end -}}
{{- end -}}

{{- define "copia.cloudsql.appRole.serviceAccountName" -}}
{{- if and .Values.cloudsql .Values.cloudsql.appRole .Values.cloudsql.appRole.serviceAccountName }}
{{- .Values.cloudsql.appRole.serviceAccountName }}
{{- else -}}
cloudsql-bootstrap
{{- end -}}
{{- end -}}

{{- define "copia.cloudsql.appRole.kubectlImage" -}}
{{- if and .Values.cloudsql .Values.cloudsql.appRole .Values.cloudsql.appRole.kubectlImage }}
{{- .Values.cloudsql.appRole.kubectlImage }}
{{- else -}}
alpine/k8s:1.34.9@sha256:72c921a10c53ab749674e828ad12b776d006481c852bba7dd89e149ceed666f3
{{- end -}}
{{- end -}}

{{- define "copia.cloudsql.appRole.postgresImage" -}}
{{- if and .Values.cloudsql .Values.cloudsql.appRole .Values.cloudsql.appRole.postgresImage }}
{{- .Values.cloudsql.appRole.postgresImage }}
{{- else -}}
postgres:16.15-alpine@sha256:cf78e76683b9ca8c5733cbbdce6c9262b45b6767934dd0a95e671f9a0fc20685
{{- end -}}
{{- end -}}

{{/*
Emit Windsor-equivalent app-role RBAC + CronJob for one DatabaseInstance.

Expects dict:
  root                  - chart context
  instanceName          - DatabaseInstance CR name
  databaseName          - Postgres database (role becomes <databaseName>_app)
  secretName            - K8s Secret name for username/password
  connectionSecretName  - K8s Secret name for host/port
  adminSecretName       - Terraform admin secret in system-provisioning
  grantSql              - one-line GRANT SQL
  labels                - optional label helper output string
*/}}
{{- define "copia.cloudsql.appRole.resources" -}}
{{- $root := .root -}}
{{- $instance := .instanceName -}}
{{- $db := .databaseName -}}
{{- $secret := .secretName -}}
{{- $connSecret := .connectionSecretName -}}
{{- $adminSecret := .adminSecretName -}}
{{- $grant := .grantSql -}}
{{- $ns := include "copia.cloudsql.appRole.namespace" $root -}}
{{- $sa := include "copia.cloudsql.appRole.serviceAccountName" $root -}}
{{- $targetNs := $root.Release.Namespace -}}
{{- $kubectlImg := include "copia.cloudsql.appRole.kubectlImage" $root -}}
{{- $pgImg := include "copia.cloudsql.appRole.postgresImage" $root }}
---
# Chart opt-in to Windsor app-role (same mechanics as
# kustomize/provisioning/resources/crossplane/gcp-cloudsql/app-role). Creates
# <dbname>_app and publishes <instance>-app-credentials, never the admin
# password. Also writes <instance>-connection (host from privateIpAddress)
# because DatabaseInstance does not fill writeConnectionSecretToRef the way
# RDS Instance does. Uses the platform ServiceAccount cloudsql-bootstrap.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $instance }}-app-reader
  labels:
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
rules:
  - apiGroups:
      - sql.gcp.upbound.io
    resources:
      - databaseinstances
    resourceNames:
      - {{ $instance }}
    verbs:
      - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $instance }}-app-reader
  labels:
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ $instance }}-app-reader
subjects:
  - kind: ServiceAccount
    name: {{ $sa }}
    namespace: {{ $ns }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $instance }}-app-reader
  namespace: {{ $targetNs }}
  labels:
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
rules:
  - apiGroups:
      - ""
    resources:
      - secrets
    resourceNames:
      - {{ $secret }}
      - {{ $connSecret }}
    verbs:
      - get
      - update
      - patch
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $instance }}-app-reader
  namespace: {{ $targetNs }}
  labels:
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $instance }}-app-reader
subjects:
  - kind: ServiceAccount
    name: {{ $sa }}
    namespace: {{ $ns }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $instance }}-provision-app-role
  namespace: {{ $ns }}
  labels:
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
spec:
  {{- $schedule := "*/5 * * * *" }}
  {{- if and $root.Values.cloudsql $root.Values.cloudsql.appRole $root.Values.cloudsql.appRole.schedule }}
  {{- $schedule = $root.Values.cloudsql.appRole.schedule }}
  {{- end }}
  schedule: {{ $schedule | quote }}
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 300
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      backoffLimit: 2
      activeDeadlineSeconds: 600
      template:
        spec:
          serviceAccountName: {{ $sa }}
          restartPolicy: Never
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            runAsGroup: 1000
            fsGroup: 1000
          initContainers:
            - name: fetch-admin-credentials
              image: {{ $kubectlImg }}
              securityContext:
                allowPrivilegeEscalation: false
                capabilities:
                  drop:
                    - ALL
                seccompProfile:
                  type: RuntimeDefault
              command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail

                  READY=$(kubectl get databaseinstance.sql.gcp.upbound.io {{ $instance }} \
                    -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
                  if [ "$READY" != "True" ]; then
                    echo "{{ $instance }} DatabaseInstance not Ready yet, skipping this tick."
                    touch /shared/skip
                    exit 0
                  fi

                  kubectl get databaseinstance.sql.gcp.upbound.io {{ $instance }} \
                    -o jsonpath='{.status.atProvider.privateIpAddress}' > /shared/address

                  kubectl get secret {{ $adminSecret }} \
                    -n {{ $ns }} -o jsonpath='{.data.username}' | base64 -d > /shared/admin-username
                  kubectl get secret {{ $adminSecret }} \
                    -n {{ $ns }} -o jsonpath='{.data.password}' | base64 -d > /shared/admin-password

                  EXISTING=$(kubectl get secret {{ $secret }} \
                    -n {{ $targetNs }} -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "")
                  if [ -n "$EXISTING" ]; then
                    echo -n "$EXISTING" > /shared/app-password
                  else
                    head -c 24 /dev/urandom | base64 | tr -d '/+=\n' > /shared/app-password
                    touch /shared/needs-password-set
                  fi
              volumeMounts:
                - name: shared
                  mountPath: /shared
            - name: provision-app-role
              image: {{ $pgImg }}
              securityContext:
                allowPrivilegeEscalation: false
                capabilities:
                  drop:
                    - ALL
                seccompProfile:
                  type: RuntimeDefault
              command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail

                  if [ -f /shared/skip ]; then
                    echo "Skipping, nothing to provision this tick."
                    exit 0
                  fi

                  ADDRESS=$(cat /shared/address)
                  ADMIN_USER=$(cat /shared/admin-username)
                  APP_PASSWORD=$(cat /shared/app-password)
                  NEEDS_PASSWORD_SET=false
                  if [ -f /shared/needs-password-set ]; then
                    NEEDS_PASSWORD_SET=true
                  fi

                  PGPASSWORD=$(cat /shared/admin-password) psql -h "$ADDRESS" -U "$ADMIN_USER" \
                    -d {{ $db }} -v ON_ERROR_STOP=1 <<SQL
                  DO \$\$
                  BEGIN
                    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '{{ $db }}_app') THEN
                      CREATE ROLE {{ $db }}_app WITH LOGIN PASSWORD '$APP_PASSWORD';
                    ELSIF $NEEDS_PASSWORD_SET THEN
                      ALTER ROLE {{ $db }}_app WITH PASSWORD '$APP_PASSWORD';
                    END IF;
                  END
                  \$\$;
                  {{ $grant }}
                  SQL
              volumeMounts:
                - name: shared
                  mountPath: /shared
          containers:
            - name: publish-app-secret
              image: {{ $kubectlImg }}
              securityContext:
                allowPrivilegeEscalation: false
                capabilities:
                  drop:
                    - ALL
                seccompProfile:
                  type: RuntimeDefault
              command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail

                  if [ -f /shared/skip ]; then
                    echo "Skipping, nothing to publish this tick."
                    exit 0
                  fi

                  kubectl create secret generic {{ $secret }} \
                    -n {{ $targetNs }} \
                    --from-literal=username="{{ $db }}_app" \
                    --from-literal=password="$(cat /shared/app-password)" \
                    --dry-run=client -o yaml | kubectl apply -f -

                  kubectl create secret generic {{ $connSecret }} \
                    -n {{ $targetNs }} \
                    --from-literal=host="$(cat /shared/address)" \
                    --from-literal=endpoint="$(cat /shared/address)" \
                    --from-literal=address="$(cat /shared/address)" \
                    --from-literal=port="5432" \
                    --dry-run=client -o yaml | kubectl apply -f -
              volumeMounts:
                - name: shared
                  mountPath: /shared
          volumes:
            - name: shared
              emptyDir:
                medium: Memory

{{- end }}
