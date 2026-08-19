{{/*
Init container that blocks until Postgres accepts connections and the target
database exists. Used so Copia and conversion-manager do not start during CNPG
initdb.
*/}}
{{- define "copia.waitPostgres.initContainer" -}}
- name: {{ .name }}
  image: postgres:16-alpine
  imagePullPolicy: IfNotPresent
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      max_attempts=180
      attempt=0
      until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t 3; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres readiness timeout (${PGHOST}:${PGPORT}/${PGDATABASE})"
          exit 1
        fi
        echo "waiting for postgres ${PGHOST}:${PGPORT}/${PGDATABASE} (${attempt}/${max_attempts})"
        sleep 2
      done
      attempt=0
      until psql -tAc "SELECT 1" | grep -q 1; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres login timeout (${PGHOST}:${PGPORT}/${PGDATABASE})"
          exit 1
        fi
        echo "waiting for database ${PGDATABASE} (${attempt}/${max_attempts})"
        sleep 2
      done
      echo "postgres is ready"
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 128Mi
  env:
    - name: PGHOST
      value: {{ .host | quote }}
    - name: PGPORT
      value: {{ .port | quote }}
    - name: PGUSER
      value: {{ .user | quote }}
    - name: PGPASSWORD
      value: {{ .password | quote }}
    - name: PGDATABASE
      value: {{ .database | quote }}
    - name: PGSSLMODE
      value: {{ .sslMode | default "prefer" | quote }}
{{- end -}}
