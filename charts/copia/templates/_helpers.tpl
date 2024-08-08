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
{{- default "conversion-manager" .Values.conversionManager.nameOverride | trunc 63 | trimSuffix "-" -}}
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
Fullname suffixed with -conversion-manager
Adds the 20 char truncation to app.fullname
*/}}
{{- define "app.conversion-manager.fullname" -}}
{{- if .Values.conversionManager.fullnameOverride -}}
{{- .Values.conversionManager.fullnameOverride | trunc 20 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-conversion-manager" (include "app.fullname" .) -}}
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
{{- define "app.conversion-manager.image" -}}
{{- $name := .Values.conversionManager.image.repository -}}
{{- if hasKey .Values.conversionManager.image "version" -}}
{{- printf "%s:%s" $name .Values.conversionManager.image.version -}}
{{- else if hasKey .Values.conversionManager.image "tag" -}}
{{- printf "%s:%s" $name .Values.conversionManager.image.tag -}}
{{- else -}}
{{- printf "%s:%s" $name .Chart.AppVersion -}}
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
{{- if hasKey .Values.conversionManager.image "version" -}}
app.kubernetes.io/version: {{ .Values.conversionManager.image.version| quote }}
version: {{ .Values.conversionManager.image.version| quote }}
{{- else if hasKey .Values.conversionManager.image "tag" }}
app.kubernetes.io/version: {{ .Values.conversionManager.image.tag| quote }}
version: {{ .Values.conversionManager.image.tag| quote }}
{{- else }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
version: {{ .Chart.AppVersion | quote }}
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
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
