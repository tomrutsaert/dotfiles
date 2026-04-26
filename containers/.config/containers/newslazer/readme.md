# newslazer (sandboxed)

Runs [Newslazer](https://newslazer.com) inside a rootless podman container
so the proprietary binary never touches the host filesystem outside a single
NZB drop directory.

## How it works

The `.run` "installer" shipped by Newslazer is a Qt-based downloader that
HTTP-fetches a zip, extracts an AppImage, and tries to FUSE-mount it — FUSE
isn't available inside rootless podman, so we bypass the installer entirely
and do our own fetch:

1. First run: `entrypoint.sh` fetches
   [`cdn.aboutusenet.com/nl/setup/package.json`](https://cdn.aboutusenet.com/nl/setup/package.json)
   for the current release metadata.
2. Downloads the Linux zip listed there.
3. Verifies the SHA-512 from the JSON (the CDN's TLS cert has been expired
   since 2026-04, so `curl -k` is used — integrity is restored by the
   checksum pin).
4. Unzips and unpacks the inner AppImage with `--appimage-extract` into
   `/opt/newslazer` (a persistent podman volume). No FUSE required.
5. Launches `AppRun` from the extracted tree.

Subsequent runs skip straight to step 5.

## What gets exposed to the container

| Host | Container | Why |
| --- | --- | --- |
| `/tmp/.X11-unix` | `/tmp/.X11-unix` | GUI rendering via XWayland (Newslazer's bundled Qt5 only ships the xcb plugin) |
| `/dev/dri` | `/dev/dri` | GPU accel for Qt/OpenGL |
| `newslazer-install` (podman volume) | `/opt/newslazer` | Extracted AppImage |
| `newslazer-home`   (podman volume) | `/home/app/.config` | App settings |
| `~/appdata/echo/appdata/sabnzbd/config/watch` | `/home/app/Downloads` | NZB download target (SABnzbd watch dir) |

Nothing else from `$HOME` is visible inside the container. The `.run`
installer file is no longer used.

## First run

```
./run.sh
# or, via compose:
podman-compose run --rm newslazer
```

Takes ~30 s on first launch (100 MB download + unzip + extract). Subsequent
runs are instant.

Inside Newslazer, set the download directory to `/home/app/Downloads`. Files
written there appear on the host under
`~/appdata/echo/appdata/sabnzbd/config/watch/`, where SABnzbd will pick them
up automatically.

## Updating

Delete the install volume and rerun — the entrypoint will fetch whatever is
current at the CDN:

```
podman volume rm newslazer-install
./run.sh
```

## Resetting everything

```
podman volume rm newslazer-install newslazer-home
podman rmi localhost/newslazer:latest
```
