#!/bin/bash
# Bolt Framework — start-bolt-copilot.sh
#
# Launches `copilot` with one --plugin-dir per plugin selected in plugins-state.yaml.
#
# Copilot CLI has no project/local install scope (unlike Claude Code's --scope project)
# and no persisted config/env var for --plugin-dir — see "Alcance por proyecto (scope)"
# in docs/bolt-plugin-distribution-proposal.md. `bolt plugin` therefore never runs
# `copilot plugin install/uninstall` for bolt-framework plugins; instead, this launcher
# resolves each plugin id from .boltf/memory/plugins-state.yaml to a local directory and
# passes it via --plugin-dir on every invocation — nothing needs to be "installed".
#
# Resolution order per plugin id (first match wins):
#   1. plugins/<id>/            — local copy (current monorepo layout, or a plugin kept
#                                  vendored via plugins/<id>/.vendor-sources.yaml).
#   2. Claude Code's own cache  — if `claude plugin install <id>@bolt-framework
#                                  --scope project` already ran, reuse its resolved
#                                  installPath. Claude already resolved the marketplace
#                                  entry's `source` (local path or remote git repo), so
#                                  this works even if a plugin has been split into its
#                                  own repo (Fase 3) and there is no local plugins/<id>/.
#
# Any arguments passed to this script are forwarded to `copilot` as-is.
#
# Requires: jq (to parse `claude plugin list --json` for the cache-path fallback).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MARKETPLACE_NAME="bolt-framework"
STATE_FILE="$PROJECT_ROOT/.boltf/memory/plugins-state.yaml"

if ! command -v copilot >/dev/null 2>&1; then
    echo "❌ No se encontró 'copilot' en PATH." >&2
    exit 1
fi

get_plugins_state() {
    [[ -f "$STATE_FILE" ]] || return 0
    awk '/^installed:/{f=1;next} /^[^ ]/{f=0} f && /^[[:space:]]*-[[:space:]]*/{gsub(/^[[:space:]]*-[[:space:]]*/,"");print}' "$STATE_FILE"
}

# Reuses Claude Code's already-resolved cache path for a plugin at scope=project,
# if Claude is present and has it installed — works regardless of whether the
# plugin's marketplace source is a local path or a remote per-plugin repo (Fase 3).
get_claude_cache_path() {
    local id="$1"
    command -v claude >/dev/null 2>&1 || return 1
    command -v jq >/dev/null 2>&1 || return 1
    claude plugin list --json 2>/dev/null \
        | jq -r --arg id "$id@$MARKETPLACE_NAME" \
            '.[] | select(.id==$id and .scope=="project") | .installPath' \
        | head -n1
}

resolve_plugin_dir() {
    local id="$1"
    local local_path="$PROJECT_ROOT/plugins/$id"
    if [[ -d "$local_path" ]]; then
        echo "$local_path"
        return 0
    fi
    local cache_path
    cache_path="$(get_claude_cache_path "$id" || true)"
    if [[ -n "$cache_path" && -d "$cache_path" ]]; then
        echo "$cache_path"
        return 0
    fi
    return 1
}

mapfile -t ids < <(get_plugins_state)
[[ ${#ids[@]} -eq 0 ]] && ids=("bolt-core")

plugin_dir_args=()
for id in "${ids[@]}"; do
    dir="$(resolve_plugin_dir "$id" || true)"
    if [[ -n "$dir" ]]; then
        plugin_dir_args+=(--plugin-dir "$dir")
    else
        echo "⚠️  No se pudo resolver un directorio local para '$id' (ni plugins/$id ni caché de Claude)." >&2
        echo "    Ejecuta 'bolt plugin config' con Claude Code instalado, o restaura la copia vendorizada." >&2
    fi
done

exec copilot "${plugin_dir_args[@]}" "$@"
