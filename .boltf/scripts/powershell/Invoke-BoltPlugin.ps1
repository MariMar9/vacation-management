#Requires -Version 7.0
<#
.SYNOPSIS
    bolt plugin — thin wrapper over the native `copilot plugin` / `claude plugin` CLIs.

.DESCRIPTION
    Implements list/config/add/remove/status/update as described in
    docs/bolt-plugin-distribution-proposal.md ("El comando `bolt plugin`"). Bolt does not
    reimplement install/uninstall/update — it only delegates to whichever native CLI(s)
    (copilot, claude) are detected on PATH, and persists Bolt-specific bookkeeping
    (.boltf/memory/plugins-state.yaml) that the native CLIs don't know about.

    Claude Code plugins are installed with --scope project (writes to the project's own
    .claude/settings.json, not the user's global profile) instead of the CLI default
    (user scope) — see "Alcance por proyecto (scope)" in the proposal doc. Copilot CLI has
    no equivalent scope concept for `plugin install`, so this script never calls
    `copilot plugin install/uninstall/update` for bolt-framework plugins — Copilot mounts
    them at runtime via --plugin-dir instead (Start-BoltCopilot.ps1 / start-bolt-copilot.sh),
    which reads plugins-state.yaml on every launch.

    Claude Code's own --scope project flag has been observed (2026-08-12) to still write to
    the user's GLOBAL ~/.claude/settings.json instead of the project's .claude/settings.json
    in some environments. As a belt-and-braces fallback, Set-ClaudeEnabledPlugins writes
    enabledPlugins directly into the project's .claude/settings.json after every
    config/add/remove, independent of what the native CLI actually did — this makes the
    project's own settings.json authoritative regardless of that CLI quirk.

    In "maintainer mode" (run inside this monorepo, detected by the presence of
    .claude-plugin/marketplace.json at the project root) it also offers to refresh
    vendored external content (awesome-copilot) declared in each plugin's
    plugins/<id>/.vendor-sources.yaml — see "Sincronización de contenido vendorizado"
    in the proposal doc. Consumer projects never trigger this — they only ever receive
    whatever vendored snapshot was last released.

.NOTES
    bolt-core is always installed (decision #4 in the proposal doc) — it is never shown
    in the toggle checklist and can't be removed via `remove`.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list', 'config', 'add', 'remove', 'status', 'update')]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$PluginId,

    [switch]$All,
    [switch]$SkipVendorSync,
    [switch]$Yes,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$script:MarketplaceName = "bolt-framework"

# ─── Logging ─────────────────────────────────────────────────────────────────
function Write-Info { param([string]$m) Write-Host "ℹ️  $m" -ForegroundColor Cyan }
function Write-Ok   { param([string]$m) Write-Host "✅ $m" -ForegroundColor Green }
function Write-Warn { param([string]$m) Write-Host "⚠️  $m" -ForegroundColor Yellow }
function Write-Err  { param([string]$m) Write-Host "❌ $m" -ForegroundColor Red }
function Write-Step { param([string]$m) Write-Host "`n$m" -ForegroundColor Cyan }

# ─── Usage ───────────────────────────────────────────────────────────────────
function Show-Usage {
    Write-Host @"
bolt plugin — wrapper fino sobre 'copilot plugin' / 'claude plugin'

Uso:
  Invoke-BoltPlugin.ps1 list
      Delega en <cliente> plugin list (por cada CLI detectada).

  Invoke-BoltPlugin.ps1 config [-Yes] [-SkipVendorSync]
      Menú checklist de plugins -> instala/desinstala vía CLI nativa
      + persiste .boltf/memory/plugins-state.yaml.

  Invoke-BoltPlugin.ps1 add <id> [-Yes] [-SkipVendorSync]
  Invoke-BoltPlugin.ps1 remove <id>
  Invoke-BoltPlugin.ps1 status
  Invoke-BoltPlugin.ps1 update [<id>] [-All] [-Yes] [-SkipVendorSync]

Flags:
  -All             Con 'update' sin <id>: delega en '<cliente> plugin update --all'.
  -SkipVendorSync  Omite el refresco de contenido vendorizado (modo mantenedor).
  -Yes             Auto-confirma sin preguntar (uso en CI / Test-InitFlows).
  -Help            Muestra esta ayuda.

Nota: Claude Code instala con --scope project (.claude/settings.json del proyecto).
Copilot CLI no instala nada -- usa .boltf/scripts/powershell/Start-BoltCopilot.ps1
(o start-bolt-copilot.sh) para lanzarlo con --plugin-dir por cada plugin seleccionado.

Ver: docs/bolt-plugin-distribution-proposal.md
"@
}

