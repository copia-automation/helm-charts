# AWS RDS via Crossplane (Windsor)

This guide covers provisioning Copia's Postgres on **AWS RDS** using the
Windsor Core provisioning add-on (`database.postgres.driver=rds`). The chart
emits `rds.aws.upbound.io/v1beta3` **Instance** CRs (same posture as
CloudNativePG's `Cluster` CR). It does **not** install Crossplane, the AWS
provider, or Claims/XRD/Composition.

For local/docker, keep using CloudNativePG (`cloudnativePG.enabled`).

## Prerequisites (platform / infrastructure agent)

On the infrastructure application, enable Windsor's RDS driver (names vary by
Distr/Windsor version), e.g.:

```bash
CORE_DATABASE__POSTGRES__ENABLED=true
CORE_DATABASE__POSTGRES__DRIVER=rds
```

That installs Crossplane, `provider-aws-rds`, a `default` `ProviderConfig`
(Pod Identity), DB subnet group, and Kyverno policies. See
[Windsor Core provisioning](https://github.com/windsorcli/core/blob/main/kustomize/provisioning/README.md).

Also wire **app-role** for each Instance the chart creates (Copia, and
conversion-manager when enabled). App-role publishes
`<instance>-app-credentials` (`username` + `password`) into the release
namespace. Required substitutions:

| Key | Example (Copia) | Example (CM) |
|-----|-----------------|--------------|
| `pg_instance_name` | `copia-pg` | `copia-cm-pg` |
| `pg_database_name` | `copia` | `conversion_manager` |
| `pg_target_namespace` | release namespace | same |
| `pg_grant_sql` | grants for `copia_app` | grants for `conversion_manager_app` |

Without app-role, pods block forever waiting on the credentials Secret.

## Customer values

Enable RDS and **omit** `HOST` / `PASSWD` (and CM `DB_HOST` / `DB_PASSWORD`).
Supply region, subnet group, and security groups from platform outputs:

```yaml
database:
  provider: rds   # or: rds.enabled: true
rds:
  region: us-east-2
  dbSubnetGroupName: mycluster-crossplane-rds
  vpcSecurityGroupIds:
    - sg-poc-rds
  instanceClass: db.t4g.small
  allocatedStorage: 100
  # Optional second Instance sizing when conversion-manager is enabled:
  conversionManager:
    instanceClass: db.t4g.micro
    allocatedStorage: 20
conversion_manager_service:
  enabled: true
  configmap:
    DB_NAME: conversion_manager
    # omit DB_HOST / DB_USER — filled at runtime from Secrets
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

Do **not** enable `cloudnativePG` at the same time.

## How the chart behaves

1. Helm applies one `Instance` for Copia (and a second for conversion-manager
   when CM is enabled). Instances are cluster-scoped; no Claim.
2. Crossplane creates RDS with `manageMasterUserPassword: true` (master in
   AWS Secrets Manager — apps do not use it).
3. Windsor **app-role** CronJob creates `<dbname>_app` and writes
   `<instance>-app-credentials` (`username`, `password`).
4. Instance `writeConnectionSecretToRef` publishes host/port into
   `<instance>-connection` (app-credentials does not include endpoint).
5. Deployment init waits until both Secrets exist, then `pg_isready` with the
   **app** user. `render-app-ini` / CM entrypoint fill HOST/USER/PASSWD from
   those Secrets.
6. Admin bootstrap Job uses the same Secrets (60m deadline for RDS).

## Smoke test

```bash
helm upgrade --install copia-poc ./charts/copia -n crossplane-poc --create-namespace \
  --timeout 60m \
  --values charts/copia/distr/values.base.yaml \
  --set database.provider=rds \
  --set rds.region=us-east-2 \
  --set rds.dbSubnetGroupName=YOUR-cluster-crossplane-rds \
  --set-json 'rds.vpcSecurityGroupIds=["sg-..."]' \
  --set rds.instanceClass=db.t4g.micro \
  --set rds.allocatedStorage=20 \
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
kubectl get instance.rds.aws.upbound.io
kubectl get secret -n crossplane-poc | grep -E 'connection|app-credentials'
kubectl logs -n crossplane-poc -l app.kubernetes.io/name=copia -c copia-wait-db
```

## Cleanup

```bash
helm uninstall copia-poc -n crossplane-poc
kubectl delete instance.rds.aws.upbound.io --all
```
