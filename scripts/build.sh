#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
definition="${1:-${repo_root}/rocky10-plasma.def}"
output="${2:-${repo_root}/rocky10-plasma.sif}"

apptainer build --force "${output}" "${definition}"
