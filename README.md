# Rocky 10 Plasma Apptainer Desktop for Selkies

This repository contains Apptainer image definitions and small build helpers for
a layered Rocky 10 KDE Plasma desktop used with Selkies/PixelFlux.

The built `.sif` image is intentionally not stored in Git.

## Contents

- `rocky10-plasma-base.def` - base Rocky 10 Plasma image with static OS,
  desktop, codec, and build dependencies.
- `rocky10-plasma.def` - Selkies development/runtime layer built from the base
  image.
- `Makefile` - local build helper.

Open OnDemand app files are intentionally kept out of this repository. They
belong in a separate OOD application repository.

## Build

```bash
make build
```

This builds both layers:

```bash
apptainer build --force rocky10-plasma-base.sif rocky10-plasma-base.def
apptainer build --force rocky10-plasma.sif rocky10-plasma.def
```

`rocky10-plasma.def` uses `Bootstrap: localimage` and expects
`rocky10-plasma-base.sif` in the build directory. To rebuild only the Selkies
layer after Selkies changes, run `make final`.

## Publish

Publish the final `rocky10-plasma.sif` with your site's normal artifact release
process. In production HPC environments this will commonly be a CVMFS
publication workflow, not a direct copy into a local `/opt` path. The base image
can also be published if you want a reusable development base, but the OOD app
uses the final Selkies image.

This repository intentionally does not encode a site-specific CVMFS repository,
transaction command, or destination path.

The base image is published by GitHub Actions to GHCR as an Apptainer ORAS
artifact:

```bash
apptainer pull rocky10-plasma-base.sif oras://ghcr.io/jose-d/selkies-ood-apptainer-rocky10-plasma/rocky10-plasma-base:latest
```

The workflow builds only `rocky10-plasma-base.sif`. Pushes to `main` publish the
`latest` tag and the short commit SHA. Tags matching `base-*` publish the exact
Git tag and the short commit SHA.

## Runtime Contract

The base image includes:

- Rocky 10 KDE Plasma, KWin Wayland, Xwayland, and Wayland runtime packages
- development tools used by the Selkies layer
- `wl-paste` and `wl-copy` from `wl-clipboard`
- `/opt/selkies-codecs` with portable software H.264 support:
  - generic shared `libx264`
  - the matching GStreamer `x264enc` plugin

The final Selkies image builds on the base image and adds Selkies under
`/opt/selkies-ood`:

- `/opt/selkies-ood/venv/bin/selkies`
- `/opt/selkies-ood/web`

The final image patches Selkies' Wayland input handler to honor the standard
`XKB_DEFAULT_LAYOUT`, `XKB_DEFAULT_VARIANT`, and `XKB_DEFAULT_OPTIONS`
environment variables instead of forcing a US keymap. This is required for
non-US layouts such as Czech.

This codec layer is built without `-march=native`; it is intended as a generic
portable baseline for CVMFS-style distribution, not as a per-node optimized
build.

The image is a platform image. It provides Selkies, KDE Plasma, KWin Wayland,
Xwayland, web assets, and codecs, but it does not provide runtime launcher
scripts or an Apptainer runscript. The Open OnDemand app owns launch
orchestration and should run its own scripts with `apptainer exec`.

Required environment:

- `XDG_RUNTIME_DIR` - runtime directory containing the outer PixelFlux Wayland socket.
- `WAYLAND_DISPLAY` - outer PixelFlux Wayland socket name.

Optional environment:

- `SELKIES_NESTED_SOCKET` - nested KWin socket name, default `rocky10-kde`.
- `SELKIES_NESTED_WIDTH` - nested desktop width, default `1500`.
- `SELKIES_NESTED_HEIGHT` - nested desktop height, default `850`.
- `SELKIES_NESTED_LOG` - KDE startup log path, default `/tmp/rocky10-kde.log`.
- `XKB_DEFAULT_LAYOUT` - keyboard layout used by Selkies Wayland input, default
  from Selkies fallback is `us`.
- `XKB_DEFAULT_VARIANT` - optional keyboard layout variant.
- `XKB_DEFAULT_OPTIONS` - optional keyboard layout options.

The app-owned KDE launcher starts:

1. nested `kwin_wayland` on the outer PixelFlux Wayland display
2. a session bus with `dbus-run-session`
3. `kded6`
4. `plasmashell --no-respawn`
5. `dolphin`

The app-owned Selkies launcher starts `/opt/selkies-ood/venv/bin/selkies`,
defaults `SELKIES_WEB_ROOT` to `/opt/selkies-ood/web`, and prepends
`/opt/selkies-codecs` to the codec-related library paths.

## Notes

`kwin_wayland` may be installed with file capability `cap_sys_nice=ep` on Rocky
10. The definition strips that capability because Apptainer can refuse to
execute files with capabilities in this environment.

The Selkies Python package and web frontend are built from pinned upstream
commit `5686f6c4d20ed63a27e253bac00fb89ef99828c8`.

The bundled software H.264 layer is built from pinned upstream source refs:

- x264 `b35605ace3ddf7c1a5d67a2eb553f034aef41d55`
- GStreamer `1.26.7` tag commit `0c88a1af6b5ab19f9d2bc8dc725fec90b7fe5494`