# ─── CLI / marketplace discovery ─────────────────────────────────────────────
function Get-BoltClients {
    $clients = @()
    if (Get-Command copilot -ErrorAction SilentlyContinue) { $clients += 'copilot' }
    if (Get-Command claude -ErrorAction SilentlyContinue) { $clients += 'claude' }
    return $clients
}

function Test-MaintainerMode {
    param([string]$ProjectRoot)
    return Test-Path (Join-Path $ProjectRoot ".claude-plugin\marketplace.json")
}

function Get-MarketplacePlugins {
    param([string]$ProjectRoot)
    $mpPath = Join-Path $ProjectRoot ".claude-plugin\marketplace.json"
    if (-not (Test-Path $mpPath)) {
        throw "No se encontró marketplace.json en $mpPath"
    }
    $mp = Get-Content $mpPath -Raw | ConvertFrom-Json
    return @($mp.plugins | ForEach-Object { $_.name })
}

function Register-Marketplace {
    param([string]$Client, [string]$ProjectRoot)
    Push-Location $ProjectRoot
    try {
        $scopeArgs = if ($Client -eq 'claude') { @('--scope', 'project') } else { @() }
        & $Client plugin marketplace add './' @scopeArgs *> $null
    } finally {
        Pop-Location
    }
}

function Invoke-ClientCommand {
    param([string]$Client, [string[]]$Arguments)
    Write-Host "    `$ $Client $($Arguments -join ' ')" -ForegroundColor DarkGray
    & $Client @Arguments
}

