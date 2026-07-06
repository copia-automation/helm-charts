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
}

main "$@"
