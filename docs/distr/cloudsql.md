# GCP Cloud SQL via Crossplane

This guide covers provisioning Copia's Postgres on **GCP Cloud SQL**. The chart
emits a `sql.gcp.upbound.io` **DatabaseInstance** and **Database**, plus a
`database.windsorcli.dev` **AppRole**. It does **not** install Crossplane,
the GCP provider, or the Windsor database components.

If you already created Cloud SQL (Terraform, console, another chart), do not
follow this guide. Leave `cloudsql.enabled` false and set
`copia.config.database.HOST` like any other existing Postgres.

For local/docker, keep using CloudNativePG (`cloudnativePG.enabled`).

## Prerequisites

Enable Windsor cloud Postgres with the Cloud SQL driver first. It installs
Crossplane, `provider-gcp-sql`, the `AppRole` API, admission policies, and the
database credential controllers. Windsor creates the Cloud SQL admin user.
The chart's `AppRole` creates a scoped application user and writes
`<instance>-app-credentials` in the release namespace.

## Customer values

Enable Cloud SQL and **omit** `HOST` / `PASSWD` (and CM `DB_HOST` / `DB_PASSWORD`).
Supply the region and instance sizing. Windsor injects the context project and
private network:

```yaml
cloudsql:
  enabled: true
  region: us-central1
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
    # omit DB_HOST / DB_USER. Filled at runtime from Secrets.
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

## Encryption at rest

The chart never sets an encryption key. Configure it in the Windsor context.
Admission injects the resulting `encryptionKeyName` onto every
`DatabaseInstance` the chart creates, so Copia and conversion-manager share
one key.

Set `managed: true` to have Windsor create a key. Set `key_id` to use a
CryptoKey created outside Windsor; it overrides `managed`.

```yaml
database:
  postgres:
    cloud:
      encryption:
        managed: true
        # key_id: projects/my-project/locations/us-central1/keyRings/my-ring/cryptoKeys/my-key
```

See [Windsor Cloud SQL encryption](https://github.com/windsorcli/core/blob/main/docs/guides/database/cloudsql.md).

## How the chart behaves

1. Helm applies one `DatabaseInstance`, `Database`, and namespaced `AppRole`
   for Copia, plus a second set when conversion-manager is enabled.
2. Windsor creates the admin user. Each `AppRole` creates a scoped login and
   `<instance>-app-credentials` in the release namespace.
3. `writeConnectionSecretToRef` publishes host/port into
   `<instance>-connection` in the release namespace.
4. Deployment init waits until that Secret and `<instance>-app-credentials`
   exist, then `pg_isready` with the app user. `render-app-ini` / CM entrypoint
   fill HOST/USER/PASSWD from those Secrets.
5. Admin bootstrap Job uses the same Secrets (60m deadline for Cloud SQL).

## Smoke test

```bash
helm upgrade --install copia-poc ./charts/copia -n crossplane-poc --create-namespace \
  --timeout 60m \
  --values charts/copia/distr/values.base.yaml \
  --set cloudsql.enabled=true \
  --set cloudsql.region=us-central1 \
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
kubectl get secret -n crossplane-poc | grep -E 'connection|app-credentials'
kubectl logs -n crossplane-poc -l app.kubernetes.io/name=copia -c copia-wait-db
```

## Cleanup

```bash
helm uninstall copia-poc -n crossplane-poc
kubectl delete databaseinstance.sql.gcp.upbound.io \
  -l copia.io/helm-release=copia-poc
```