# Queries the native CLI's OWN installed-plugin state (ground truth) — NOT
# plugins-state.yaml, which only tracks Bolt's desired/pre-selected set and is
# written before any real `plugin install` call happens (see Invoke-ConfigCommand).
#
# claude: `plugin list --json` is GLOBAL — it returns project-scope entries for
# EVERY project on the machine, each tagged with its own `projectPath`. Filtering
# only by scope='project' (without also matching projectPath to $ProjectRoot) makes
# an unrelated project's plugins look "installed here" and its own plugins look
# like they need (re)installing — which then makes `plugin uninstall --scope
# project` fail with "not installed in project scope" because it never was, for
# THIS project. Both scope AND projectPath must match.
function Get-InstalledPluginIds {
    param([string]$Client, [string]$ProjectRoot)
    Push-Location $ProjectRoot
    try {
        if ($Client -eq 'claude') {
            $json = & $Client plugin list --json 2>$null
            $ids = @()
            try { $parsed = @(($json -join "`n") | ConvertFrom-Json) } catch { $parsed = @() }
            $marketplaceSuffix = "@$script:MarketplaceName"
            $normalizedRoot = $ProjectRoot.TrimEnd('\', '/')
            foreach ($entry in $parsed) {
                $entryRoot = if ($entry.projectPath) { $entry.projectPath.TrimEnd('\', '/') } else { $null }
                if ($entry.scope -eq 'project' -and $entry.id -like "*$marketplaceSuffix" -and $entryRoot -eq $normalizedRoot) {
                    $ids += $entry.id.Substring(0, $entry.id.Length - $marketplaceSuffix.Length)
                }
            }
            return $ids
        }
        $output = & $Client plugin list 2>$null
    } finally {
        Pop-Location
    }
    $ids = @()
    $marketplace = [regex]::Escape($script:MarketplaceName)
    foreach ($line in $output) {
        if ($line -match "([\w][\w-]*)@$marketplace\b") { $ids += $Matches[1] }
    }
    return $ids
}

# ─── plugins-state.yaml (Bolt-specific bookkeeping, not a file inventory) ────
function Get-PluginsState {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    $installed = @()
    $inBlock = $false
    foreach ($line in Get-Content $Path) {
        if ($line -match '^installed:\s*$') { $inBlock = $true; continue }
        if ($inBlock) {
            if ($line -match '^\s*-\s*(\S+)\s*$') { $installed += $Matches[1] }
            elseif ($line -match '^\S') { $inBlock = $false }
        }
    }
    return $installed
}

function Set-PluginsState {
    param([string]$Path, [string[]]$InstalledIds)
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $sorted = @($InstalledIds | Sort-Object -Unique)
    $lines = @(
        "# Bolt Framework — plugin selection state"
        "# Managed by ``bolt plugin`` (Invoke-BoltPlugin.ps1 / bolt-plugin.sh). No editar a mano."
        "version: 1"
        "updated: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
        "installed:"
    )
    foreach ($id in $sorted) { $lines += "  - $id" }
    Set-Content -Path $Path -Value ($lines -join "`n") -Encoding UTF8
}

# VS Code's built-in Copilot Chat agent picker only auto-discovers
# `.github/agents/*.agent.md`. Bolt ships agents/skills under
# `plugins/<id>/{agents,skills}/` instead, so this must be kept in sync with
# plugins-state.yaml on every config/add/remove — see Init.ps1's
# Set-VSCodeAgentDiscovery (same logic, duplicated here since this script has
# no shared-module dependency on Init.ps1).
function Set-VSCodeAgentDiscovery {
    param([string]$ProjectRoot, [string[]]$PluginIds)

    $vscodeDir = Join-Path $ProjectRoot ".vscode"
    $settingsPath = Join-Path $vscodeDir "settings.json"
    if (-not (Test-Path $vscodeDir)) { New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null }

    $agentLocations = [ordered]@{}
    $skillLocations = [ordered]@{}
    foreach ($id in $PluginIds) {
        if (Test-Path (Join-Path $ProjectRoot "plugins\$id\agents")) { $agentLocations["plugins/$id/agents"] = $true }
        if (Test-Path (Join-Path $ProjectRoot "plugins\$id\skills")) { $skillLocations["plugins/$id/skills"] = $true }
    }

    $existing = $null
    if (Test-Path $settingsPath) {
        try {
            $raw = (Get-Content $settingsPath -Raw) -replace '(?m)^\s*//.*$', ''
            $existing = $raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        } catch {
            Write-Warn "No se pudo parsear .vscode/settings.json automáticamente — actualiza chat.agentFilesLocations/chat.agentSkillsLocations a mano"
            return
        }
    }
    if (-not $existing) { $existing = [ordered]@{} }

    $existing['chat.agentFilesLocations'] = $agentLocations
    $existing['chat.agentSkillsLocations'] = $skillLocations

    ($existing | ConvertTo-Json -Depth 10) | Set-Content -Path $settingsPath -Encoding UTF8
}

# Fallback for when `claude plugin install/uninstall --scope project` doesn't actually land
# in the project's own .claude/settings.json (observed writing to the user's global
# ~/.claude/settings.json instead, 2026-08-12). Rebuilds the enabledPlugins block for THIS
# marketplace's plugins from the desired set on every call — entries for other marketplaces
# are preserved untouched, and every other top-level key (extraKnownMarketplaces, etc.) is
# left as-is. bolt-core is always forced to true (decision #4 — never removable).
function Set-ClaudeEnabledPlugins {
    param([string]$ProjectRoot, [string[]]$PluginIds)

    $claudeDir = Join-Path $ProjectRoot ".claude"
    $settingsPath = Join-Path $claudeDir "settings.json"
    if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

    $existing = $null
    if (Test-Path $settingsPath) {
        try {
            $raw = (Get-Content $settingsPath -Raw) -replace '(?m)^\s*//.*$', ''
            $existing = $raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        } catch {
            Write-Warn "No se pudo parsear .claude/settings.json automáticamente — actualiza enabledPlugins a mano"
            return
        }
    }
    if (-not $existing) { $existing = [ordered]@{} }

    $enabledPlugins = [ordered]@{}
    if ($existing.Contains('enabledPlugins') -and $existing['enabledPlugins']) {
        foreach ($key in $existing['enabledPlugins'].Keys) {
            if ($key -notlike "*@$script:MarketplaceName") { $enabledPlugins[$key] = $existing['enabledPlugins'][$key] }
        }
    }

    $ids = @('bolt-core') + @($PluginIds | Where-Object { $_ -ne 'bolt-core' } | Sort-Object -Unique)
    foreach ($id in $ids) { $enabledPlugins["$id@$script:MarketplaceName"] = $true }

    $existing['enabledPlugins'] = $enabledPlugins
    ($existing | ConvertTo-Json -Depth 10) | Set-Content -Path $settingsPath -Encoding UTF8
}

# ─── Interactive checklist (↑↓ navigate, Space toggle, Enter confirm, Esc cancel) ─
# Same interaction model as Init.ps1's Read-MultiChoice, kept self-contained here
# since this script has no shared-module dependency on Init.ps1.
function Read-PluginChecklist {
    param([string[]]$AllIds, [string[]]$PreSelected)

    $currentIndex = 0
    $selectedIndices = [System.Collections.Generic.List[int]]::new()
    for ($i = 0; $i -lt $AllIds.Count; $i++) {
        if ($AllIds[$i] -in $PreSelected) { $selectedIndices.Add($i) }
    }

    # Redraws a single item row in place — only the two rows that change per keypress
    function Draw-PluginRow {
        param([int]$ItemIndex, [bool]$IsActive, [bool]$IsSelected, [int]$StartLine)

        $checkbox = if ($IsSelected) { "[x]" } else { "[ ]" }
        $prefix   = if ($IsActive)   { "  >" } else { "   " }
        $maxLen   = [Math]::Max(1, [Console]::WindowWidth - 1)
        $line     = ("$prefix $checkbox $($AllIds[$ItemIndex])").PadRight($maxLen).Substring(0, $maxLen)

        $savedColor = [Console]::ForegroundColor
        $maxY = [Console]::BufferHeight - 1
        [Console]::SetCursorPosition(0, [Math]::Min($StartLine + $ItemIndex, $maxY))
        if ($IsActive) { [Console]::ForegroundColor = [ConsoleColor]::Yellow }
        [Console]::Write($line)
        [Console]::ForegroundColor = $savedColor
        [Console]::SetCursorPosition(0, [Math]::Min($StartLine + $AllIds.Count, $maxY))
    }

    # Pre-scroll: reserve enough lines so the menu won't push past the buffer while drawing
    $totalMenuLines = $AllIds.Count + 3
    for ($r = 0; $r -lt $totalMenuLines; $r++) { [Console]::WriteLine("") }
    $blockStart = [Math]::Max(0, [Console]::CursorTop - $totalMenuLines)
    [Console]::SetCursorPosition(0, $blockStart)

    $savedColor = [Console]::ForegroundColor
    [Console]::WriteLine("")
    [Console]::ForegroundColor = [ConsoleColor]::Cyan
    [Console]::WriteLine("  Plugins disponibles (bolt-core siempre instalado)")
    [Console]::ForegroundColor = [ConsoleColor]::DarkGray
    [Console]::WriteLine("  (up/down navigate | Space select | Enter confirm | Esc cancel)")
    [Console]::ForegroundColor = $savedColor

    $itemsStartLine = [Console]::CursorTop
    for ($i = 0; $i -lt $AllIds.Count; $i++) {
        Draw-PluginRow -ItemIndex $i -IsActive ($i -eq $currentIndex) -IsSelected ($selectedIndices.Contains($i)) -StartLine $itemsStartLine
    }
    $maxY = [Console]::BufferHeight - 1
    [Console]::SetCursorPosition(0, [Math]::Min($itemsStartLine + $AllIds.Count, $maxY))

    $cancelled = $false
    $done = $false
    while (-not $done) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.VirtualKeyCode) {
            38 { # Up Arrow
                $oldIndex = $currentIndex
                $currentIndex = if ($currentIndex -gt 0) { $currentIndex - 1 } else { $AllIds.Count - 1 }
                Draw-PluginRow -ItemIndex $oldIndex     -IsActive $false -IsSelected ($selectedIndices.Contains($oldIndex))     -StartLine $itemsStartLine
                Draw-PluginRow -ItemIndex $currentIndex -IsActive $true  -IsSelected ($selectedIndices.Contains($currentIndex)) -StartLine $itemsStartLine
            }
            40 { # Down Arrow
                $oldIndex = $currentIndex
                $currentIndex = if ($currentIndex -lt $AllIds.Count - 1) { $currentIndex + 1 } else { 0 }
                Draw-PluginRow -ItemIndex $oldIndex     -IsActive $false -IsSelected ($selectedIndices.Contains($oldIndex))     -StartLine $itemsStartLine
                Draw-PluginRow -ItemIndex $currentIndex -IsActive $true  -IsSelected ($selectedIndices.Contains($currentIndex)) -StartLine $itemsStartLine
            }
            32 { # Space — toggle selection
                if ($selectedIndices.Contains($currentIndex)) { $selectedIndices.Remove($currentIndex) | Out-Null }
                else { $selectedIndices.Add($currentIndex) }
                Draw-PluginRow -ItemIndex $currentIndex -IsActive $true -IsSelected ($selectedIndices.Contains($currentIndex)) -StartLine $itemsStartLine
            }
            13 { $done = $true } # Enter — confirm
            27 { $done = $true; $cancelled = $true } # Esc — cancel
        }
    }
    Write-Host ""

    if ($cancelled) { return $null }
    $result = @()
    foreach ($idx in $selectedIndices) { $result += $AllIds[$idx] }
    return @($result)
}

# ─── Vendored content sync (maintainer mode only, see proposal doc) ──────────
function Get-VendorItems {
    # Hand-rolled line scanner (fixed 5-line-per-item schema), consistent with
    # Get-PluginsState's approach elsewhere in this file — avoids a full YAML parser.
    param([string]$Path)
    $items = @()
    if (-not (Test-Path $Path)) { return $items }

    $repo = $null; $ref = $null; $vpath = $null; $dest = $null
    foreach ($line in Get-Content $Path) {
        if ($line -match '^\s*-\s*repo:\s*(\S+)\s*$') { $repo = $Matches[1]; continue }
        if ($line -match '^\s*ref:\s*(\S+)\s*$') { $ref = $Matches[1]; continue }
        if ($line -match '^\s*path:\s*(\S+)\s*$') { $vpath = $Matches[1]; continue }
        if ($line -match '^\s*dest:\s*(\S+)\s*$') { $dest = $Matches[1]; continue }
        if ($line -match '^\s*pinnedSha:\s*(\S+)\s*$') {
            $items += [PSCustomObject]@{
                Repo      = $repo
                Ref       = $ref
                Path      = $vpath
                Dest      = $dest
                PinnedSha = $Matches[1]
            }
        }
    }
    return $items
}

function Set-VendorItems {
    param([string]$Path, [object[]]$Items)
    $lines = @(
        "# plugins/<id>/.vendor-sources.yaml — contenido vendorizado desde fuentes externas (awesome-copilot)."
        "# Gestionado por ``bolt plugin`` en modo mantenedor. No editar 'pinnedSha' a mano."
        "items:"
    )
    foreach ($it in $Items) {
        $lines += "  - repo: $($it.Repo)"
        $lines += "    ref: $($it.Ref)"
        $lines += "    path: $($it.Path)"
        $lines += "    dest: $($it.Dest)"
        $lines += "    pinnedSha: $($it.PinnedSha)"
    }
    Set-Content -Path $Path -Value ($lines -join "`n") -Encoding UTF8
}

function Test-VendorItemChanged {
    param($Item)
    $url = "https://raw.githubusercontent.com/$($Item.Repo)/$($Item.Ref)/$($Item.Path)"
    try {
        $remote = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        $content = $remote.Content
    } catch {
        Write-Warn "No se pudo descargar $url — se omite este ítem."
        return $null
    }
    $hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($content))
    $sha = -join ($hashBytes | ForEach-Object { $_.ToString('x2') })
    if ($sha -ne $Item.PinnedSha) {
        return [PSCustomObject]@{ Item = $Item; NewSha = $sha; Content = $content }
    }
    return $null
}

