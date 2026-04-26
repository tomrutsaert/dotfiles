#!/usr/bin/env bash
# Standalone launcher — equivalent to `podman-compose run --rm newslazer`
# but without the compose dependency. Safe to invoke from anywhere.
set -euo pipefail

here="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
image="localhost/newslazer:latest"
downloads="${HOME}/appdata/echo/appdata/sabnzbd/config/watch"
display="${DISPLAY:-:0}"
x11_socket="/tmp/.X11-unix"

# Newslazer's bundled Qt5 ships only the xcb plugin, so we target XWayland
# via the host's X11 unix socket rather than the native Wayland one.
if [[ ! -S "${x11_socket}/X${display#:}" ]]; then
    echo "ERROR: X11 socket ${x11_socket}/X${display#:} not found." >&2
    echo "       Is XWayland running on your compositor?" >&2
    exit 1
fi

if ! podman image exists "${image}"; then
    echo ">>> Building image ${image}"
    podman build \
        --build-arg "UID=$(id -u)" \
        --build-arg "GID=$(id -g)" \
        -t "${image}" \
        "${here}"
fi

mkdir -p "${downloads}"

exec podman run --rm -it \
    --name newslazer \
    --userns keep-id \
    --security-opt label=disable \
    --device /dev/dri \
    -e DISPLAY="${display}" \
    -e QT_QPA_PLATFORM=xcb \
    -v "${x11_socket}:${x11_socket}" \
    -v "newslazer-install:/opt/newslazer" \
    -v "newslazer-home:/home/app/.config" \
    -v "${downloads}:/home/app/Downloads:Z" \
    "${image}" "$@"
