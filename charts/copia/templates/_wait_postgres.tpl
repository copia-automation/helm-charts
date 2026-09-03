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
(Crossplane writeConnectionSecretToRef).

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
Wait for RDS using Windsor app-role credentials + Instance connection Secret.

  app-credentials (Windsor CronJob): username, password
  connection Secret (Instance writeConnectionSecretToRef): host/endpoint, port

Database name comes from chart values (appDatabase), not the Secrets.
*/}}
{{- define "copia.waitPostgres.windsor.initContainer" -}}
- name: {{ .name }}
  image: postgres:16-alpine
  imagePullPolicy: IfNotPresent
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      CONN=/etc/db-connection
      APP=/etc/app-credentials
      read_file() {
        dir="$1"; shift
        for key in "$@"; do
          if [ -e "${dir}/${key}" ]; then
            tr -d '\n' < "${dir}/${key}"
            return 0
          fi
        done
        return 1
      }
      host="$(read_file "$CONN" host endpoint address || true)"
      if [ -z "${host}" ]; then
        echo "missing host/endpoint in ${CONN}; keys:" >&2
        ls -1 "${CONN}" >&2 || true
        exit 1
      fi
      host="${host%%:*}"
      port="$(read_file "$CONN" port || echo 5432)"
      user="$(read_file "$APP" username user || true)"
      pass="$(read_file "$APP" password || true)"
      if [ -z "${user}" ] || [ -z "${pass}" ]; then
        echo "missing username/password in ${APP}; keys:" >&2
        ls -1 "${APP}" >&2 || true
        exit 1
      fi
      db={{ (.appDatabase | default "copia") | quote }}
      export PGHOST="$host" PGPORT="$port" PGUSER="$user" PGPASSWORD="$pass" PGDATABASE="$db"
      export PGSSLMODE={{ (.sslMode | default "require") | quote }}
{{- if .writeDbHostPath }}
      mkdir -p /cm-db
      printf '%s:%s' "$host" "$port" > {{ .writeDbHostPath | quote }}
{{- end }}
      echo "waiting for postgres ${PGHOST}:${PGPORT}/${PGDATABASE} as ${PGUSER}"
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
    - name: {{ .connectionVolumeName | default "db-connection" }}
      mountPath: /etc/db-connection
      readOnly: true
    - name: {{ .appCredentialsVolumeName | default "app-credentials" }}
      mountPath: /etc/app-credentials
      readOnly: true
{{- if .writeDbHostPath }}
    - name: {{ .writeDbHostVolume | default "cm-db" }}
      mountPath: /cm-db
{{- end }}
{{- end -}}