function Step-PluginVersion {
    # Regex patch-bump (not ConvertTo-Json round-trip) to avoid reformatting the whole file.
    param([string]$PluginJsonPath)
    $content = Get-Content $PluginJsonPath -Raw
    if ($content -notmatch '"version":\s*"(\d+)\.(\d+)\.(\d+)"') {
        Write-Warn "No se encontró 'version' semver en $PluginJsonPath"
        return $null
    }
    $newVersion = "$($Matches[1]).$($Matches[2]).$([int]$Matches[3] + 1)"
    $updated = $content -replace '"version":\s*"\d+\.\d+\.\d+"', "`"version`": `"$newVersion`""
    Set-Content -Path $PluginJsonPath -Value $updated -NoNewline -Encoding UTF8
    return $newVersion
}

function Invoke-VendorSync {
    param([string]$ProjectRoot, [string[]]$PluginIds, [switch]$Yes, [switch]$SkipVendorSync)
    if ($SkipVendorSync) { return }
    if (-not (Test-MaintainerMode $ProjectRoot)) { return }

    $plan = @()
    foreach ($id in $PluginIds) {
        $vendorFile = Join-Path $ProjectRoot "plugins\$id\.vendor-sources.yaml"
        if (-not (Test-Path $vendorFile)) { continue }
        $items = Get-VendorItems -Path $vendorFile
        $changed = @()
        foreach ($item in $items) {
            $diff = Test-VendorItemChanged -Item $item
            if ($diff) { $changed += $diff }
        }
        if ($changed.Count -gt 0) {
            $plan += [PSCustomObject]@{ PluginId = $id; VendorFile = $vendorFile; AllItems = $items; Changed = $changed }
        }
    }
    if ($plan.Count -eq 0) { return }

    Write-Step "Contenido vendorizado con cambios detectados (awesome-copilot):"
    foreach ($p in $plan) {
        foreach ($c in $p.Changed) {
            $shortOld = $c.Item.PinnedSha.Substring(0, [Math]::Min(7, $c.Item.PinnedSha.Length))
            Write-Host ("    {0}: {1} ({2} → {3})" -f $p.PluginId, $c.Item.Dest, $shortOld, $c.NewSha.Substring(0, 7))
        }
        Write-Host ("    → {0}: version bump pendiente (patch)" -f $p.PluginId) -ForegroundColor DarkGray
    }

    if (-not $Yes) {
        $ans = Read-Host "  ¿Aplicar estos cambios vendorizados y subir versión? [y/N]"
        if ($ans.Trim().ToLower() -ne 'y') { Write-Warn "Refresco de contenido vendorizado omitido."; return }
    }

    foreach ($p in $plan) {
        $pluginJson = Join-Path $ProjectRoot "plugins\$($p.PluginId)\.claude-plugin\plugin.json"
        $newVersion = Step-PluginVersion -PluginJsonPath $pluginJson
        foreach ($c in $p.Changed) {
            $destPath = Join-Path $ProjectRoot "plugins\$($p.PluginId)\$($c.Item.Dest)"
            $destDir = Split-Path $destPath -Parent
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Set-Content -Path $destPath -Value $c.Content -Encoding UTF8 -NoNewline
            $c.Item.PinnedSha = $c.NewSha
        }
        Set-VendorItems -Path $p.VendorFile -Items $p.AllItems
        Write-Ok "  $($p.PluginId) → v$newVersion ($($p.Changed.Count) fichero(s) actualizados)"
    }
}

