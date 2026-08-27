{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "app.conversion-manager.name" -}}
{{- default "conversion-manager" .Values.conversion_manager_service.nameOverride | trunc 43 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds an extra 20 characters, so truncation should be 63-20=43.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 43 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 43 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 43 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Fullname suffixed with -cm
Adds the 43 char truncation to app.fullname
*/}}
{{- define "app.conversion-manager.fullname" -}}
{{- if .Values.conversion_manager_service.fullnameOverride -}}
{{- .Values.conversion_manager_service.fullnameOverride | trunc 43 | trimSuffix "-" -}}
{{- else -}}
{{- default "conversion-manager" -}}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image name and tag used by the deployment.
*/}}
{{- define "app.image" -}}
{{- $name := .Values.image.repository -}}
{{- if hasKey .Values.image "version" -}}
{{- printf "%s:%s" $name .Values.image.version -}}
{{- else if hasKey .Values.image "tag" -}}
{{- printf "%s:%s" $name .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s" $name .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Create image name and tag used by the deployment.
*/}}
{{- define "cm.image" -}}
{{- $name := .Values.conversion_manager_service.deployment.image.repository -}}
{{- if hasKey .Values.conversion_manager_service.deployment.image "version" -}}
{{- printf "%s:%s" $name .Values.conversion_manager_service.deployment.image.version -}}
{{- else if hasKey .Values.conversion_manager_service.deployment.image "tag" -}}
{{- printf "%s:%s" $name .Values.conversion_manager_service.deployment.image.tag -}}
{{- else -}}
{{- printf "%s:%s" $name .Values.cmVersion -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
app: {{ include "app.name" . }}
{{ include "app.selectorLabels" . }}
{{- if hasKey .Values.image "version" -}}
app.kubernetes.io/version: {{ .Values.image.version| quote }}
version: {{ .Values.image.version| quote }}
{{- else if hasKey .Values.image "tag" }}
app.kubernetes.io/version: {{ .Values.image.tag| quote }}
version: {{ .Values.image.tag| quote }}
{{- else }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Conversion-manager labels
*/}}
{{- define "app.conversion-manager.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
app: {{ include "app.conversion-manager.name" . }}
{{ include "app.conversion-manager.selectorLabels" . }}
{{- if hasKey .Values.conversion_manager_service.deployment.image "version" -}}
app.kubernetes.io/version: {{ .Values.conversion_manager_service.deployment.image.version| quote }}
version: {{ .Values.conversion_manager_service.deployment.image.version| quote }}
{{- else if hasKey .Values.conversion_manager_service.deployment.image "tag" }}
app.kubernetes.io/version: {{ .Values.conversion_manager_service.deployment.image.tag| quote }}
version: {{ .Values.conversion_manager_service.deployment.image.tag| quote }}
{{- else }}
app.kubernetes.io/version: {{ .Values.cmVersion | quote }}
version: {{ .Values.cmVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "app.conversion-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.conversion-manager.name" . }}
app.kubernetes.io/instance: {{ include "app.conversion-manager.name" . }}
{{- end -}}

{{/*
Return "true" when the chart should render a CloudNativePG Cluster.
*/}}
{{- define "copia.cnpg.enabled" -}}
{{- if and .Values.cloudnativePG .Values.cloudnativePG.enabled -}}
true
{{- end -}}
{{- end -}}

{{/*
CloudNativePG Cluster object name. DNS label, kept short enough for -rw/-r suffixes.
*/}}
{{- define "copia.cnpg.clusterName" -}}
{{- if and .Values.cloudnativePG .Values.cloudnativePG.clusterName }}
{{- .Values.cloudnativePG.clusterName | trunc 51 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-pg" (include "app.fullname" .) | trunc 51 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{/*
Postgres application owner. Defaults to copia. Reserved CNPG roles are rejected.
*/}}
{{- define "copia.database.user" -}}
{{- $user := "copia" -}}
{{- if and .Values.copia .Values.copia.config .Values.copia.config.database .Values.copia.config.database.USER -}}
{{- $user = .Values.copia.config.database.USER -}}
{{- end -}}
{{- if and (eq "true" (include "copia.cnpg.enabled" .)) (or (eq $user "postgres") (eq $user "streaming_replica")) -}}
{{- fail "cloudnativePG.enabled cannot use database USER postgres or streaming_replica (reserved by CloudNativePG)." -}}
{{- end -}}
{{- $user -}}
{{- end -}}

{{/*
Postgres database name for Copia. Defaults to copia.
*/}}
{{- define "copia.database.name" -}}
{{- if and .Values.copia .Values.copia.config .Values.copia.config.database .Values.copia.config.database.NAME -}}
{{- .Values.copia.config.database.NAME -}}
{{- else -}}
copia
{{- end -}}
{{- end -}}

{{/*
host:port used by Copia and conversion-manager. When CloudNativePG is enabled this
is the Cluster read-write Service. A customer-set HOST/DB_HOST is an error unless
it is empty, a localhost placeholder (chart default), or already the RW Service.
*/}}
{{- define "copia.cnpg.isPlaceholderHost" -}}
{{- $h := . | toString | trim | lower -}}
{{- if or (eq $h "") (eq $h "localhost") (hasPrefix "localhost:" $h) -}}
true
{{- end -}}
{{- end -}}

{{- define "copia.cnpg.validateHosts" -}}
{{- if eq "true" (include "copia.cnpg.enabled" .) -}}
{{- $expected := printf "%s-rw:5432" (include "copia.cnpg.clusterName" .) -}}
{{- $host := "" -}}
{{- if and .Values.copia .Values.copia.config .Values.copia.config.database .Values.copia.config.database.HOST -}}
{{- $host = .Values.copia.config.database.HOST | toString -}}
{{- end -}}
{{- if and $host (ne $host $expected) (ne (include "copia.cnpg.isPlaceholderHost" $host) "true") -}}
{{- fail "cloudnativePG.enabled is true; omit copia.config.database.HOST." -}}
{{- end -}}
{{- $cmHost := "" -}}
{{- $cm := .Values.conversion_manager_service -}}
{{- if and $cm $cm.configmap $cm.configmap.DB_HOST -}}
{{- $cmHost = $cm.configmap.DB_HOST | toString -}}
{{- end -}}
{{- if and $cmHost (ne $cmHost $expected) (ne (include "copia.cnpg.isPlaceholderHost" $cmHost) "true") -}}
{{- fail "cloudnativePG.enabled is true; omit conversion_manager_service.configmap.DB_HOST." -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "copia.database.hostPort" -}}
{{- if eq "true" (include "copia.cnpg.enabled" .) }}
{{- $_ := include "copia.cnpg.validateHosts" . }}
{{- printf "%s-rw:5432" (include "copia.cnpg.clusterName" .) }}
{{- else if and .Values.copia .Values.copia.config .Values.copia.config.database .Values.copia.config.database.HOST }}
{{- .Values.copia.config.database.HOST }}
{{- end }}
{{- end -}}

{{- define "copia.database.host" -}}
{{- $hostPort := include "copia.database.hostPort" . | trim }}
{{- $parts := splitList ":" $hostPort }}
{{- index $parts 0 }}
{{- end -}}

{{- define "copia.database.port" -}}
{{- $hostPort := include "copia.database.hostPort" . | trim }}
{{- $parts := splitList ":" $hostPort }}
{{- if eq (len $parts) 2 }}{{ index $parts 1 }}{{ else }}5432{{ end }}
{{- end -}}

{{/*
Return "true" when conversion-manager should get a CNPG Database and role.
*/}}
{{- define "copia.cnpg.conversionManager.enabled" -}}
{{- if eq "true" (include "copia.cnpg.enabled" .) -}}
{{- if and .Values.conversion_manager_service .Values.conversion_manager_service.enabled -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
conversion-manager role name. Remaps reserved postgres/streaming_replica names.
*/}}
{{- define "copia.cnpg.conversionManager.user" -}}
{{- $user := "conversion_manager" }}
{{- $cm := .Values.conversion_manager_service }}
{{- if and $cm $cm.configmap $cm.configmap.DB_USER }}
{{- $user = $cm.configmap.DB_USER }}
{{- end }}
{{- if or (eq $user "postgres") (eq $user "streaming_replica") }}
{{- $user = "conversion_manager" }}
{{- end }}
{{- $user }}
{{- end -}}

{{- define "copia.cnpg.conversionManager.database" -}}
{{- $cm := .Values.conversion_manager_service }}
{{- if and $cm $cm.configmap $cm.configmap.DB_NAME }}
{{- $cm.configmap.DB_NAME }}
{{- else }}
conversion_manager
{{- end }}
{{- end -}}

{{/*
Return "true" when the chart should emit a Crossplane Postgres Claim and read
DB credentials from a connection Secret (nexus keys: user/password/host/port/dbname).

Enable with crossplane.enabled=true or database.provider=crossplane.
Mutually exclusive with cloudnativePG.enabled.
*/}}
{{- define "copia.crossplane.enabled" -}}
{{- $fromBlock := and .Values.crossplane .Values.crossplane.enabled -}}
{{- $fromProvider := and .Values.database (eq (.Values.database.provider | default "") "crossplane") -}}
{{- if or $fromBlock $fromProvider -}}
{{- if eq "true" (include "copia.cnpg.enabled" .) -}}
{{- fail "crossplane and cloudnativePG cannot both be enabled; pick one database path." -}}
{{- end -}}
true
{{- end -}}
{{- end -}}

{{- define "copia.crossplane.claimName" -}}
{{- if and .Values.crossplane .Values.crossplane.claimName }}
{{- .Values.crossplane.claimName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-pg" (include "app.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{- define "copia.crossplane.connectionSecretName" -}}
{{- if and .Values.crossplane .Values.crossplane.connectionSecretName }}
{{- .Values.crossplane.connectionSecretName }}
{{- else }}
{{- printf "%s-db-app" (include "app.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{- define "copia.crossplane.conversionManager.enabled" -}}
{{- if eq "true" (include "copia.crossplane.enabled" .) -}}
{{- if and .Values.conversion_manager_service .Values.conversion_manager_service.enabled -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "copia.crossplane.validateHosts" -}}
{{- if eq "true" (include "copia.crossplane.enabled" .) -}}
{{- $host := "" -}}
{{- if and .Values.copia .Values.copia.config .Values.copia.config.database .Values.copia.config.database.HOST -}}
{{- $host = .Values.copia.config.database.HOST | toString -}}
{{- end -}}
{{- if and $host (ne (include "copia.cnpg.isPlaceholderHost" $host) "true") -}}
{{- fail "crossplane database provider is enabled; omit copia.config.database.HOST (and PASSWD) — credentials come from the connection Secret." -}}
{{- end -}}
{{- $cmHost := "" -}}
{{- $cm := .Values.conversion_manager_service -}}
{{- if and $cm $cm.configmap $cm.configmap.DB_HOST -}}
{{- $cmHost = $cm.configmap.DB_HOST | toString -}}
{{- end -}}
{{- if and $cmHost (ne (include "copia.cnpg.isPlaceholderHost" $cmHost) "true") -}}
{{- fail "crossplane database provider is enabled; omit conversion_manager_service.configmap.DB_HOST." -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "copia.crossplane.validateConversionManager" -}}
{{- if eq "true" (include "copia.crossplane.conversionManager.enabled" .) -}}
{{- $_ := include "copia.crossplane.validateHosts" . -}}
{{- if not (and .Values.conversion_manager_service.secret .Values.conversion_manager_service.secret.DB_PASSWORD) -}}
{{- fail "crossplane with conversion-manager requires conversion_manager_service.secret.DB_PASSWORD." -}}
{{- end -}}
{{- end -}}
{{- end -}}
