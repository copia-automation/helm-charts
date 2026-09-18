{{/*
Emit DatabaseInstance + User + Database for one Cloud SQL instance.

Expects dict:
  root                  - chart context
  instanceName          - DatabaseInstance CR name (also GCP instance id)
  databaseName          - Postgres database (Database CR forProvider.name)
  adminUsername         - Cloud SQL User name; must match admin secret
  adminSecretName       - <instance>-admin-credentials
  connectionSecretName  - writeConnectionSecretToRef target
  tier                  - Cloud SQL machine tier
  diskSize              - disk size in GB
  labels                - optional label helper output string
*/}}
{{- define "copia.cloudsql.instanceResources" -}}
{{- $root := .root -}}
{{- $instance := .instanceName -}}
{{- $db := .databaseName -}}
{{- $adminUser := .adminUsername -}}
{{- $adminSecret := .adminSecretName -}}
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
{{- $kms := $cs.encryptionKeyName | default "" -}}
{{- $adminNs := "system-provisioning" -}}
{{- if $cs.adminCredentialsNamespace -}}
{{- $adminNs = $cs.adminCredentialsNamespace -}}
{{- end }}
---
# Platform installs Crossplane + provider-gcp-sql; this chart defines the
# instance. Host/port come from writeConnectionSecretToRef. App login uses
# <instance>-app-credentials in the release namespace. The User CR reads
# <instance>-admin-credentials (Cloud SQL User has no auto-generate password).
apiVersion: sql.gcp.upbound.io/v1beta2
kind: DatabaseInstance
metadata:
  name: {{ $instance }}
  labels:
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
        privateNetwork: {{ $network | quote }}
---
apiVersion: sql.gcp.upbound.io/v1beta2
kind: User
metadata:
  name: {{ printf "%s-admin" $instance | trunc 63 | trimSuffix "-" }}
  labels:
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
    name: {{ $adminUser | quote }}
    instanceRef:
      name: {{ $instance }}
    passwordSecretRef:
      name: {{ $adminSecret }}
      namespace: {{ $adminNs }}
      key: password
---
# Postgres database name is forProvider.name; metadata.name stays unique.
apiVersion: sql.gcp.upbound.io/v1beta1
kind: Database
metadata:
  name: {{ printf "%s-db" $instance | trunc 63 | trimSuffix "-" }}
  labels:
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
{{- end }}