# ─── Commands ─────────────────────────────────────────────────────────────
# Copilot never natively installs bolt-framework plugins (see Register-Marketplace /
# Get-InstalledPluginIds notes above) — `copilot plugin list` would show nothing
# useful, so this prints the plugins-state.yaml-derived set plus how to mount them.
function Invoke-ListCommand {
    param([string]$ProjectRoot, [string[]]$Clients)
    foreach ($client in $Clients) {
        if ($client -eq 'copilot') {
            Write-Step "copilot (vía Start-BoltCopilot.ps1)"
            $statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
            $ids = @(Get-PluginsState -Path $statePath)
            if ($ids.Count -eq 0) { $ids = @('bolt-core') }
            Write-Host "  Copilot no instala plugins nativamente — se montan vía --plugin-dir en cada"
            Write-Host "  arranque de Start-BoltCopilot.ps1, a partir de plugins-state.yaml:"
            foreach ($id in $ids) { Write-Host "    - $id" }
            continue
        }
        Write-Step "$client plugin list"
        & $client plugin list
    }
}

function Invoke-StatusCommand {
    param([string]$ProjectRoot, [string[]]$Clients)
    $statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
    if (Test-Path $statePath) {
        Write-Step "plugins-state.yaml"
        Get-Content $statePath | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Warn "No existe $statePath todavía — ejecuta 'bolt plugin config' primero."
    }
    Invoke-ListCommand -ProjectRoot $ProjectRoot -Clients $Clients
}

