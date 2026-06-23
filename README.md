# Rocky 10 Plasma Apptainer Desktop for Selkies

This repository contains the Apptainer image definition and small build helpers
for a self-contained Rocky 10 KDE Plasma desktop used with Selkies/PixelFlux.

The built `.sif` image is intentionally not stored in Git.

## Contents

- `rocky10-plasma.def` - Apptainer definition for the Rocky 10 Plasma image.
- `Makefile` - local build helper.

Open OnDemand app files are intentionally kept out of this repository. They
belong in a separate OOD application repository.

## Build

```bash
sudo apptainer build --force rocky10-plasma.sif rocky10-plasma.def
```

or:

```bash
make build
```

## Publish

Publish the built `.sif` with your site's normal artifact release process. In
production HPC environments this will commonly be a CVMFS publication workflow,
not a direct copy into a local `/opt` path.

This repository intentionally does not encode a site-specific CVMFS repository,
transaction command, or destination path.

## Runtime Contract

The image includes Selkies under `/opt/selkies-ood`:

- `/opt/selkies-ood/venv/bin/selkies`
- `/opt/selkies-ood/web`
- `/opt/selkies/bin/start-selkies`

The image also includes `wl-paste` and `wl-copy` from `wl-clipboard` so
Selkies clipboard synchronization can read and write the Wayland clipboard
without host-side binary binds.

The image also includes a portable software H.264 path under
`/opt/selkies-codecs`:

- generic shared `libx264`
- the matching GStreamer `x264enc` plugin

This codec layer is built without `-march=native`; it is intended as a generic
portable baseline for CVMFS-style distribution, not as a per-node optimized
build.

The image also includes the nested KDE launcher:

- `/opt/selkies/bin/start-pixelflux-kde`

The KDE launcher expects to be run after Selkies/PixelFlux has already created a
Wayland socket. An OOD wrapper can therefore start `start-selkies`, wait for the
PixelFlux socket, and then run the image runscript or `start-pixelflux-kde`.

Required environment:

- `XDG_RUNTIME_DIR` - runtime directory containing the outer PixelFlux Wayland socket.
- `WAYLAND_DISPLAY` - outer PixelFlux Wayland socket name.

Optional environment:

- `SELKIES_NESTED_SOCKET` - nested KWin socket name, default `rocky10-kde`.
- `SELKIES_NESTED_WIDTH` - nested desktop width, default `1500`.
- `SELKIES_NESTED_HEIGHT` - nested desktop height, default `850`.
- `SELKIES_NESTED_LOG` - KDE startup log path, default `/tmp/rocky10-kde.log`.

The runscript starts:

1. nested `kwin_wayland` on the outer PixelFlux Wayland display
2. a session bus with `dbus-run-session`
3. `kded6`
4. `plasmashell --no-respawn`
5. `weston-terminal` and `dolphin`

The `start-selkies` helper starts the embedded Selkies server and defaults
`SELKIES_WEB_ROOT` to `/opt/selkies-ood/web`.

## Notes

`kwin_wayland` may be installed with file capability `cap_sys_nice=ep` on Rocky
10. The definition strips that capability because Apptainer can refuse to
execute files with capabilities in this environment.

The Selkies Python package and web frontend are built from pinned upstream
commit `5686f6c4d20ed63a27e253bac00fb89ef99828c8`.

The bundled software H.264 layer is built from pinned upstream source refs:

- x264 `b35605ace3ddf7c1a5d67a2eb553f034aef41d55`
- GStreamer `1.26.7` tag commit `0c88a1af6b5ab19f9d2bc8dc725fec90b7fe5494`
