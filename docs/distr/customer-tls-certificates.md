# TLS certificates

Paste-ready text for the Copia Deployment Portal docs.

Page to add: [TLS certificates](https://docs.copia.io/copia-deployment-portal/application/tls-certificates)

Put it under Application, next to Kubernetes Controller and Artifact Only Distribution. Link it from the
Kubernetes Controller installation page and from Built-In TLS.

---

## Page body

# TLS certificates

HTTPS is required for Copia and for conversion manager. Choose one of these, based on where Copia runs.

| Where Copia runs | How HTTPS is terminated |
| --- | --- |
| AWS | AWS Certificate Manager (ACM) on the load balancer. Remove the `tls` blocks and leave the secrets unset. |
| vSphere, Hyper-V, or other non-cloud | Your own certificate files, stored as portal secrets. Follow the steps below. |

## Your own certificate files (non-cloud)

Use this when there is no managed certificate service. The certificate can be a wildcard, or list both hostnames.

Encode each file as one line of base64. Paste that line into **Secret Value**.

```bash
base64 < copia.crt | tr -d '\n'
base64 < copia.key | tr -d '\n'
```

| Secret | Value |
| --- | --- |
| `CopiaTlsCertificate` | One line of base64 from the certificate file |
| `CopiaTlsPrivateKey` | One line of base64 from the private key file |

Open the deployment, then **Helm values**. Put the secret references on the Copia Ingress. Point the conversion
manager Ingress at the same `secretName`.

```yaml
ingress:
  enabled: true
  hosts:
    - host: copia.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: copia-tls
      hosts:
        - copia.example.com
      certificate: "{{ .Secrets.CopiaTlsCertificate }}"
      privateKey: "{{ .Secrets.CopiaTlsPrivateKey }}"
conversion_manager_service:
  ingress:
    enabled: true
    hosts:
      - host: conversion.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: copia-tls
        hosts:
          - conversion.example.com
```

Quote `certificate` and `privateKey` the same way as the other secrets. Each `hosts` entry is that service's
hostname. The certificate file must cover both. Deploy after both secrets exist.

If conversion manager needs its own certificate, create `ConversionManagerTlsCertificate` and
`ConversionManagerTlsPrivateKey` the same way, and set that Ingress to `secretName: conversion-manager-tls` with
`certificate` and `privateKey` from those two secrets.

To replace a certificate, edit its secret values and deploy again.

---

## Edits to existing pages

### Kubernetes Controller installation

Page: https://docs.copia.io/copia-deployment-portal/application/kubernetes-controller/installation

In **Set up Copia Application Credentials**, add these rows to the secrets table. They are required only for
non-cloud deployments that bring their own certificate files.

| Secret | Use |
| --- | --- |
| `CopiaTlsCertificate` | Base64 of the certificate file for the Copia Ingress, non-cloud only. |
| `CopiaTlsPrivateKey` | Base64 of the private key file for `CopiaTlsCertificate`, non-cloud only. |
| `ConversionManagerTlsCertificate` | Base64 of the conversion-manager certificate file, when it has its own. |
| `ConversionManagerTlsPrivateKey` | Base64 of the private key file for `ConversionManagerTlsCertificate`. |

Add this subsection after the Helm values step:

#### TLS certificate

HTTPS is required. On AWS, terminate HTTPS at the load balancer with ACM. On vSphere, Hyper-V, or other
non-cloud platforms, paste your own certificate files into portal secrets. See
[TLS certificates](https://docs.copia.io/copia-deployment-portal/application/tls-certificates).

### Built-In TLS

Page: https://docs.copia.io/copia-deployment-portal/application/artifact-only-distribution/built-in-tls

Add this paragraph above **Using the built-in server**:

To terminate TLS on the Copia and conversion manager Ingresses with your own certificate files on a non-cloud
platform, follow [TLS certificates](https://docs.copia.io/copia-deployment-portal/application/tls-certificates).

### Helm Values

Page: https://docs.copia.io/copia-deployment-portal/application/artifact-only-distribution/helm-values

Portal deployments that use the Kubernetes Controller should follow
[TLS certificates](https://docs.copia.io/copia-deployment-portal/application/tls-certificates).
