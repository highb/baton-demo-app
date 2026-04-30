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
  if command -v go >/dev/null 2>&1 && [ -t 0 ]; then
    read -r -p "'$BATON_HTTP' not found. go install github.com/conductorone/baton-http/cmd/baton-http@latest? [Y/n] " reply
    case "$reply" in
      ""|y|Y|yes|YES)
        echo "→ go install github.com/conductorone/baton-http/cmd/baton-http@latest"
        go install github.com/conductorone/baton-http/cmd/baton-http@latest

        # The install lands in $GOBIN or $GOPATH/bin (default ~/go/bin).
        # Make sure that dir is on PATH for the rest of this script.
        gobin="$(go env GOBIN 2>/dev/null)"
        [ -z "$gobin" ] && gobin="$(go env GOPATH 2>/dev/null)/bin"
        export PATH="$gobin:$PATH"

        if ! command -v "$BATON_HTTP" >/dev/null 2>&1; then
          echo >&2 "installed, but '$BATON_HTTP' still isn't on PATH."
          echo >&2 "add this to your shell profile:  export PATH=\"$gobin:\$PATH\""
          exit 1
        fi
        echo "→ installed at $(command -v "$BATON_HTTP")"
        ;;
      *)
        echo "skipping install. point BATON_HTTP at a binary or run go install yourself."
        exit 1
        ;;
    esac
  else
    cat >&2 <<EOF
error: '$BATON_HTTP' not found.

Install with:
  go install github.com/conductorone/baton-http/cmd/baton-http@latest

Or point BATON_HTTP at a local build:
  BATON_HTTP=../../baton-http/baton-http ./run.sh
EOF
    exit 1
  fi
fi

ARGS=( --config-path "$CONFIG_PATH" )

if [ -n "${C1_CLIENT_ID:-}" ] && [ -n "${C1_CLIENT_SECRET:-}" ]; then
  if [ -n "${BATON_C1_API_HOST:-}" ]; then
    echo "running in service mode → $BATON_C1_API_HOST"
  else
    echo "running in service mode → host parsed from client-secret (typically prod)"
  fi
  ARGS+=( --client-id "$C1_CLIENT_ID" --client-secret "$C1_CLIENT_SECRET" )
else
  echo "running in local sync mode (writes .c1z file)"
fi

exec "$BATON_HTTP" "${ARGS[@]}" "$@"
