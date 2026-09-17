# GCP Cloud SQL via Crossplane (Windsor)

This guide covers provisioning Copia's Postgres on **GCP Cloud SQL** using the
Windsor Core provisioning add-on (`database.postgres.driver=cloudsql`). The chart
emits `sql.gcp.upbound.io` **DatabaseInstance**, **Database**, and **User** CRs
(same posture as AWS RDS Instance CRs) and **opts into app-role** so credentials
are published on helm install. It does **not** install Crossplane or the GCP
provider.

If you already created Cloud SQL (Terraform, console, another chart), do not
follow this guide. Leave `cloudsql.enabled` false and set
`copia.config.database.HOST` like any other existing Postgres.

For local/docker, keep using CloudNativePG (`cloudnativePG.enabled`).

## Prerequisites (platform / infrastructure agent)

On the infrastructure application, enable Windsor's Cloud SQL driver:

```bash
CORE_DATABASE__POSTGRES__ENABLED=true
CORE_DATABASE__POSTGRES__DRIVER=cloudsql
```

That installs Crossplane, `provider-gcp-sql`, a `default` `ProviderConfig`
(Workload Identity), private service connection, Kyverno policies, and the
shared `cloudsql-bootstrap` ServiceAccount in `system-provisioning`. See
[Windsor Core provisioning](https://github.com/windsorcli/core/blob/main/kustomize/provisioning/README.md).

Terraform `database/gcp-cloudsql` must also create admin credential Secrets
keyed by the DatabaseInstance names this chart will use (default
`<release-fullname>-pg`, plus `<release-fullname>-cm-pg` when conversion-manager
is enabled):

```hcl
admin_credentials = {
  "copia-pg"    = { username = "copia" }
  "copia-cm-pg" = { username = "conversion_manager" }
}
```

Each key writes `<key>-admin-credentials` in `system-provisioning`. Cloud SQL's
User CR cannot auto-generate a password the way RDS `manageMasterUserPassword`
does, so the chart User CR reads that Secret.

## Customer values

Enable Cloud SQL and **omit** `HOST` / `PASSWD` (and CM `DB_HOST` / `DB_PASSWORD`).
Supply region and private network from platform outputs:

```yaml
cloudsql:
  enabled: true
  region: us-central1
  privateNetwork: projects/my-project/global/networks/my-vpc
  encryptionKeyName: projects/my-project/locations/us-central1/keyRings/cloudsql/cryptoKeys/cloudsql
  tier: db-custom-2-7680
  diskSize: 100
  # Optional second DatabaseInstance sizing when conversion-manager is enabled:
  conversionManager:
    tier: db-f1-micro
    diskSize: 20
conversion_manager_service:
  enabled: true
  configmap:
    DB_NAME: conversion_manager
    # omit DB_HOST / DB_USER. Filled at runtime from Secrets
adminUser:
  create: true
  username: admin
  email: admin@example.com
  password: "test-admin-password"
copia:
  config:
    database:
      SSL_MODE: require
      # omit HOST and PASSWD
```

Do **not** enable `cloudnativePG` or `rds` at the same time.

## How the chart behaves

1. Helm applies one `DatabaseInstance` + `User` + `Database` for Copia (and a
   second set for conversion-manager when CM is enabled). Resources are
   cluster-scoped; no Claim. Kyverno force-sets `project`.
2. The User CR reads `<instance>-admin-credentials` from `system-provisioning`
   (Terraform-generated). Apps do not use the admin user.
3. Chart-owned **app-role** CronJob(s) in `system-provisioning` (same mechanics
   as Windsor `crossplane/gcp-cloudsql/app-role`) create `<dbname>_app` and write
   `<instance>-app-credentials` (`username`, `password`) plus
   `<instance>-connection` (`host` from `privateIpAddress`) into the release
   namespace. Uses platform SA `cloudsql-bootstrap`.
4. Deployment init waits until both Secrets exist, then `pg_isready` with the
   **app** user. `render-app-ini` / CM entrypoint fill HOST/USER/PASSWD from
   those Secrets.
5. Admin bootstrap Job uses the same Secrets (60m deadline for Cloud SQL).

Set `cloudsql.appRole.enabled=false` only if you wire Windsor's app-role
component yourself (duplicate CronJobs would race).

## Smoke test

```bash
helm upgrade --install copia-poc ./charts/copia -n crossplane-poc --create-namespace \
  --timeout 60m \
  --values charts/copia/distr/values.base.yaml \
  --set cloudsql.enabled=true \
  --set cloudsql.region=us-central1 \
  --set cloudsql.privateNetwork=projects/PROJECT/global/networks/NETWORK \
  --set cloudsql.tier=db-f1-micro \
  --set cloudsql.diskSize=20 \
  --set conversion_manager_service.enabled=true \
  --set conversion_manager_service.configmap.DB_HOST= \
  --set chartGeneratedSecrets.enabled=true \
  --set adminUser.create=true \
  --set adminUser.password='test-admin-password' \
  --set copia.config.database.HOST= \
  --set ghcrCheck=false
```

Verify:

```bash
kubectl get databaseinstance.sql.gcp.upbound.io
kubectl get cronjob -n system-provisioning | grep provision-app-role
kubectl get secret -n crossplane-poc | grep -E 'connection|app-credentials'
kubectl logs -n crossplane-poc -l app.kubernetes.io/name=copia -c copia-wait-db
```

## Cleanup

```bash
helm uninstall copia-poc -n crossplane-poc
kubectl delete databaseinstance.sql.gcp.upbound.io --all
```
