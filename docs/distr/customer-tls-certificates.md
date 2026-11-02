# TLS certificates

HTTPS is required for Copia and for conversion manager. Choose one of these, based on where Copia runs.

| Where Copia runs | How HTTPS is terminated |
| --- | --- |
| AWS | AWS Certificate Manager (ACM) on the load balancer. Leave `tls` and the certificate secrets unset. |
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

Open the deployment, then **Helm values**, and add the `tls` block. Quote both values the same way as the other
secrets. Deploy after both secrets exist.

```yaml
tls:
  termination: pod
  copia:
    certificate: "{{ .Secrets.CopiaTlsCertificate }}"
    privateKey: "{{ .Secrets.CopiaTlsPrivateKey }}"
copia:
  config:
    server:
      ROOT_URL: https://copia.example.com/
```

The chart stores the pair in a `kubernetes.io/tls` Secret named `<release>-copia-tls`. Conversion manager uses
the same certificate unless you give it its own.

## Where TLS terminates

TLS terminates in one place. The chart stops the deploy if it is set up in two.

`termination: pod` is the default. Copia and conversion manager serve HTTPS themselves from the Secret. The chart
sets `PROTOCOL`, `CERT_FILE` and `KEY_FILE` in `app.ini`, sets `ENABLE_HTTPS`, `CERT_FILE` and `KEY_FILE` for
conversion manager, and switches the health probes to HTTPS. Reach the pods through their Services, for example
with `service.http.type: LoadBalancer`. Leave `ingress.tls` and `conversion_manager_service.ingress.tls` empty.

`termination: ingress` puts the Secret on both chart Ingresses, for every host in their `hosts` lists, and the pods
serve HTTP. Both Ingresses must be enabled, and their `tls` lists must be empty because the chart fills them.

```yaml
tls:
  termination: ingress
  copia:
    certificate: "{{ .Secrets.CopiaTlsCertificate }}"
    privateKey: "{{ .Secrets.CopiaTlsPrivateKey }}"
ingress:
  enabled: true
  hosts:
    - host: copia.example.com
      paths:
        - path: /
          pathType: Prefix
conversion_manager_service:
  ingress:
    enabled: true
    hosts:
      - host: conversion.example.com
        paths:
          - path: /
            pathType: Prefix
```

## A separate conversion manager certificate

Create `ConversionManagerTlsCertificate` and `ConversionManagerTlsPrivateKey` the same way, then add:

```yaml
tls:
  conversionManager:
    certificate: "{{ .Secrets.ConversionManagerTlsCertificate }}"
    privateKey: "{{ .Secrets.ConversionManagerTlsPrivateKey }}"
```

## A Secret you manage yourself

To keep creating the Secret with kubectl, set only its name and leave `certificate` and `privateKey` unset:

```yaml
tls:
  copia:
    secretName: copia-tls
```

If the chart is asked to create a Secret whose name already exists outside the release, the deploy stops and
names the Secret. Delete it, or keep it and remove `certificate` and `privateKey`.

## Replacing a certificate

Edit the secret values and deploy again. With pod termination, the pods restart and load the new certificate.
For a Secret you manage yourself, update it first, then deploy.
