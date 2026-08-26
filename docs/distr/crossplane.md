# Crossplane Config

This guide covers provisioning Copia's Postgres on **AWS RDS via Crossplane**.
The chart emits a `PostgresInstance` Claim as a normal release resource and reads
credentials at **runtime** from a connection Secret. It does **not** install
Crossplane or the AWS provider.

Use this for the AWS / Distr path once Crossplane is a platform capability.
For local/docker, keep using CloudNativePG (`cloudnativePG.enabled`).

## Prerequisites (platform)

1. Crossplane core installed and healthy
2. Upbound AWS RDS provider + `ProviderConfig` (IRSA / Pod Identity)
3. XRD + Composition for `PostgresInstance` (`aws.copia.io/v1alpha1`) that:
   - Creates subnet group + RDS instance
   - Sets Composition `spec.writeConnectionSecretsToNamespace` (e.g.
     `crossplane-system`) so the composite gets a staging connection Secret.
     **Without this field the Claim can still report Ready=True but no Secret
     is ever published** — a silent failure that hangs chart init.
   - Remaps connection details to **nexus keys**: `user`, `password`, `host`,
     `port`, `dbname` (from Crossplane's `username` / `endpoint` / …)
   - The chart Claim then sets `spec.writeConnectionSecretToRef.name` so
     Crossplane **copies** that Secret into the Claim / Helm release namespace
     (where the Deployment mounts it). Two fields, two namespaces — both required.
4. A `ProviderConfig` named **`default`**, or set `crossplane.providerConfigRef`
   to match your platform install.
5. Network inputs available to the Claim (until Composition does tag lookup):
   - database/isolated subnet IDs
   - security group allowing **5432** from EKS workers
   - AWS `region` (required; no chart default)

Example XRD/Composition for a staging spike live under
`charts/copia/examples/crossplane/` (Crossplane **v2 pipeline** Composition +
`function-patch-and-transform`). Validated with Crossplane **2.4.0** (claim-style
XRD `scope: LegacyCluster`).

```bash
kubectl apply -k charts/copia/examples/crossplane
kubectl wait function.pkg.crossplane.io/function-patch-and-transform \
  --for=condition=Healthy --timeout=2m
kubectl get crd postgresinstances.aws.copia.io
kubectl get composition xpostgresinstances.aws.copia.io
```

## Customer / smoke values

Enable Crossplane and **omit** `HOST` and `PASSWD`. Supply Claim network
parameters (staging spike) and an admin password for the post-install Job.
The connection Secret defaults to `<release-name>-db-app`; override with
`connectionSecretName: copia-db-app` if you need the fixed nexus name.

```yaml
database:
  provider: crossplane   # or: crossplane.enabled: true
crossplane:
  # connectionSecretName: copia-db-app  # optional nexus-style override
  # providerConfigRef: default          # must match platform ProviderConfig name
  parameters:
    region: us-east-2
    subnetIds:
      - subnet-aaa
      - subnet-bbb
      - subnet-ccc
    vpcSecurityGroupIds:
      - sg-poc-rds
chartGeneratedSecrets:
  enabled: true
conversion_manager_service:
  enabled: true
  configmap:
    DB_NAME: conversion_manager
    DB_USER: conversion_manager
    # omit DB_HOST — chart reads RDS endpoint from the connection Secret
  secret:
    DB_PASSWORD: "{{ .Secrets.ConversionManagerDbPassword }}"
adminUser:
  create: true
  username: admin
  email: admin@example.com
  password: "test-admin-password"
copia:
  config:
    database:
      # NAME/USER are overridden at runtime from the connection Secret when present
      SSL_MODE: require
      # omit HOST and PASSWD
```

Do **not** enable `cloudnativePG` at the same time.

## How the chart behaves

1. Helm applies a `PostgresInstance` Claim with the release (not a pre-install
   hook — Helm must not wait on RDS Ready, which takes 5–15 minutes).
2. Crossplane reconciles the Claim → AWS RDS → connection Secret
   (`<release>-db-app` by default).
3. Deployment **init** mounts the Secret and runs `pg_isready` / `psql`
   (kubelet blocks start until the Secret exists).
4. `render-app-ini` substitutes `HOST` / `USER` / `PASSWD` / `NAME` from the
   Secret (placeholders `###XP_DB_*###`).
5. Post-install **admin bootstrap** Job also reads the Secret (not Helm values).
   On the Crossplane path the Job deadline is 60m to cover RDS provisioning.

### Conversion-manager (same RDS, second database)

When `conversion_manager_service.enabled` is true on the Crossplane path, the
chart mirrors CloudNativePG:

1. **One RDS** from the `PostgresInstance` Claim (Copia owner/database).
2. Conversion-manager Deployment **init** connects with master credentials from
   the connection Secret and creates the `conversion_manager` role + database
   (idempotent).
3. A second init waits until conversion-manager can log in.
4. `DB_HOST` is taken from the RDS connection Secret at runtime (`host:port`);
   omit `conversion_manager_service.configmap.DB_HOST`. Set `DB_USER`,
   `DB_NAME`, and `secret.DB_PASSWORD` as with CloudNativePG.

Requires Distr secret **`ConversionManagerDbPassword`** when using
`chartGeneratedSecrets.enabled=true`.

## Step 10 smoke (second namespace)

Use a real image and skip the GHCR preflight Job. For throwaway POC teardown,
opt out of safe RDS deletion defaults. Conversion-manager can stay disabled for
a Copia-only spike, or enable it to validate the second-database bootstrap:

```bash
# After XRD+Composition are installed and you have subnet/SG IDs:
helm install copia-poc ./charts/copia -n crossplane-poc --create-namespace \
  --timeout 60m \
  --values charts/copia/distr/values.base.yaml \
  --set image.repository=ghcr.io/copia-automation/copia-web-app-selfhosted-releases \
  --set image.tag=v0.57.0 \
  --set ghcrCheck=false \
  --set database.provider=crossplane \
  --set conversion_manager_service.enabled=true \
  --set conversion_manager_service.configmap.DB_HOST= \
  --set conversion_manager_service.secret.DB_PASSWORD='cm-test-password' \
  --set chartGeneratedSecrets.enabled=true \
  --set adminUser.create=true \
  --set adminUser.username=admin \
  --set adminUser.email=admin@example.com \
  --set adminUser.password='test-admin-password' \
  --set copia.config.database.HOST= \
  --set crossplane.parameters.region=us-east-2 \
  --set crossplane.parameters.skipFinalSnapshot=true \
  --set crossplane.parameters.deletionProtection=false \
  --set-json 'crossplane.parameters.subnetIds=["subnet-aaa","subnet-bbb","subnet-ccc"]' \
  --set-json 'crossplane.parameters.vpcSecurityGroupIds=["sg-poc"]'
```

Verify:

```bash
kubectl get postgresinstance -n crossplane-poc
kubectl get secret copia-poc-db-app -n crossplane-poc -o json | jq -r '.data | keys[]'
kubectl logs -n crossplane-poc -l app.kubernetes.io/name=copia -c copia-wait-db
kubectl logs -n crossplane-poc job/copia-poc-admin-bootstrap
```

Port-forward and log in with `admin` / your test admin password once the
Deployment is Ready.

## Cleanup

```bash
helm uninstall copia-poc -n crossplane-poc
# wait for Claim/RDS finalizers; confirm instance gone in AWS
kubectl delete postgresinstance -n crossplane-poc --all
```
