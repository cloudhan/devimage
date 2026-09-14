#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v mise >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/mise" ]]; then
    curl --proto '=https' --tlsv1.2 -fsSL https://mise.run | sh
fi

mise_bin="$(type -P mise 2>/dev/null || true)"
if [[ -z "$mise_bin" && -x "$HOME/.local/bin/mise" ]]; then
    mise_bin="$HOME/.local/bin/mise"
fi
if [[ -z "$mise_bin" ]]; then
    printf 'mise installation did not produce an executable\n' >&2
    exit 1
fi

"$mise_bin" trust --yes "$repo_dir/mise.toml"
export DEBIAN_FRONTEND=noninteractive
"$mise_bin" --cd "$repo_dir" bootstrap packages use --yes \
    apt:bash apt:bubblewrap apt:ca-certificates apt:clangd apt:curl \
    apt:file apt:fish apt:git apt:htop apt:jq apt:libarchive-tools \
    apt:libdw-dev apt:socat apt:sudo apt:tmux apt:tree apt:wget
"$mise_bin" --cd "$repo_dir" install

install -Dm644 "$repo_dir/scripts/mise.fish" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/mise.fish"

# Make the configured tools visible for the rest of this run without relying
# on shell startup files.
eval "$("$mise_bin" --cd "$repo_dir" env --shell bash)"

# Install only developer packages absent from the raw NGC image. The image's
# Python compute stack is left untouched.
python -m pip install -r "$repo_dir/requirements-dev.txt"

"$repo_dir/scripts/check-env.sh"

printf '\nBootstrap complete. Project directory:\n  %s\n' "$repo_dir"
