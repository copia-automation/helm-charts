{{/*
Default one-line GRANT SQL for Windsor-style <dbname>_app (semicolon-separated).
Chart opts into app-role mechanics; grants are app-specific.
*/}}
{{- define "copia.rds.appRole.defaultGrantSql" -}}
{{- $db := . -}}
{{- $role := printf "%s_app" $db -}}
GRANT CONNECT ON DATABASE {{ $db }} TO {{ $role }}; GRANT USAGE, CREATE ON SCHEMA public TO {{ $role }}; GRANT ALL ON ALL TABLES IN SCHEMA public TO {{ $role }}; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO {{ $role }}; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO {{ $role }}; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO {{ $role }};
{{- end -}}

{{- define "copia.rds.appRole.enabled" -}}
{{- if eq "true" (include "copia.rds.enabled" .) -}}
{{- $off := and .Values.rds .Values.rds.appRole (eq .Values.rds.appRole.enabled false) -}}
{{- if not $off -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "copia.rds.appRole.namespace" -}}
{{- if and .Values.rds .Values.rds.appRole .Values.rds.appRole.namespace }}
{{- .Values.rds.appRole.namespace }}
{{- else -}}
system-provisioning
{{- end -}}
{{- end -}}

{{- define "copia.rds.appRole.serviceAccountName" -}}
{{- if and .Values.rds .Values.rds.appRole .Values.rds.appRole.serviceAccountName }}
{{- .Values.rds.appRole.serviceAccountName }}
{{- else -}}
rds-secret-reader
{{- end -}}
{{- end -}}

{{- define "copia.rds.appRole.kubectlImage" -}}
{{- if and .Values.rds .Values.rds.appRole .Values.rds.appRole.kubectlImage }}
{{- .Values.rds.appRole.kubectlImage }}
{{- else -}}
alpine/k8s:1.34.9@sha256:72c921a10c53ab749674e828ad12b776d006481c852bba7dd89e149ceed666f3
{{- end -}}
{{- end -}}

{{- define "copia.rds.appRole.postgresImage" -}}
{{- if and .Values.rds .Values.rds.appRole .Values.rds.appRole.postgresImage }}
{{- .Values.rds.appRole.postgresImage }}
{{- else -}}
postgres:16.15-alpine@sha256:cf78e76683b9ca8c5733cbbdce6c9262b45b6767934dd0a95e671f9a0fc20685
{{- end -}}
{{- end -}}

{{/*
Emit Windsor-equivalent app-role RBAC + CronJob for one Instance.

Expects dict:
  root            - chart context
  instanceName    - Instance CR name
  databaseName    - Postgres database (role becomes <databaseName>_app)
  secretName      - K8s Secret name for username/password
  grantSql        - one-line GRANT SQL
  labels          - optional label helper output string
*/}}
{{- define "copia.rds.appRole.resources" -}}
{{- $root := .root -}}
{{- $instance := .instanceName -}}
{{- $db := .databaseName -}}
{{- $secret := .secretName -}}
{{- $grant := .grantSql -}}
{{- $ns := include "copia.rds.appRole.namespace" $root -}}
{{- $sa := include "copia.rds.appRole.serviceAccountName" $root -}}
{{- $targetNs := $root.Release.Namespace -}}
{{- $kubectlImg := include "copia.rds.appRole.kubectlImage" $root -}}
{{- $pgImg := include "copia.rds.appRole.postgresImage" $root }}
---
# Chart opt-in to Windsor app-role (same mechanics as
# kustomize/provisioning/resources/crossplane/aws-rds/app-role). Creates
# <dbname>_app and publishes <instance>-app-credentials — never the master
# password. Uses the platform ServiceAccount rds-secret-reader.
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
      - rds.aws.upbound.io
    resources:
      - instances
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
  {{- if and $root.Values.rds $root.Values.rds.appRole $root.Values.rds.appRole.schedule }}
  {{- $schedule = $root.Values.rds.appRole.schedule }}
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

                  READY=$(kubectl get instance.rds.aws.upbound.io {{ $instance }} \
                    -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
                  if [ "$READY" != "True" ]; then
                    echo "{{ $instance }} Instance not Ready yet, skipping this tick."
                    touch /shared/skip
                    exit 0
                  fi

                  kubectl get instance.rds.aws.upbound.io {{ $instance }} \
                    -o jsonpath='{.status.atProvider.address}' > /shared/address

                  SECRET_ARN=$(kubectl get instance.rds.aws.upbound.io {{ $instance }} \
                    -o jsonpath='{.status.atProvider.masterUserSecret[0].secretArn}')

                  SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" \
                    --query SecretString --output text)
                  echo "$SECRET_JSON" | jq -r '.username' > /shared/admin-username
                  echo "$SECRET_JSON" | jq -r '.password' > /shared/admin-password

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
              volumeMounts:
                - name: shared
                  mountPath: /shared
          volumes:
            - name: shared
              emptyDir:
                medium: Memory

{{- end }}