function Invoke-ConfigCommand {
    param([string]$ProjectRoot, [string[]]$Clients, [switch]$SkipVendorSync, [switch]$Yes)

    $marketplaceIds = Get-MarketplacePlugins -ProjectRoot $ProjectRoot
    $toggleable = @($marketplaceIds | Where-Object { $_ -ne 'bolt-core' })

    $statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
    $current = @(Get-PluginsState -Path $statePath)
    if ($current.Count -eq 0) { $current = @('bolt-core') }
    $preSelected = @($current | Where-Object { $_ -ne 'bolt-core' })

    Write-Step "bolt plugin config"
    Write-Host "  ✔ bolt-core (siempre instalado)" -ForegroundColor Green
    if ($preSelected.Count -gt 0) {
        foreach ($id in $preSelected) { Write-Host "  ✔ $id" -ForegroundColor Green }
    } else {
        Write-Host "  (ningún plugin adicional seleccionado)" -ForegroundColor DarkGray
    }

    # -Yes: accept the pre-selected set as-is (e.g. CI) — no prompts at all.
    if ($Yes) {
        $selected = $preSelected
    } else {
        # Ask before opening the checklist: keep the current selection, or modify it.
        $ans = Read-Host "  ¿Es correcta esta selección? [Y/n]"
        if ($ans.Trim().ToLower() -eq 'n') {
            $selected = Read-PluginChecklist -AllIds $toggleable -PreSelected $preSelected
            if ($null -eq $selected) { Write-Warn "Cancelado."; return }
        } else {
            $selected = $preSelected
        }
    }

    $finalSet = @('bolt-core') + @($selected)

    Invoke-VendorSync -ProjectRoot $ProjectRoot -PluginIds $finalSet -Yes:$Yes -SkipVendorSync:$SkipVendorSync

    # NOTE: the install/remove diff is computed PER CLIENT against what that
    # client's native CLI actually reports as installed (`plugin list`) — NOT
    # against plugins-state.yaml. The YAML only tracks Bolt's desired/pre-selected
    # set (used above for the checklist defaults) and may already equal $finalSet
    # even on a brand-new project (Init.ps1 pre-seeds it), which would make a
    # bookkeeping-only diff wrongly conclude "nothing to install".
    foreach ($client in $Clients) {
        if ($client -eq 'copilot') {
            Write-Step "Resumen (copilot)"
            Write-Host "  Copilot no usa instalación nativa para plugins de $script:MarketplaceName." -ForegroundColor DarkGray
            Write-Host "  Se montarán dinámicamente vía Start-BoltCopilot.ps1 (--plugin-dir) a partir de plugins-state.yaml." -ForegroundColor DarkGray
            continue
        }

        Register-Marketplace -Client $client -ProjectRoot $ProjectRoot
        $clientInstalled = @(Get-InstalledPluginIds -Client $client -ProjectRoot $ProjectRoot)
        $clientToInstall = @($finalSet | Where-Object { $_ -notin $clientInstalled })
        $clientToRemove = @($clientInstalled | Where-Object { $_ -notin $finalSet -and $_ -ne 'bolt-core' })

        Write-Step "Resumen ($client)"
        Write-Host "  Instalar: $(if ($clientToInstall) { $clientToInstall -join ', ' } else { '(ninguno)' })"
        Write-Host "  Eliminar: $(if ($clientToRemove) { $clientToRemove -join ', ' } else { '(ninguno)' })"

        foreach ($id in $clientToInstall) { Invoke-ClientCommand -Client $client -Arguments @('plugin', 'install', "$id@$script:MarketplaceName", '--scope', 'project') }
        foreach ($id in $clientToRemove) { Invoke-ClientCommand -Client $client -Arguments @('plugin', 'uninstall', "$id@$script:MarketplaceName", '--scope', 'project') }
    }

    Set-PluginsState -Path $statePath -InstalledIds $finalSet
    Set-VSCodeAgentDiscovery -ProjectRoot $ProjectRoot -PluginIds $finalSet
    if ($Clients -contains 'claude') { Set-ClaudeEnabledPlugins -ProjectRoot $ProjectRoot -PluginIds $finalSet }
    Write-Ok "plugins-state.yaml actualizado ($($finalSet.Count) plugin(s))."
}

