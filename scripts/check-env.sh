#!/usr/bin/env bash
set -euo pipefail

missing=0

for command_name in \
    python pip cmake ninja node npm codex \
    git gh curl wget bash fish tmux file tree htop jq bsdtar clangd \
    git-branchless sudo bwrap socat rg fd fzf; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'missing command: %s\n' "$command_name" >&2
        missing=1
    fi
done

python - <<'PY' || missing=1
from importlib import metadata

packages = (
    "pytest",
    "pytest-flakefinder",
    "pre-commit",
)

failed = False
for package in packages:
    try:
        version = metadata.version(package)
    except metadata.PackageNotFoundError:
        print(f"missing package: {package}")
        failed = True
    else:
        print(f"{package:24} {version}")

if failed:
    raise SystemExit(1)
PY

python -m pip check || missing=1

if ((missing)); then
    exit 1
fi

printf 'environment check passed\n'
