#!/bin/bash
# Bolt Framework — bolt plugin (thin wrapper over `copilot plugin` / `claude plugin`)
#
# Implements list/config/add/remove/status/update as described in
# docs/bolt-plugin-distribution-proposal.md ("El comando `bolt plugin`"). Bolt does not
# reimplement install/uninstall/update — it only delegates to whichever native CLI(s)
# (copilot, claude) are detected on PATH, and persists Bolt-specific bookkeeping
# (.boltf/memory/plugins-state.yaml) that the native CLIs don't know about.
#
# Claude Code plugins are installed with --scope project (writes to the project's own
# .claude/settings.json, not the user's global profile) instead of the CLI default (user
# scope) — see "Alcance por proyecto (scope)" in the proposal doc. Copilot CLI has no
# equivalent scope concept for `plugin install`, so this script never calls
# `copilot plugin install/uninstall/update` for bolt-framework plugins — Copilot mounts
# them at runtime via --plugin-dir instead (start-bolt-copilot.sh / Start-BoltCopilot.ps1),
# which reads plugins-state.yaml on every launch.
#
# Claude Code's own --scope project flag has been observed (2026-08-12) to still write to
# the user's GLOBAL ~/.claude/settings.json instead of the project's .claude/settings.json
# in some environments. As a belt-and-braces fallback, set_claude_enabled_plugins writes
# enabledPlugins directly into the project's .claude/settings.json after every
# config/add/remove, independent of what the native CLI actually did.
#
# In "maintainer mode" (run inside this monorepo, detected by the presence of
# .claude-plugin/marketplace.json at the project root) it also offers to refresh
# vendored external content (awesome-copilot) declared in each plugin's
# plugins/<id>/.vendor-sources.yaml — see "Sincronización de contenido vendorizado"
# in the proposal doc. Consumer projects never trigger this.
#
# bolt-core is always installed (decision #4) — never shown in the checklist, can't be removed.
#
# Requires: jq (marketplace.json parsing), curl (vendor sync).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MARKETPLACE_NAME="bolt-framework"
STATE_FILE="$PROJECT_ROOT/.boltf/memory/plugins-state.yaml"
MARKETPLACE_FILE="$PROJECT_ROOT/.claude-plugin/marketplace.json"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; GRAY='\033[0;90m'; NC='\033[0m'
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; }
step() { echo -e "\n${CYAN}$1${NC}"; }

usage() {
    cat <<'EOF'
bolt plugin — wrapper fino sobre 'copilot plugin' / 'claude plugin'

Uso:
  bolt-plugin.sh list
      Delega en <cliente> plugin list (por cada CLI detectada).

  bolt-plugin.sh config [--yes] [--skip-vendor-sync]
      Menú checklist de plugins -> instala/desinstala vía CLI nativa
      + persiste .boltf/memory/plugins-state.yaml.

  bolt-plugin.sh add <id> [--yes] [--skip-vendor-sync]
  bolt-plugin.sh remove <id>
  bolt-plugin.sh status
  bolt-plugin.sh update [<id>] [--all] [--yes] [--skip-vendor-sync]

Flags:
  --all                Con 'update' sin <id>: delega en '<cliente> plugin update --all'.
  --skip-vendor-sync   Omite el refresco de contenido vendorizado (modo mantenedor).
  --yes                Auto-confirma sin preguntar (uso en CI / Test-InitFlows).
  --help               Muestra esta ayuda.

Nota: Claude Code instala con --scope project (.claude/settings.json del proyecto).
Copilot CLI no instala nada -- usa .boltf/scripts/bash/start-bolt-copilot.sh (o
Start-BoltCopilot.ps1) para lanzarlo con --plugin-dir por cada plugin seleccionado.

Ver: docs/bolt-plugin-distribution-proposal.md
EOF
}

COMMAND="${1:-}"
if [[ -n "$COMMAND" ]]; then shift; fi

PLUGIN_ID=""
ALL=false
SKIP_VENDOR_SYNC=false
YES=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all) ALL=true; shift ;;
        --skip-vendor-sync) SKIP_VENDOR_SYNC=true; shift ;;
        --yes) YES=true; shift ;;
        --help) usage; exit 0 ;;
        -*) err "Opción desconocida: $1"; usage; exit 1 ;;
        *) PLUGIN_ID="$1"; shift ;;
    esac