function Invoke-AddCommand {
    param([string]$ProjectRoot, [string[]]$Clients, [string]$PluginId, [switch]$SkipVendorSync, [switch]$Yes)
    if (-not $PluginId) { Write-Err "Uso: bolt plugin add <id>"; return }

    $marketplaceIds = Get-MarketplacePlugins -ProjectRoot $ProjectRoot
    if ($PluginId -notin $marketplaceIds) { Write-Err "Plugin desconocido: $PluginId"; return }
    if ($PluginId -eq 'bolt-core') { Write-Warn "bolt-core ya está siempre instalado."; return }

    Invoke-VendorSync -ProjectRoot $ProjectRoot -PluginIds @($PluginId) -Yes:$Yes -SkipVendorSync:$SkipVendorSync

    foreach ($client in $Clients) {
        if ($client -eq 'copilot') {
            Write-Info "Copilot: $PluginId se montará vía Start-BoltCopilot.ps1 (--plugin-dir), no requiere instalación."
            continue
        }
        Register-Marketplace -Client $client -ProjectRoot $ProjectRoot
        Invoke-ClientCommand -Client $client -Arguments @('plugin', 'install', "$PluginId@$script:MarketplaceName", '--scope', 'project')
    }

    $statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
    $current = @(Get-PluginsState -Path $statePath)
    if ($current.Count -eq 0) { $current = @('bolt-core') }
    if ($PluginId -notin $current) { $current += $PluginId }
    Set-PluginsState -Path $statePath -InstalledIds $current
    Set-VSCodeAgentDiscovery -ProjectRoot $ProjectRoot -PluginIds $current
    if ($Clients -contains 'claude') { Set-ClaudeEnabledPlugins -ProjectRoot $ProjectRoot -PluginIds $current }
    Write-Ok "$PluginId instalado y registrado en plugins-state.yaml."
}

