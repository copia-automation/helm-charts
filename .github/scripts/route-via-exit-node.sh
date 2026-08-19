#!/usr/bin/env bash
# Resolve the live MagicDNS name of a staging-platform exit node and route through it.
# EXIT_NODE may be the family prefix (staging-platform) or a numbered host
# (staging-platform-1). The tailnet host can be unsuffixed or staging-platform-N.
set -euo pipefail

if [ -z "${EXIT_NODE:-}" ]; then
  echo "::error::EXIT_NODE is not set" >&2
  exit 1
fi

prefix="${EXIT_NODE}"
if [[ "${prefix}" =~ ^(.+)-[0-9]+$ ]]; then
  prefix="${BASH_REMATCH[1]}"
fi
escaped=$(printf '%s' "${prefix}" | sed 's/[][().^$*+?{|]/\\&/g')
pattern="^${escaped}(-[0-9]+)?$"

node=""
for _ in $(seq 1 30); do
  node=$(tailscale status --json | jq -r --arg re "${pattern}" '
    [.Peer[]?
     | select(.Online == true and .ExitNodeOption == true)
     | .HostName
     | select(test($re))]
    | sort
    | .[0] // empty
  ')
  if [ -n "${node}" ]; then
    break
  fi
  sleep 1
done

if [ -z "${node}" ]; then
  echo "::error::no online exit node matching ${prefix} or ${prefix}-N" >&2
  tailscale status
  exit 1
fi

echo "Using exit node ${node} (hint was ${EXIT_NODE})"
sudo tailscale set --exit-node="${node}" --exit-node-allow-lan-access
