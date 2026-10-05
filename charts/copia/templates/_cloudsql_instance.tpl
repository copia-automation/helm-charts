{{/*
Emit DatabaseInstance + Database + AppRole for one Cloud SQL instance.

Expects dict:
  root                  - chart context
  instanceName          - DatabaseInstance CR name (also GCP instance id)
  databaseName          - Postgres database (Database CR forProvider.name)
  appRoleName           - scoped Postgres application role
  appCredentialsSecretName - AppRole connection Secret
  connectionSecretName  - writeConnectionSecretToRef target
  tier                  - Cloud SQL machine tier
  diskSize              - disk size in GB
  labels                - optional label helper output string
*/}}
{{- define "copia.cloudsql.instanceResources" -}}
{{- $root := .root -}}
{{- $instance := .instanceName -}}
{{- $db := .databaseName -}}
{{- $appRole := .appRoleName -}}
{{- $appSecret := .appCredentialsSecretName -}}
{{- $connSecret := .connectionSecretName -}}
{{- $tier := .tier -}}
{{- $diskSize := .diskSize -}}
{{- $cs := $root.Values.cloudsql | default dict -}}
{{- $region := $cs.region -}}
{{- $network := $cs.privateNetwork -}}
{{- $version := $cs.databaseVersion | default "POSTGRES_16" -}}
{{- $edition := $cs.edition | default "ENTERPRISE" -}}
{{- $deletionPolicy := $cs.deletionPolicy | default "Delete" -}}
{{- $delProtect := false -}}
{{- if hasKey $cs "deletionProtection" -}}
{{- $delProtect = $cs.deletionProtection -}}
{{- end -}}
{{- $ipv4 := false -}}
{{- if hasKey $cs "ipv4Enabled" -}}
{{- $ipv4 = $cs.ipv4Enabled -}}
{{- end -}}
{{- /* Omit when empty so Windsor can inject. A set value is a BYO key and is kept. */ -}}
{{- $kms := $cs.encryptionKeyName | default "" -}}
---
# Platform installs Crossplane + provider-gcp-sql; this chart defines the
# instance. Windsor creates the admin user and the AppRole creates the scoped
# application login Secret in the release namespace.
apiVersion: sql.gcp.upbound.io/v1beta2
kind: DatabaseInstance
metadata:
  name: {{ $instance }}
  labels:
    copia.io/helm-release: {{ $root.Release.Name }}
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
  {{- if $cs.keepOnDelete }}
  annotations:
    helm.sh/resource-policy: keep
  {{- end }}
spec:
  deletionPolicy: {{ $deletionPolicy }}
  writeConnectionSecretToRef:
    name: {{ $connSecret }}
    namespace: {{ $root.Release.Namespace }}
  forProvider:
    region: {{ $region | quote }}
    databaseVersion: {{ $version | quote }}
    deletionProtection: {{ $delProtect }}
    {{- if $kms }}
    encryptionKeyName: {{ $kms | quote }}
    {{- end }}
    settings:
      # Enterprise unlocks db-f1-micro; Enterprise Plus rejects it.
      edition: {{ $edition | quote }}
      tier: {{ $tier | quote }}
      diskSize: {{ $diskSize }}
      ipConfiguration:
        ipv4Enabled: {{ $ipv4 }}
        {{- if $network }}
        privateNetwork: {{ $network | quote }}
        {{- end }}
---
apiVersion: sql.gcp.upbound.io/v1beta1
kind: Database
metadata:
  name: {{ printf "%s-db" $instance | trunc 63 | trimSuffix "-" }}
  labels:
    copia.io/helm-release: {{ $root.Release.Name }}
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
  {{- if $cs.keepOnDelete }}
  annotations:
    helm.sh/resource-policy: keep
  {{- end }}
spec:
  deletionPolicy: {{ $deletionPolicy }}
  forProvider:
    name: {{ $db | quote }}
    instanceRef:
      name: {{ $instance }}
---
# Windsor composes a scoped Role and Grants, then writes endpoint, port,
# username, and password to the requested Secret in this namespace.
apiVersion: database.windsorcli.dev/v1alpha1
kind: AppRole
metadata:
  name: {{ $appRole }}
  namespace: {{ $root.Release.Namespace }}
  labels:
    copia.io/helm-release: {{ $root.Release.Name }}
    {{- if .labels }}
    {{- .labels | nindent 4 }}
    {{- else }}
    {{- include "app.labels" $root | nindent 4 }}
    {{- end }}
  {{- if $cs.keepOnDelete }}
  annotations:
    helm.sh/resource-policy: keep
  {{- end }}
spec:
  instanceName: {{ $instance }}
  databaseName: {{ $db | quote }}
  secretName: {{ $appSecret }}
{{- end }}
