# Rocky 10 Plasma Apptainer Desktop for Selkies

This repository contains the Apptainer image definition and small build helpers
for a Rocky 10 KDE Plasma desktop used with Selkies/PixelFlux.

The built `.sif` image is intentionally not stored in Git.

## Contents

- `rocky10-plasma.def` - Apptainer definition for the Rocky 10 Plasma image.
- `scripts/build.sh` - local build helper.
- `scripts/install.sh` - install a built image into the live Selkies image path.

Open OnDemand app files are intentionally kept out of this repository. They
belong in a separate OOD application repository.

## Build

```bash
sudo apptainer build --force rocky10-plasma.sif rocky10-plasma.def
```

or:

```bash
./scripts/build.sh
```

## Install

```bash
sudo ./scripts/install.sh rocky10-plasma.sif /opt/selkies-ood/containers/rocky10-gnome.sif
```

The install helper backs up the previous live image before replacing it.

## Runtime Contract

The image expects to be launched by an outer Selkies/PixelFlux process that has
already created a Wayland socket.

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

## Notes

`kwin_wayland` may be installed with file capability `cap_sys_nice=ep` on Rocky
10. The definition strips that capability because Apptainer can refuse to
execute files with capabilities in this environment.
