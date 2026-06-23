#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 SOURCE_SIF [DESTINATION_SIF]" >&2
  exit 2
fi

source_sif="$1"
destination="${2:-/opt/selkies-ood/containers/rocky10-gnome.sif}"

if [[ ! -r "${source_sif}" ]]; then
  echo "Source image is not readable: ${source_sif}" >&2
  exit 1
fi

destination_dir="$(dirname "${destination}")"
destination_base="$(basename "${destination}")"
timestamp="$(date +%Y%m%d%H%M%S)"

install -d -m 0755 "${destination_dir}"

if [[ -e "${destination}" ]]; then
  cp -a "${destination}" "${destination_dir}/${destination_base}.bak.${timestamp}"
fi

install -m 0644 "${source_sif}" "${destination}"
stat -c '%n %s %y' "${destination}"
