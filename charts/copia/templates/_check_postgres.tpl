{{/*
Container that verifies Postgres accepts the provided credentials. Fail-fast
relative to waitPostgres: this is a pre-install config check, not a startup wait.
PGPASSWORD comes from a hook Secret (passwordSecretName / passwordSecretKey).
*/}}
{{- define "copia.checkPostgres.container" -}}
- name: {{ .name }}
  image: postgres:16-alpine
  imagePullPolicy: IfNotPresent
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      export PGCONNECT_TIMEOUT=3
      max_attempts=12
      attempt=0
      until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t 2; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres check failed for ${CHECK_LABEL} (${PGHOST}:${PGPORT}/${PGDATABASE} user=${PGUSER})"
          echo "host is not reachable; confirm HOST/DB_HOST and network access from the cluster"
          exit 1
        fi
        echo "checking postgres ${PGHOST}:${PGPORT}/${PGDATABASE} (${attempt}/${max_attempts})"
        sleep 2
      done
      attempt=0
      until psql -tAc "SELECT 1" | grep -q 1; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres check failed for ${CHECK_LABEL} (${PGHOST}:${PGPORT}/${PGDATABASE} user=${PGUSER})"
          echo "login failed; confirm USER/DB_USER, NAME/DB_NAME, password, and SSL_MODE"
          exit 1
        fi
        echo "checking login ${PGDATABASE} (${attempt}/${max_attempts})"
        sleep 2
      done
      echo "postgres check passed for ${CHECK_LABEL} (${PGHOST}:${PGPORT}/${PGDATABASE})"
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 128Mi
  env:
    - name: CHECK_LABEL
      value: {{ .label | quote }}
    - name: PGHOST
      value: {{ .host | quote }}
    - name: PGPORT
      value: {{ .port | quote }}
    - name: PGUSER
      value: {{ .user | quote }}
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .passwordSecretName | quote }}
          key: {{ .passwordSecretKey | quote }}
    - name: PGDATABASE
      value: {{ .database | quote }}
    - name: PGSSLMODE
      value: {{ .sslMode | default "prefer" | quote }}
{{- end -}}
