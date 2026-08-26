#!/usr/bin/env bash

set -eo pipefail

source script/util.sh

# Render the chart with the Distr base overlay and a representative per-target
# overlay, failing on any render error so malformed values cannot produce an
# ApplicationVersion.
main() {
  log::exec_command helm template copia charts/copia \
    --values charts/copia/distr/values.base.yaml \
    --values charts/copia/distr/values.customer.example.yaml \
    >/dev/null
  log::success "Distr base + per-target overlay renders cleanly"

  log::exec_command helm template copia charts/copia \
    --api-versions postgresql.cnpg.io/v1 \
    --values charts/copia/distr/values.base.yaml \
    --values charts/copia/distr/values.customer.example.yaml \
    --set cloudnativePG.enabled=true \
    --set copia.config.database.HOST= \
    --set conversion_manager_service.configmap.DB_HOST= \
    >/dev/null
  log::success "Distr overlay with cloudnativePG.enabled renders cleanly"

  log::exec_command helm template copia charts/copia \
    --api-versions aws.copia.io/v1alpha1 \
    --values charts/copia/distr/values.base.yaml \
    --set database.provider=crossplane \
    --set chartGeneratedSecrets.enabled=true \
    --set copia.config.database.HOST= \
    --set crossplane.parameters.region=us-east-2 \
    --set-json 'crossplane.parameters.subnetIds=["subnet-a","subnet-b"]' \
    --set-json 'crossplane.parameters.vpcSecurityGroupIds=["sg-a"]' \
    >/dev/null
  log::success "Chart with database.provider=crossplane renders cleanly"

  log::exec_command helm template copia charts/copia \
    --api-versions aws.copia.io/v1alpha1 \
    --values charts/copia/distr/values.base.yaml \
    --set database.provider=crossplane \
    --set chartGeneratedSecrets.enabled=true \
    --set conversion_manager_service.enabled=true \
    --set conversion_manager_service.configmap.DB_HOST= \
    --set conversion_manager_service.secret.DB_PASSWORD=cm-secret \
    --set copia.config.database.HOST= \
    --set crossplane.parameters.region=us-east-2 \
    --set-json 'crossplane.parameters.subnetIds=["subnet-a","subnet-b"]' \
    --set-json 'crossplane.parameters.vpcSecurityGroupIds=["sg-a"]' \
    >/dev/null
  log::success "Chart with crossplane + conversion-manager renders cleanly"
}

main "$@"
