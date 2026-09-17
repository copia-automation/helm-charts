# GCP Cloud SQL via Crossplane

This guide covers provisioning Copia's Postgres on **GCP Cloud SQL**. The chart
emits `sql.gcp.upbound.io` **DatabaseInstance**, **Database**, and **User** CRs.
It does **not** install Crossplane or the GCP provider.

If you already created Cloud SQL (Terraform, console, another chart), do not
follow this guide. Leave `cloudsql.enabled` false and set
`copia.config.database.HOST` like any other existing Postgres.

For local/docker, keep using CloudNativePG (`cloudnativePG.enabled`).

## Prerequisites

Crossplane and `provider-gcp-sql` must already be installed, with a usable
`ProviderConfig`. The User CR reads `<instance>-admin-credentials` from
`system-provisioning` (username + password). App login uses
`<instance>-app-credentials` in the release namespace; the chart does not
create that Secret.

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
   cluster-scoped.
2. The User CR reads `<instance>-admin-credentials` from
   `system-provisioning`. Apps do not use the admin user.
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
kubectl get secret -n crossplane-poc | grep -E 'connection|app-credentials'
kubectl logs -n crossplane-poc -l app.kubernetes.io/name=copia -c copia-wait-db
```

## Cleanup

```bash
helm uninstall copia-poc -n crossplane-poc
kubectl delete databaseinstance.sql.gcp.upbound.io --all
```
