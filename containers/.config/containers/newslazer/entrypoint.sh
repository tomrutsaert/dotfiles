#!/usr/bin/env bash
# On first run: fetch the current Newslazer release metadata, download the
# official Linux zip, verify its SHA-512, and unpack the bundled AppImage
# with --appimage-extract (FUSE isn't available inside rootless podman).
# Subsequent runs skip straight to launch.
#
# This bypasses the proprietary `.run` "installer" entirely — that tool was
# only a Qt-based downloader anyway (InstallerManager / httpGet), and it
# trips over the missing FUSE inside the sandbox. We go to the same CDN
# it would have used.
set -euo pipefail

INSTALL_DIR=/opt/newslazer
APPRUN="${INSTALL_DIR}/squashfs-root/AppRun"
METADATA_URL="https://cdn.aboutusenet.com/nl/setup/package.json"

if [[ ! -x "${APPRUN}" ]]; then
    workdir="$(mktemp -d)"
    trap 'rm -rf "${workdir}"' EXIT

    # NOTE: cdn.aboutusenet.com's certificate was expired when this script
    # was written (2026-04). We use -k to proceed and rely on the SHA-512
    # from package.json for integrity.
    curl_opts=(--fail --show-error --silent --location --insecure)

    echo ">>> Fetching release metadata..."
    curl "${curl_opts[@]}" -o "${workdir}/package.json" "${METADATA_URL}"

    url="$(jq -r '.product_files[] | select(.os=="lin*64") | .url'              "${workdir}/package.json")"
    sha="$(jq -r '.product_files[] | select(.os=="lin*64") | .checksums.sha512' "${workdir}/package.json")"
    version="$(jq -r '.app_version' "${workdir}/package.json")"

    if [[ -z "${url}" || -z "${sha}" ]]; then
        echo "ERROR: couldn't find lin*64 entry in ${METADATA_URL}" >&2
        exit 1
    fi

    echo ">>> Downloading Newslazer ${version}..."
    zip="${workdir}/newslazer.zip"
    curl "${curl_opts[@]}" -o "${zip}" "${url}"

    echo ">>> Verifying SHA-512..."
    echo "${sha}  ${zip}" | sha512sum -c -

    echo ">>> Unzipping..."
    unzip -q "${zip}" -d "${workdir}/unpacked"

    appimage="$(find "${workdir}/unpacked" -maxdepth 1 -iname '*.AppImage' | head -n1)"
    if [[ -z "${appimage}" ]]; then
        echo "ERROR: no AppImage found inside ${url}" >&2
        exit 1
    fi

    echo ">>> Extracting AppImage into ${INSTALL_DIR}..."
    chmod +x "${appimage}"
    cd "${INSTALL_DIR}"
    "${appimage}" --appimage-extract >/dev/null

    if [[ ! -x "${APPRUN}" ]]; then
        echo "ERROR: extraction finished but ${APPRUN} is missing." >&2
        exit 1
    fi
    echo ">>> Installed Newslazer ${version}."
fi

exec "${APPRUN}" "$@"
