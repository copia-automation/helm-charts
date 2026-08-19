# CloudNativePG Config

This guide covers running Copia's Postgres **in-cluster** with
[CloudNativePG](https://cloudnative-pg.io/). The Copia Helm chart can create a
`Cluster` (and an extra `Database` for conversion-manager). It does **not**
install the CloudNativePG operator.

Use this when you do not already have an external Postgres (RDS, Cloud SQL, or
similar). If you do, leave `cloudnativePG.enabled` false and set `HOST` /
`DB_HOST` as in the default customer values.

## Prerequisites

- CloudNativePG operator **1.22 or newer** already installed in the cluster
  (the `postgresql.cnpg.io/v1` CRDs must be present)
- A StorageClass that can provision ReadWriteOnce volumes for Postgres
- Distr secrets `CopiaDbPassword` and `ConversionManagerDbPassword` (if you use
  conversion-manager)

Confirm the CRDs:

```bash
kubectl get crd clusters.postgresql.cnpg.io databases.postgresql.cnpg.io
```

The chart fails `helm install`/`upgrade` with a clear error if
`cloudnativePG.enabled` is true and `postgresql.cnpg.io/v1` is missing. Preflight
checks also look for `clusters.postgresql.cnpg.io`.

## Customer values

Flip `cloudnativePG.enabled` to `true` and **remove** `copia.config.database.HOST` and
`conversion_manager_service.configmap.DB_HOST`. The chart points both apps at the
Cluster read-write Service (`<clusterName>-rw:5432`). Leaving an external host in
place fails the install. Keep `NAME`, `USER`, and `PASSWD`.

```yaml
cloudnativePG:
  enabled: true
  instances: 1
  storage:
    size: 50Gi
    storageClass: gp3
copia:
  config:
    database:
      NAME: copia
      USER: copia
      PASSWD: "{{ .Secrets.CopiaDbPassword }}"
      SSL_MODE: require
conversion_manager_service:
  configmap:
    DB_NAME: conversion_manager
    DB_USER: conversion_manager
  secret:
    DB_PASSWORD: "{{ .Secrets.ConversionManagerDbPassword }}"
```

`USER` must not be `postgres` or `streaming_replica` (CloudNativePG reserves
those). `copia` is the usual owner name.

### Optional knobs

| Value | Default | Purpose |
|---|---|---|
| `cloudnativePG.clusterName` | `<fullname>-pg` | Cluster object and Service prefix |
| `cloudnativePG.instances` | `1` | Postgres pods. Use `3` for HA |
| `cloudnativePG.imageName` | `ghcr.io/cloudnative-pg/postgresql:16` | Operand image (mirror this if air-gapped) |
| `cloudnativePG.storage.size` | `20Gi` (chart) / `50Gi` (customer example) | Data volume |
| `cloudnativePG.storage.storageClass` | cluster default | Must support RWO |
| `cloudnativePG.keepOnDelete` | `true` | Helm will not delete the Cluster on uninstall |
| `cloudnativePG.extraSpec` | `{}` | Merged into the Cluster spec |

### `extraSpec` examples

HA anti-affinity, Postgres parameters, or backups go in `extraSpec` and are
merged into the Cluster spec:

```yaml
cloudnativePG:
  enabled: true
  instances: 3
  extraSpec:
    postgresql:
      parameters:
        max_connections: "200"
        shared_buffers: "256MB"
```

See the [CloudNativePG Cluster spec](https://cloudnative-pg.io/documentation/current/)
for the full field list.

## What the chart creates

When `cloudnativePG.enabled` is true:

1. A `kubernetes.io/basic-auth` Secret for the Copia owner (`username` /
   `password` from `copia.config.database`)
2. A CloudNativePG `Cluster` bootstrapped with that owner and database
3. If conversion-manager is enabled: a second auth Secret, a managed role, and a
   `Database` CR for `conversion_manager`

The read-write Service is `<clusterName>-rw` on port 5432. Copia waits for
Postgres with an init container before the app starts.

## Conversion-manager

The default chart `DB_USER` is `postgres`, which CloudNativePG does not allow as
a managed role. The chart remaps that to `conversion_manager`. Set `DB_USER` to
`conversion_manager` (as in the customer example) to make the values match what
is created.

Requires CloudNativePG 1.22+ for the `Database` CRD.

## Uninstall and disable

`keepOnDelete` defaults to true, so `helm uninstall` or setting `enabled: false`
does not delete the Cluster or its PVCs. To tear the database down, delete the
Cluster yourself after you have backups:

```bash
kubectl -n copia delete cluster.postgresql.cnpg.io <clusterName>
```

## Troubleshooting

- **Helm: CRDs were not found** — install the operator, then retry deploy
- **Copia crash-loop / init container waiting** — `kubectl -n copia get cluster`
  and describe the Cluster; storage and image pull are the usual causes
- **conversion-manager cannot log in** — confirm `DB_USER` is not `postgres`, and
  that `ConversionManagerDbPassword` matches the Secret the chart created
