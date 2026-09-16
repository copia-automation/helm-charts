#!/usr/bin/env bash
# Route CI egress through an online Tailscale exit node matching EXIT_NODE.
# EXIT_NODE is a prefix: staging-platform matches staging-platform or staging-platform-N.
set -euo pipefail

if [ -z "${EXIT_NODE:-}" ]; then
  echo "::error::EXIT_NODE is not set" >&2
  exit 1
fi

prefix="${EXIT_NODE}"
prefix="${prefix%.}"
prefix="${prefix%%.*}"
if [[ "${prefix}" =~ ^(.+)-[0-9]+$ ]]; then
  prefix="${BASH_REMATCH[1]}"
fi
escaped=$(printf '%s' "${prefix}" | sed 's/[][().^$*+?{|]/\\&/g')
pattern="^${escaped}(-[0-9]+)?$"

pick_node() {
  tailscale status --json | jq -r --arg re "${pattern}" '
    def dns_label:
      rtrimstr(".") | split(".")[0];
    def is_match:
      ((.HostName // "") | test($re))
      or ((.DNSName // "") | dns_label | test($re));
    def exit_id:
      if ((.DNSName // "") != "") then (.DNSName | rtrimstr("."))
      else .HostName end;
    [.Peer[]?
     | select(.Online == true and .ExitNodeOption == true)
     | select(is_match)]
    | sort_by(exit_id)
    | .[0]
    | select(. != null)
    | exit_id
  '
}

node=""
for _ in $(seq 1 30); do
  node=$(pick_node || true)
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

echo "Using exit node ${node} (prefix ${prefix}, hint ${EXIT_NODE})"
sudo tailscale set --exit-node="${node}" --exit-node-allow-lan-access
