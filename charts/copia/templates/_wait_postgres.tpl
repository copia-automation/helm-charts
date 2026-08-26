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

{{/*
Init container that waits on Postgres using credentials from a connection Secret
(Crossplane writeConnectionSecretToRef / nexus-style connection Secret).

Secret keys (preferred): host, port, user, password, dbname
Also accepts Crossplane defaults: endpoint/username (and optional attribute.*).
Kubelet blocks start until required keys exist (optional: false).
*/}}
{{- define "copia.waitPostgres.fromSecret.initContainer" -}}
- name: {{ .name }}
  image: postgres:16-alpine
  imagePullPolicy: IfNotPresent
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      SECRET=/etc/db-secret
      read_secret() {
        for key in "$@"; do
          if [ -e "${SECRET}/${key}" ]; then
            tr -d '\n' < "${SECRET}/${key}"
            return 0
          fi
        done
        return 1
      }
      host="$(read_secret host endpoint address || true)"
      if [ -z "${host}" ]; then
        echo "missing host/endpoint in ${SECRET}; keys:" >&2
        ls -1 "${SECRET}" >&2 || true
        exit 1
      fi
      host="${host%%:*}"
      port="$(read_secret port || echo 5432)"
{{- if .user }}
      user={{ .user | quote }}
{{- else }}
      user="$(read_secret user username || true)"
{{- end }}
{{- if .password }}
      pass={{ .password | quote }}
{{- else }}
      pass="$(read_secret password attribute.password || true)"
{{- end }}
{{- if .appDatabase }}
      db={{ .appDatabase | quote }}
{{- else }}
      db="$(read_secret dbname database || echo {{ (.defaultDatabase | default "copia") | quote }})"
{{- end }}
      export PGHOST="$host" PGPORT="$port" PGUSER="$user" PGPASSWORD="$pass" PGDATABASE="$db"
      export PGSSLMODE={{ (.sslMode | default "require") | quote }}
{{- if .writeDbHostPath }}
      mkdir -p "$(dirname {{ .writeDbHostPath | quote }})"
      printf '%s:%s' "$host" "$port" > {{ .writeDbHostPath | quote }}
{{- end }}
      echo "waiting for postgres ${PGHOST}:${PGPORT}/${PGDATABASE}"
      max_attempts=180
      attempt=0
      until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t 3; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres readiness timeout"
          exit 1
        fi
        sleep 2
      done
      attempt=0
      until psql -tAc "SELECT 1" | grep -q 1; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres login timeout"
          exit 1
        fi
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
  volumeMounts:
    - name: {{ .volumeName | default "db-secret" }}
      mountPath: /etc/db-secret
      readOnly: true
{{- if .writeDbHostPath }}
    - name: {{ .writeDbHostVolume | default "cm-db" }}
      mountPath: /cm-db
{{- end }}
{{- end -}}

{{/*
Bootstrap conversion-manager database and role on the Crossplane RDS instance
(single RDS, second database — mirrors CloudNativePG Database + managed role).
Connects with master credentials from the connection Secret.
*/}}
{{- define "copia.crossplane.bootstrapConversionManager.initContainer" -}}
- name: cm-bootstrap-db
  image: postgres:16-alpine
  imagePullPolicy: IfNotPresent
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      SECRET=/etc/db-secret
      read_secret() {
        for key in "$@"; do
          if [ -e "${SECRET}/${key}" ]; then
            tr -d '\n' < "${SECRET}/${key}"
            return 0
          fi
        done
        return 1
      }
      host="$(read_secret host endpoint address || true)"
      if [ -z "${host}" ]; then
        echo "missing host/endpoint in ${SECRET}" >&2
        exit 1
      fi
      host="${host%%:*}"
      port="$(read_secret port || echo 5432)"
      master_user="$(read_secret user username || true)"
      master_pass="$(read_secret password attribute.password || true)"
      export PGHOST="$host" PGPORT="$port" PGUSER="$master_user" PGPASSWORD="$master_pass" PGDATABASE=postgres
      export PGSSLMODE={{ (.sslMode | default "require") | quote }}
      printf '%s:%s' "$host" "$port" > /cm-db/DB_HOST
      max_attempts=180
      attempt=0
      until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t 3; do
        attempt=$((attempt + 1))
        if [ "$attempt" -ge "$max_attempts" ]; then
          echo "postgres readiness timeout (bootstrap)"
          exit 1
        fi
        sleep 2
      done
      cm_user={{ .cmUser | quote }}
      cm_db={{ .cmDatabase | quote }}
      cm_pass={{ .cmPassword | quote }}
      cm_pass_sql="${cm_pass//\'/\'\'}"
      role_exists="$(psql -tAc "SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '${cm_user}'" || true)"
      if [ "$role_exists" != "1" ]; then
        psql -v ON_ERROR_STOP=1 -c "CREATE USER \"${cm_user}\" WITH PASSWORD '${cm_pass_sql}'"
      else
        psql -v ON_ERROR_STOP=1 -c "ALTER USER \"${cm_user}\" WITH PASSWORD '${cm_pass_sql}'"
      fi
      db_exists="$(psql -tAc "SELECT 1 FROM pg_database WHERE datname = '${cm_db}'" || true)"
      if [ "$db_exists" != "1" ]; then
        psql -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"${cm_db}\" OWNER \"${cm_user}\""
      fi
      psql -v ON_ERROR_STOP=1 -c "GRANT ALL PRIVILEGES ON DATABASE \"${cm_db}\" TO \"${cm_user}\""
      echo "conversion-manager database ${cm_db} ready"
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 128Mi
  volumeMounts:
    - name: {{ .volumeName | default "db-secret" }}
      mountPath: /etc/db-secret
      readOnly: true
    - name: {{ .writeDbHostVolume | default "cm-db" }}
      mountPath: /cm-db
{{- end -}}
