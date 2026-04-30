#!/usr/bin/env bash
# Run baton-http against Symphony. Reads optional config from .env in
# this directory.
#
# Local sync mode (default): writes ./sync.c1z that you can dump with
# the `baton` CLI.
#
# Service mode: set C1_CLIENT_ID + C1_CLIENT_SECRET in .env (issued by
# your ConductorOne tenant when registering a custom connector) and the
# script will pass them through automatically.

set -euo pipefail

cd "$(dirname "$0")"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# Defaults so a fresh checkout runs with no setup.
: "${SYMPHONY_API_TOKEN:=demo-secret}"
: "${CONFIG_PATH:=symphony.yaml}"
: "${BATON_HTTP:=baton-http}"
export SYMPHONY_API_TOKEN

if ! command -v "$BATON_HTTP" >/dev/null 2>&1 && [ ! -x "$BATON_HTTP" ]; then
  cat >&2 <<EOF
error: '$BATON_HTTP' not found.

Install with:
  go install github.com/conductorone/baton-http/cmd/baton-http@latest

Or point BATON_HTTP at a local build:
  BATON_HTTP=../../baton-http/baton-http ./run.sh
EOF
  exit 1
fi

ARGS=( --config-path "$CONFIG_PATH" )

if [ -n "${C1_CLIENT_ID:-}" ] && [ -n "${C1_CLIENT_SECRET:-}" ]; then
  echo "running in service mode (streaming to ConductorOne)"
  ARGS+=( --client-id "$C1_CLIENT_ID" --client-secret "$C1_CLIENT_SECRET" )
else
  echo "running in local sync mode (writes .c1z file)"
fi

exec "$BATON_HTTP" "${ARGS[@]}" "$@"
