# Install Guide — Copia (Kubernetes Agent)

This guide covers deploying Copia via the Distr Kubernetes agent. For the full self-hosted
documentation set, see [Copia Self-Hosted Docs](https://docs.copia.io/self-hosted-docs).

## Prerequisites

- A Kubernetes cluster with `kubectl` configured (often provisioned by the infrastructure agent)
- Network access from the cluster to your Distr host
- A Distr **Kubernetes deployment target** created for namespace `copia`
- Application entitlement granted for the Copia application

## Before you deploy

Configure these in the Distr customer portal:

| Item | Where |
|---|---|
| **Application entitlement** | Licenses → your org → Application Entitlements |
| **`CopiaDbPassword`** | Secrets (customer-scoped, not vendor-level) |
| **`CopiaAdminPassword`** | Secrets |
| **`ConversionManagerDbPassword`** | Secrets (if using conversion manager) |
| **Environment variables** | Deployments → your target → Environment tab |

Required environment fields include hostname, database connection settings, and admin user
details. See the environment template on your deployment for the full list. Empty required
fields keep **Deploy** disabled.

### Database

Copia needs PostgreSQL. Supported layouts:

- **External Postgres** (default customer values) — set `copia.config.database.HOST`
  and conversion-manager `DB_HOST` to your server.
- **In-cluster CloudNativePG** — on the **infrastructure** application, set
  `CORE_DATABASE__POSTGRES__ENABLED=true` and
  `CORE_DATABASE__POSTGRES__DRIVER=cloudnativepg` (Windsor Core `v0.7.0`). Wait
  until `kubectl get crd clusters.postgresql.cnpg.io` succeeds, then set
  `cloudnativePG.enabled: true` and remove `HOST` / `DB_HOST`. The chart creates
  a `Cluster` CR and points the apps at it. See
  [CloudNativePG Config](./cloudnativepg.md).
- **AWS RDS via Crossplane** (Distr AWS / Windsor `driver=rds`) — platform
  installs Crossplane + provider; chart emits `Instance` CRs and opts into
  app-role CronJobs that publish `<instance>-app-credentials`, plus connection
  Secrets for host. Omit `HOST` / `PASSWD` (and CM `DB_HOST`). See
  [Crossplane Config](./crossplane.md).

Do not use `CORE_ADDONS__DATABASE__*` with Core `v0.7.0`.

## Install the Kubernetes agent

Copy the connect command from your deployment page in Distr and run it against your cluster.
Distr generates a one-time command that includes credentials — paste it from the portal:

```bash
kubectl apply -n copia -f "https://<your-distr-host>/api/v1/connect?..."
```

This installs the Distr agent with RBAC scoped to the `copia` namespace. The agent registers
with Distr, pulls the Copia Helm chart and container images using injected registry
credentials, and runs `helm install`.

## Deploy Copia

1. Assign a published **ApplicationVersion** to your deployment target
2. Click **Deploy**
3. Monitor deployment status in the Distr portal

The agent merges three layers of Helm values:

1. Chart defaults (`charts/copia/values.yaml`)
2. Copia base values (attached to every ApplicationVersion)
3. Your target-specific values and secrets

## Upgrades

Publishing a new ApplicationVersion does not change running deployments automatically. To
upgrade, assign your target to the new version in the Distr portal. The agent runs
`helm upgrade`. Reverting the assignment rolls back.

## Troubleshooting

- **Deploy button disabled** — check entitlements, secrets, and required environment fields
- **Image pull errors** — confirm the agent is healthy; Distr injects pull credentials for
  artifacts hosted in the Distr registry
- **Helm install failures** — review agent logs in the deployment status view

For additional help, see [Copia Self-Hosted Docs](https://docs.copia.io/self-hosted-docs).
