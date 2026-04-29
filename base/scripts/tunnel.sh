#!/usr/bin/env bash
# SSH-tunnel a list of dev ports from a remote host to this machine.
# Run locally, then hit http://localhost:<port>/... in the browser.
#
# Usage: tunnel.sh [user@]host

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") [user@]host" >&2
  exit 1
fi
HOST="$1"

PORTS=(
  1617 1627 8161 61616 61626
  2181 9494 9052 9996 9997 29092
  2222
  3000 3306 8025 9090 9104
  4000 6085 6161 8001 15099
  7050 7051 7052
  6162 8002 8088 10101 10443
  6701 8000 8080 8085 10001 10099
  6702 8081 8086 10002 10100
  8200 8280 10299 12443
  6080 6700 6704 6705
  9070 9071 9072 9073 9999
  5601 9200 9600
  5151
  7171
  8051
  8686
  8090
  9877
  9878
  4002 4300
  3666 3667 3668
)

# dedupe + sort
mapfile -t UNIQUE < <(printf '%s\n' "${PORTS[@]}" | sort -un)

ARGS=()
for p in "${UNIQUE[@]}"; do
  ARGS+=(-L "${p}:localhost:${p}")
done

echo "Forwarding ${#UNIQUE[@]} ports from ${HOST} -> laptop localhost:"
printf '%s\n' "${UNIQUE[@]}" | paste -sd' ' -
echo "Browse on the laptop at http://localhost:<port>/..."
echo

# -N: no remote command, just tunnel.
# ServerAlive*: drop the connection promptly if the desktop sleeps / wifi dies.
# ExitOnForwardFailure: fail fast if a local port is already in use.
exec ssh -N \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -o ExitOnForwardFailure=yes \
  "${ARGS[@]}" "${HOST}"
