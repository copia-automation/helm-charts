# Crossplane Config

This guide covers provisioning Copia's Postgres on **AWS RDS via Crossplane**.
The chart emits a `PostgresInstance` Claim (pre-install hook) and reads
credentials at **runtime** from a connection Secret. It does **not** install
Crossplane or the AWS provider.

Use this for the AWS / Distr path once Crossplane is a platform capability.
For local/docker, keep using CloudNativePG (`cloudnativePG.enabled`).

## Prerequisites (platform)

1. Crossplane core installed and healthy
2. Upbound AWS RDS provider + `ProviderConfig` (IRSA / Pod Identity)
3. XRD + Composition for `PostgresInstance` (`aws.copia.io/v1alpha1`) that:
   - Creates subnet group + RDS instance
   - Writes a connection Secret with **nexus keys**: `user`, `password`, `host`,
     `port`, `dbname` (remap from Crossplane's `username` / `endpoint` / …)
4. Network inputs available to the Claim (until Composition does tag lookup):
   - database/isolated subnet IDs
   - security group allowing **5432** from EKS workers

Example XRD/Composition for a staging spike live under
`charts/copia/examples/crossplane/` (Crossplane **v2 pipeline** Composition +
`function-patch-and-transform`).

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

```yaml
database:
  provider: crossplane   # or: crossplane.enabled: true
crossplane:
  connectionSecretName: copia-db-app
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
adminUser:
  create: true
  username: admin
  email: admin@example.com
  password: "test-admin-password"
copia:
  config:
    database:
      NAME: copia
      USER: copia
      SSL_MODE: require
      # omit HOST and PASSWD
```

Do **not** enable `cloudnativePG` at the same time.

## How the chart behaves

1. Helm applies a `PostgresInstance` Claim with the release (not a pre-install
   hook — Helm must not wait on RDS Ready, which takes 5–15 minutes).
2. Crossplane reconciles the Claim → AWS RDS → Secret `copia-db-app`.
3. Deployment **init** mounts the Secret and runs `pg_isready` / `psql`
   (kubelet blocks start until the Secret exists).
4. `render-app-ini` substitutes `HOST` / `USER` / `PASSWD` from the Secret
   (placeholders `###XP_DB_*###`).
5. Post-install **admin bootstrap** Job also reads the Secret (not Helm values).

## Step 10 smoke (second namespace)

Disable conversion-manager for the spike (avoids its secrets-init Job). Use a
real image and skip the GHCR preflight Job.

```bash
# After XRD+Composition are installed and you have subnet/SG IDs:
helm install copia-poc ./charts/copia -n crossplane-poc --create-namespace \
  --timeout 20m \
  --values charts/copia/distr/values.base.yaml \
  --set image.repository=ghcr.io/copia-automation/copia-web-app-selfhosted-releases \
  --set image.tag=v0.57.0 \
  --set ghcrCheck=false \
  --set conversion_manager_service.enabled=false \
  --set database.provider=crossplane \
  --set chartGeneratedSecrets.enabled=true \
  --set adminUser.create=true \
  --set adminUser.username=admin \
  --set adminUser.email=admin@example.com \
  --set adminUser.password='test-admin-password' \
  --set copia.config.database.HOST= \
  --set crossplane.parameters.region=us-east-2 \
  --set-json 'crossplane.parameters.subnetIds=["subnet-aaa","subnet-bbb","subnet-ccc"]' \
  --set-json 'crossplane.parameters.vpcSecurityGroupIds=["sg-poc"]'
```

Verify:

```bash
kubectl get postgresinstance -n crossplane-poc
kubectl get secret copia-db-app -n crossplane-poc -o json | jq -r '.data | keys[]'
kubectl logs -n crossplane-poc -l app.kubernetes.io/name=copia -c copia-wait-db
kubectl logs -n crossplane-poc job/copia-poc-copia-admin-bootstrap
```

Port-forward and log in with `admin` / your test admin password once the
Deployment is Ready.

## Cleanup

```bash
helm uninstall copia-poc -n crossplane-poc
# wait for Claim/RDS finalizers; confirm instance gone in AWS
kubectl delete postgresinstance -n crossplane-poc --all
```