function Invoke-RemoveCommand {
    param([string]$ProjectRoot, [string[]]$Clients, [string]$PluginId)
    if (-not $PluginId) { Write-Err "Uso: bolt plugin remove <id>"; return }
    if ($PluginId -eq 'bolt-core') { Write-Err "bolt-core no se puede desinstalar (siempre activo)."; return }

    foreach ($client in $Clients) {
        if ($client -eq 'copilot') {
            Write-Info "Copilot: $PluginId dejará de montarse en el próximo lanzamiento de Start-BoltCopilot.ps1."
            continue
        }
        Invoke-ClientCommand -Client $client -Arguments @('plugin', 'uninstall', "$PluginId@$script:MarketplaceName", '--scope', 'project')
    }

    $statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
    $current = @(Get-PluginsState -Path $statePath)
    $updated = @($current | Where-Object { $_ -ne $PluginId })
    Set-PluginsState -Path $statePath -InstalledIds $updated
    Set-VSCodeAgentDiscovery -ProjectRoot $ProjectRoot -PluginIds $updated
    if ($Clients -contains 'claude') { Set-ClaudeEnabledPlugins -ProjectRoot $ProjectRoot -PluginIds $updated }
    Write-Ok "$PluginId eliminado y actualizado en plugins-state.yaml."
}

function Invoke-UpdateCommand {
    param([string]$ProjectRoot, [string[]]$Clients, [string]$PluginId, [switch]$All, [switch]$SkipVendorSync, [switch]$Yes)

    $statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
    $marketplaceIds = Get-MarketplacePlugins -ProjectRoot $ProjectRoot
    $installed = @(Get-PluginsState -Path $statePath)
    if ($installed.Count -eq 0) { $installed = @('bolt-core') }

    $targets = if ($PluginId) { @($PluginId) } elseif ($All) { $marketplaceIds } else { $installed }

    Invoke-VendorSync -ProjectRoot $ProjectRoot -PluginIds $targets -Yes:$Yes -SkipVendorSync:$SkipVendorSync

    foreach ($client in $Clients) {
        if ($client -eq 'copilot') {
            Write-Info "Copilot: no requiere 'update' — Start-BoltCopilot.ps1 siempre usa el contenido actual en disco/caché."
            continue
        }
        if ($All -and -not $PluginId) {
            Invoke-ClientCommand -Client $client -Arguments @('plugin', 'update', '--all', '--scope', 'project')
        } else {
            foreach ($id in $targets) { Invoke-ClientCommand -Client $client -Arguments @('plugin', 'update', "$id@$script:MarketplaceName", '--scope', 'project') }
        }
    }
    Write-Ok "Update completado."
}

# ─── Entry point ─────────────────────────────────────────────────────────────
if ($Help -or -not $Command) {
    Show-Usage
    exit 0
}

$ProjectRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path
$Clients = Get-BoltClients
if ($Clients.Count -eq 0) {
    Write-Err "No se encontró ni 'copilot' ni 'claude' en PATH. Instala al menos una CLI."
    exit 1
}

switch ($Command) {
    'list' { Invoke-ListCommand -ProjectRoot $ProjectRoot -Clients $Clients }
    'config' { Invoke-ConfigCommand -ProjectRoot $ProjectRoot -Clients $Clients -SkipVendorSync:$SkipVendorSync -Yes:$Yes }
    'add' { Invoke-AddCommand -ProjectRoot $ProjectRoot -Clients $Clients -PluginId $PluginId -SkipVendorSync:$SkipVendorSync -Yes:$Yes }
    'remove' { Invoke-RemoveCommand -ProjectRoot $ProjectRoot -Clients $Clients -PluginId $PluginId }
    'status' { Invoke-StatusCommand -ProjectRoot $ProjectRoot -Clients $Clients }
    'update' { Invoke-UpdateCommand -ProjectRoot $ProjectRoot -Clients $Clients -PluginId $PluginId -All:$All -SkipVendorSync:$SkipVendorSync -Yes:$Yes }
}