done

if [[ -z "$COMMAND" || "$COMMAND" == "--help" ]]; then
    usage
    exit 0
fi

# ─── CLI / marketplace discovery ─────────────────────────────────────────────
detect_clients() {
    CLIENTS=()
    command -v copilot >/dev/null 2>&1 && CLIENTS+=("copilot")
    command -v claude >/dev/null 2>&1 && CLIENTS+=("claude")
    if [[ ${#CLIENTS[@]} -eq 0 ]]; then
        err "No se encontró ni 'copilot' ni 'claude' en PATH. Instala al menos una CLI."
        exit 1
    fi
}

is_maintainer_mode() { [[ -f "$MARKETPLACE_FILE" ]]; }

get_marketplace_plugins() {
    command -v jq >/dev/null 2>&1 || { err "Se requiere 'jq' para leer marketplace.json"; exit 1; }
    jq -r '.plugins[].name' "$MARKETPLACE_FILE"
}

register_marketplace() {
    local client="$1"
    local -a scope_args=()
    [[ "$client" == "claude" ]] && scope_args=(--scope project)
    (cd "$PROJECT_ROOT" && "$client" plugin marketplace add ./ "${scope_args[@]}" >/dev/null 2>&1) || true
}

invoke_client() {
    local client="$1"; shift
    echo -e "${GRAY}    \$ $client $*${NC}"
    "$client" "$@"
}

# Queries the native CLI's OWN installed-plugin state (ground truth) — NOT
# plugins-state.yaml, which only tracks Bolt's desired/pre-selected set and is
# written before any real `plugin install` call happens (see cmd_config).
#
# claude: `plugin list --json` is GLOBAL — it returns project-scope entries for
# EVERY project on the machine, each tagged with its own `projectPath`. Filtering
# only by scope=="project" (without also matching projectPath to $PROJECT_ROOT)
# makes an unrelated project's plugins look "installed here" and its own plugins
# look like they need (re)installing — which then makes `plugin uninstall
# --scope project` fail with "not installed in project scope" because it never
# was, for THIS project. Both scope AND projectPath must match.
get_installed_plugin_ids() {
    local client="$1"
    if [[ "$client" == "claude" ]]; then
        (cd "$PROJECT_ROOT" && claude plugin list --json 2>/dev/null) \
            | jq -r --arg suffix "@${MARKETPLACE_NAME}" --arg root "${PROJECT_ROOT%/}" \
                '.[] | select(.scope=="project" and (.id | endswith($suffix)) and ((.projectPath // "") | rtrimstr("/") | rtrimstr("\\")) == $root) | .id | sub($suffix; "")'
        return 0
    fi
    (cd "$PROJECT_ROOT" && "$client" plugin list 2>/dev/null) \
        | grep -oE "[[:alnum:]_-]+@${MARKETPLACE_NAME}" \
        | sed "s/@${MARKETPLACE_NAME}\$//"
}

# ─── plugins-state.yaml (Bolt-specific bookkeeping, not a file inventory) ────
get_plugins_state() {
    [[ -f "$STATE_FILE" ]] || return 0
    awk '/^installed:/{f=1;next} /^[^ ]/{f=0} f && /^[[:space:]]*-[[:space:]]*/{gsub(/^[[:space:]]*-[[:space:]]*/,"");print}' "$STATE_FILE"
}

set_plugins_state() {
    local ids=("$@")
    mkdir -p "$(dirname "$STATE_FILE")"
    {
        echo "# Bolt Framework — plugin selection state"
        echo "# Managed by \`bolt plugin\` (Invoke-BoltPlugin.ps1 / bolt-plugin.sh). No editar a mano."
        echo "version: 1"
        echo "updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "installed:"
        printf '%s\n' "${ids[@]}" | sort -u | sed 's/^/  - /'
    } > "$STATE_FILE"
}

# VS Code's built-in Copilot Chat agent picker only auto-discovers
# `.github/agents/*.agent.md`. Bolt ships agents/skills under
# `plugins/<id>/{agents,skills}/` instead, so this must be kept in sync with
# plugins-state.yaml on every config/add/remove — see init.sh's
# set_vscode_agent_discovery (same logic, duplicated here since this script
# has no shared dependency on init.sh).
set_vscode_agent_discovery() {
    local -a plugin_ids=("$@")
    local vscode_dir="$PROJECT_ROOT/.vscode"
    local settings_file="$vscode_dir/settings.json"
    mkdir -p "$vscode_dir"

    if ! command -v jq >/dev/null 2>&1; then
        warn "jq no encontrado — omitiendo actualización de .vscode/settings.json (añade chat.agentFilesLocations/chat.agentSkillsLocations a mano)"
        return 0
    fi

    local agents_json="{}"
    local skills_json="{}"
    for id in "${plugin_ids[@]}"; do
        [[ -d "$PROJECT_ROOT/plugins/$id/agents" ]] && agents_json=$(echo "$agents_json" | jq --arg k "plugins/$id/agents" '. + {($k): true}')
        [[ -d "$PROJECT_ROOT/plugins/$id/skills" ]] && skills_json=$(echo "$skills_json" | jq --arg k "plugins/$id/skills" '. + {($k): true}')
    done

    local existing="{}"
    if [[ -f "$settings_file" ]]; then
        existing=$(sed -E 's|^\s*//.*$||' "$settings_file" | jq -c '.' 2>/dev/null) || {
            warn "No se pudo parsear .vscode/settings.json automáticamente — actualiza chat.agentFilesLocations/chat.agentSkillsLocations a mano"
            return 0
        }
    fi

    echo "$existing" | jq --argjson agents "$agents_json" --argjson skills "$skills_json" \
        '. + {"chat.agentFilesLocations": $agents, "chat.agentSkillsLocations": $skills}' > "$settings_file"
}

# Fallback for when `claude plugin install/uninstall --scope project` doesn't actually
# land in the project's own .claude/settings.json (observed writing to the user's global
# ~/.claude/settings.json instead, 2026-08-12). Rebuilds the enabledPlugins block for
# THIS marketplace's plugins from the desired set on every call — entries for other
# marketplaces are preserved untouched, and every other top-level key
# (extraKnownMarketplaces, etc.) is left as-is. bolt-core is always forced to true
# (decision #4 — never removable).
set_claude_enabled_plugins() {
    local -a plugin_ids=("$@")
    local claude_dir="$PROJECT_ROOT/.claude"
    local settings_file="$claude_dir/settings.json"
    mkdir -p "$claude_dir"

    if ! command -v jq >/dev/null 2>&1; then
        warn "jq no encontrado — omitiendo actualización de .claude/settings.json (añade enabledPlugins a mano)"
        return 0
    fi

    local existing="{}"
    if [[ -f "$settings_file" ]]; then
        existing=$(sed -E 's|^\s*//.*$||' "$settings_file" | jq -c '.' 2>/dev/null) || {
            warn "No se pudo parsear .claude/settings.json automáticamente — actualiza enabledPlugins a mano"
            return 0
        }
    fi

    local kept
    kept=$(echo "$existing" | jq --arg suffix "@${MARKETPLACE_NAME}" '(.enabledPlugins // {}) | with_entries(select(.key | endswith($suffix) | not))')

    local -a ids=("bolt-core")
    for id in "${plugin_ids[@]}"; do [[ "$id" != "bolt-core" ]] && ids+=("$id"); done
    mapfile -t ids < <(printf '%s\n' "${ids[@]}" | sort -u)

    local enabled="$kept"
    for id in "${ids[@]}"; do
        enabled=$(echo "$enabled" | jq --arg k "${id}@${MARKETPLACE_NAME}" '. + {($k): true}')
    done

    echo "$existing" | jq --argjson enabled "$enabled" '. + {enabledPlugins: $enabled}' > "$settings_file"
}


# ─── Interactive checklist (toggle by number, 'a' apply, 'q' cancel) ─────────
# Reads: TOGGLE_ALL_IDS, PRESELECTED (arrays). Writes: CHECKLIST_RESULT, CHECKLIST_CANCELLED.
read_plugin_checklist() {
    local -a all_ids=("$@")
    local -a selected=("${PRESELECTED[@]}")
    while true; do
        echo ""
        echo -e "${CYAN}  Plugins disponibles (bolt-core siempre instalado):${NC}"
        for i in "${!all_ids[@]}"; do
            local id="${all_ids[$i]}"
            local mark="[ ]"
            for s in "${selected[@]:-}"; do [[ "$s" == "$id" ]] && mark="[x]"; done
            printf "    %2d. %s %s\n" "$((i + 1))" "$mark" "$id"
        done
        echo -e "${GRAY}  Números separados por coma para alternar (ej. 1,3) · 'a' aceptar · 'q' cancelar${NC}"
        read -r -p "  > " raw
        if [[ "$raw" == "q" ]]; then
            CHECKLIST_RESULT=()
            CHECKLIST_CANCELLED=true
            return
        fi
        if [[ "$raw" == "a" || -z "$raw" ]]; then
            CHECKLIST_RESULT=("${selected[@]:-}")
            CHECKLIST_CANCELLED=false
            return
        fi
        IFS=',' read -ra toks <<< "$raw"
        for t in "${toks[@]}"; do
            t="$(echo "$t" | tr -d ' ')"
            [[ "$t" =~ ^[0-9]+$ ]] || continue
            local idx=$((t - 1))
            [[ $idx -ge 0 && $idx -lt ${#all_ids[@]} ]] || continue
            local id="${all_ids[$idx]}"
            local found=false
            local -a new_selected=()
            for s in "${selected[@]:-}"; do
                if [[ "$s" == "$id" ]]; then found=true; else new_selected+=("$s"); fi
            done
            if $found; then selected=("${new_selected[@]:-}"); else selected+=("$id"); fi
        done
    done
}

# ─── Vendored content sync (maintainer mode only, see proposal doc) ──────────
sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum | awk '{print $1}'
    else shasum -a 256 | awk '{print $1}'
    fi
}

# Reads plugins/<id>/.vendor-sources.yaml into parallel arrays (fixed 5-line-per-item schema).
read_vendor_items() {
    local file="$1"
    VENDOR_REPO=(); VENDOR_REF=(); VENDOR_PATH=(); VENDOR_DEST=(); VENDOR_SHA=()
    [[ -f "$file" ]] || return 0
    local repo="" ref="" path="" dest=""
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*-[[:space:]]*repo:[[:space:]]*(.+)$ ]] && repo="${BASH_REMATCH[1]}"
        [[ "$line" =~ ^[[:space:]]*ref:[[:space:]]*(.+)$ ]] && ref="${BASH_REMATCH[1]}"
        [[ "$line" =~ ^[[:space:]]*path:[[:space:]]*(.+)$ ]] && path="${BASH_REMATCH[1]}"
        [[ "$line" =~ ^[[:space:]]*dest:[[:space:]]*(.+)$ ]] && dest="${BASH_REMATCH[1]}"
        if [[ "$line" =~ ^[[:space:]]*pinnedSha:[[:space:]]*(.+)$ ]]; then
            VENDOR_REPO+=("$repo"); VENDOR_REF+=("$ref"); VENDOR_PATH+=("$path")
            VENDOR_DEST+=("$dest"); VENDOR_SHA+=("${BASH_REMATCH[1]}")
        fi
    done < "$file"
}

bump_plugin_version() {
    local id="$1"
    local pj="$PROJECT_ROOT/plugins/$id/.claude-plugin/plugin.json"
    [[ -f "$pj" ]] || return 0
    local ver
    ver=$(grep -o '"version": *"[0-9]*\.[0-9]*\.[0-9]*"' "$pj" | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
    IFS='.' read -r major minor patch <<< "$ver"
    local newver="$major.$minor.$((patch + 1))"
    sed -i.bak -E "s/\"version\": *\"$ver\"/\"version\": \"$newver\"/" "$pj" && rm -f "$pj.bak"
    ok "  $id → v$newver"
}

# Rewrites a plugin's .vendor-sources.yaml with freshly recomputed pinnedSha per item.
rewrite_vendor_shas() {
    local file="$1"
    read_vendor_items "$file"
    {
        echo "# plugins/<id>/.vendor-sources.yaml — contenido vendorizado desde fuentes externas (awesome-copilot)."
        echo "# Gestionado por \`bolt plugin\` en modo mantenedor. No editar 'pinnedSha' a mano."
        echo "items:"
        for i in "${!VENDOR_REPO[@]}"; do
            local url="https://raw.githubusercontent.com/${VENDOR_REPO[$i]}/${VENDOR_REF[$i]}/${VENDOR_PATH[$i]}"
            local sha
            sha=$(curl -fsSL "$url" 2>/dev/null | sha256_of)
            echo "  - repo: ${VENDOR_REPO[$i]}"
            echo "    ref: ${VENDOR_REF[$i]}"
            echo "    path: ${VENDOR_PATH[$i]}"
            echo "    dest: ${VENDOR_DEST[$i]}"
            echo "    pinnedSha: $sha"
        done
    } > "$file"
}

vendor_sync() {
    local plugin_ids=("$@")
    is_maintainer_mode || return 0
    $SKIP_VENDOR_SYNC && return 0

    local -a changed_plugin=() changed_dest=() changed_content_file=() changed_newsha=()
    for id in "${plugin_ids[@]}"; do
        local vfile="$PROJECT_ROOT/plugins/$id/.vendor-sources.yaml"
        [[ -f "$vfile" ]] || continue
        read_vendor_items "$vfile"
        for i in "${!VENDOR_REPO[@]}"; do
            local url="https://raw.githubusercontent.com/${VENDOR_REPO[$i]}/${VENDOR_REF[$i]}/${VENDOR_PATH[$i]}"
            local tmp
            tmp=$(mktemp)
            if ! curl -fsSL "$url" -o "$tmp" 2>/dev/null; then
                warn "No se pudo descargar $url — se omite este ítem."
                rm -f "$tmp"; continue
            fi
            local newsha
            newsha=$(sha256_of < "$tmp")
            if [[ "$newsha" != "${VENDOR_SHA[$i]}" ]]; then
                changed_plugin+=("$id"); changed_dest+=("${VENDOR_DEST[$i]}")
                changed_content_file+=("$tmp"); changed_newsha+=("$newsha")
            else
                rm -f "$tmp"
            fi
        done
    done

    [[ ${#changed_plugin[@]} -eq 0 ]] && return 0

    step "Contenido vendorizado con cambios detectados (awesome-copilot):"
    for i in "${!changed_plugin[@]}"; do
        echo "    ${changed_plugin[$i]}: ${changed_dest[$i]} (→ ${changed_newsha[$i]:0:7})"
    done

    if ! $YES; then
        read -r -p "  ¿Aplicar estos cambios vendorizados y subir versión? [y/N] > " ans
        if [[ "$(echo "$ans" | tr '[:upper:]' '[:lower:]')" != "y" ]]; then
            warn "Refresco de contenido vendorizado omitido."
            for f in "${changed_content_file[@]}"; do rm -f "$f"; done
            return 0
        fi
    fi

    local -a done_plugins=()
    for i in "${!changed_plugin[@]}"; do
        local id="${changed_plugin[$i]}"
        if [[ ! " ${done_plugins[*]:-} " =~ " $id " ]]; then
            bump_plugin_version "$id"
            done_plugins+=("$id")
        fi
        local dest="$PROJECT_ROOT/plugins/$id/${changed_dest[$i]}"
        mkdir -p "$(dirname "$dest")"
        cp "${changed_content_file[$i]}" "$dest"
        rm -f "${changed_content_file[$i]}"
    done

    for id in "${done_plugins[@]}"; do
        rewrite_vendor_shas "$PROJECT_ROOT/plugins/$id/.vendor-sources.yaml"
    done

    ok "Contenido vendorizado actualizado."
}

# ─── Commands ─────────────────────────────────────────────────────────────
# Copilot never natively installs bolt-framework plugins — `copilot plugin list` would
# show nothing useful, so this prints the plugins-state.yaml-derived set instead.
cmd_list() {
    detect_clients
    for c in "${CLIENTS[@]}"; do
        if [[ "$c" == "copilot" ]]; then
            step "copilot (vía start-bolt-copilot.sh)"
            mapfile -t ids < <(get_plugins_state)
            [[ ${#ids[@]} -eq 0 ]] && ids=("bolt-core")
            echo "  Copilot no instala plugins nativamente — se montan vía --plugin-dir en cada"
            echo "  arranque de start-bolt-copilot.sh, a partir de plugins-state.yaml:"
            for id in "${ids[@]}"; do echo "    - $id"; done
            continue
        fi
        step "$c plugin list"
        "$c" plugin list
    done
}

cmd_status() {
    if [[ -f "$STATE_FILE" ]]; then
        step "plugins-state.yaml"
        sed 's/^/  /' "$STATE_FILE"
    else
        warn "No existe $STATE_FILE todavía — ejecuta 'bolt plugin config' primero."
    fi
    cmd_list
}

cmd_config() {
    detect_clients
    mapfile -t marketplace_ids < <(get_marketplace_plugins)
    local -a toggleable=()
    for id in "${marketplace_ids[@]}"; do [[ "$id" != "bolt-core" ]] && toggleable+=("$id"); done

    mapfile -t current < <(get_plugins_state)
    [[ ${#current[@]} -eq 0 ]] && current=("bolt-core")
    PRESELECTED=()
    for id in "${current[@]}"; do [[ "$id" != "bolt-core" ]] && PRESELECTED+=("$id"); done

    step "bolt plugin config"
    echo -e "${GREEN}  ✔ bolt-core (siempre instalado)${NC}"

    read_plugin_checklist "${toggleable[@]}"
    if $CHECKLIST_CANCELLED; then warn "Cancelado."; return; fi

    local -a final_set=("bolt-core" "${CHECKLIST_RESULT[@]:-}")

    if ! $YES; then
        read -r -p "  ¿Continuar? [Y/n] > " ans
        [[ "$(echo "$ans" | tr '[:upper:]' '[:lower:]')" == "n" ]] && { warn "Cancelado."; return; }
    fi

    vendor_sync "${final_set[@]}"

    # NOTE: the install/remove diff is computed PER CLIENT against what that
    # client's native CLI actually reports as installed (`plugin list`) — NOT
    # against plugins-state.yaml. The YAML only tracks Bolt's desired/pre-selected
    # set (used above for the checklist defaults) and may already equal final_set
    # even on a brand-new project (Init.ps1/init.sh pre-seed it), which would make
    # a bookkeeping-only diff wrongly conclude "nothing to install".
    for c in "${CLIENTS[@]}"; do
        if [[ "$c" == "copilot" ]]; then
            step "Resumen (copilot)"
            echo "  Copilot no usa instalación nativa para plugins de $MARKETPLACE_NAME."
            echo "  Se montarán dinámicamente vía start-bolt-copilot.sh (--plugin-dir) a partir de plugins-state.yaml."
            continue
        fi

        register_marketplace "$c"
        mapfile -t client_installed < <(get_installed_plugin_ids "$c")
        local -a to_install=() to_remove=()
        for id in "${final_set[@]}"; do
            [[ ! " ${client_installed[*]} " =~ " $id " ]] && to_install+=("$id")
        done
        for id in "${client_installed[@]:-}"; do
            [[ -n "$id" && "$id" != "bolt-core" && ! " ${final_set[*]} " =~ " $id " ]] && to_remove+=("$id")
        done

        step "Resumen ($c)"
        echo "  Instalar: ${to_install[*]:-(ninguno)}"
        echo "  Eliminar: ${to_remove[*]:-(ninguno)}"

        for id in "${to_install[@]:-}"; do [[ -n "$id" ]] && invoke_client "$c" plugin install "$id@$MARKETPLACE_NAME" --scope project; done
        for id in "${to_remove[@]:-}"; do [[ -n "$id" ]] && invoke_client "$c" plugin uninstall "$id@$MARKETPLACE_NAME" --scope project; done
    done

    set_plugins_state "${final_set[@]}"
    set_vscode_agent_discovery "${final_set[@]}"
    [[ " ${CLIENTS[*]} " =~ " claude " ]] && set_claude_enabled_plugins "${final_set[@]}"
    ok "plugins-state.yaml actualizado (${#final_set[@]} plugin(s))."
}

cmd_add() {
    [[ -z "$PLUGIN_ID" ]] && { err "Uso: bolt-plugin.sh add <id>"; exit 1; }
    detect_clients
    mapfile -t marketplace_ids < <(get_marketplace_plugins)
    if [[ ! " ${marketplace_ids[*]} " =~ " $PLUGIN_ID " ]]; then err "Plugin desconocido: $PLUGIN_ID"; exit 1; fi
    if [[ "$PLUGIN_ID" == "bolt-core" ]]; then warn "bolt-core ya está siempre instalado."; return; fi

    vendor_sync "$PLUGIN_ID"

    for c in "${CLIENTS[@]}"; do
        if [[ "$c" == "copilot" ]]; then
            info "Copilot: $PLUGIN_ID se montará vía start-bolt-copilot.sh (--plugin-dir), no requiere instalación."
            continue
        fi
        register_marketplace "$c"
        invoke_client "$c" plugin install "$PLUGIN_ID@$MARKETPLACE_NAME" --scope project
    done

    mapfile -t current < <(get_plugins_state)
    [[ ${#current[@]} -eq 0 ]] && current=("bolt-core")
    [[ ! " ${current[*]} " =~ " $PLUGIN_ID " ]] && current+=("$PLUGIN_ID")
    set_plugins_state "${current[@]}"
    set_vscode_agent_discovery "${current[@]}"
    [[ " ${CLIENTS[*]} " =~ " claude " ]] && set_claude_enabled_plugins "${current[@]}"
    ok "$PLUGIN_ID instalado y registrado en plugins-state.yaml."
}

cmd_remove() {
    [[ -z "$PLUGIN_ID" ]] && { err "Uso: bolt-plugin.sh remove <id>"; exit 1; }
    [[ "$PLUGIN_ID" == "bolt-core" ]] && { err "bolt-core no se puede desinstalar (siempre activo)."; exit 1; }
    detect_clients
    for c in "${CLIENTS[@]}"; do
        if [[ "$c" == "copilot" ]]; then
            info "Copilot: $PLUGIN_ID dejará de montarse en el próximo lanzamiento de start-bolt-copilot.sh."
            continue
        fi
        invoke_client "$c" plugin uninstall "$PLUGIN_ID@$MARKETPLACE_NAME" --scope project
    done
    mapfile -t current < <(get_plugins_state)
    local -a updated=()
    for id in "${current[@]}"; do [[ "$id" != "$PLUGIN_ID" ]] && updated+=("$id"); done
    set_plugins_state "${updated[@]}"
    set_vscode_agent_discovery "${updated[@]}"
    [[ " ${CLIENTS[*]} " =~ " claude " ]] && set_claude_enabled_plugins "${updated[@]}"
    ok "$PLUGIN_ID eliminado y actualizado en plugins-state.yaml."
}

cmd_update() {
    detect_clients
    mapfile -t marketplace_ids < <(get_marketplace_plugins)
    mapfile -t installed < <(get_plugins_state)
    [[ ${#installed[@]} -eq 0 ]] && installed=("bolt-core")

    local -a targets=()
    if [[ -n "$PLUGIN_ID" ]]; then targets=("$PLUGIN_ID")
    elif $ALL; then targets=("${marketplace_ids[@]}")
    else targets=("${installed[@]}")
    fi

    vendor_sync "${targets[@]}"

    for c in "${CLIENTS[@]}"; do
        if [[ "$c" == "copilot" ]]; then
            info "Copilot: no requiere 'update' — start-bolt-copilot.sh siempre usa el contenido actual en disco/caché."
            continue
        fi
        if $ALL && [[ -z "$PLUGIN_ID" ]]; then
            invoke_client "$c" plugin update --all --scope project
        else
            for id in "${targets[@]}"; do invoke_client "$c" plugin update "$id@$MARKETPLACE_NAME" --scope project; done
        fi
    done
    ok "Update completado."
}

case "$COMMAND" in
    list) cmd_list ;;
    config) cmd_config ;;
    add) cmd_add ;;
    remove) cmd_remove ;;
    status) cmd_status ;;
    update) cmd_update ;;
    *) err "Comando desconocido: $COMMAND"; usage; exit 1 ;;
esac
