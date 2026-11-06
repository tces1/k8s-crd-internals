#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PORT="${PORT:-4174}"
HOST="${HOST:-127.0.0.1}"
URL="http://${HOST}:${PORT}/"

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required" >&2
  exit 1
fi

if command -v lsof >/dev/null 2>&1; then
  if lsof -iTCP:"${PORT}" -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Port ${PORT} is already in use."
    echo "Open: ${URL}"
    if [[ "${OPEN_BROWSER:-1}" == "1" ]] && command -v open >/dev/null 2>&1; then
      open "${URL}"
    fi
    exit 0
  fi
fi

echo "Serving K8s CRD Internals at ${URL}"
echo "Press Ctrl+C to stop."

if [[ "${OPEN_BROWSER:-1}" == "1" ]] && command -v open >/dev/null 2>&1; then
  (sleep 0.3 && open "${URL}") &
fi

exec python3 -m http.server "${PORT}" --bind "${HOST}"
