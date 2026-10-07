#Requires -Version 7.0
<#
.SYNOPSIS
    Launches `copilot` with one --plugin-dir per plugin selected in plugins-state.yaml.

.DESCRIPTION
    Copilot CLI has no project/local install scope (unlike Claude Code's --scope project)
    and no persisted config/env var for --plugin-dir — see "Alcance por proyecto (scope)"
    in docs/bolt-plugin-distribution-proposal.md. `bolt plugin` therefore never runs
    `copilot plugin install/uninstall` for bolt-framework plugins; instead, this launcher
    resolves each plugin id from .boltf/memory/plugins-state.yaml to a local directory and
    passes it via --plugin-dir on every invocation — nothing needs to be "installed".

    Resolution order per plugin id (first match wins):
      1. plugins/<id>/            — local copy (current monorepo layout, or a plugin kept
                                     vendored via plugins/<id>/.vendor-sources.yaml).
      2. Claude Code's own cache  — if `claude plugin install <id>@bolt-framework
                                     --scope project` already ran, reuse its resolved
                                     installPath. Claude already resolved the marketplace
                                     entry's `source` (local path or remote git repo), so
                                     this works even if a plugin has been split into its
                                     own repo (Fase 3) and there is no local plugins/<id>/.

    Any arguments passed to this script are forwarded to `copilot` as-is.
#>

# No param block: any [Parameter(...)] attribute (even without [CmdletBinding()])
# makes this an advanced script and adds common parameters (-InformationAction, etc.)
# whose prefix-matching swallows short flags meant for `copilot` (e.g. `-i` is
# ambiguous with -InformationAction). Using the automatic $args array instead avoids
# advanced-parameter binding entirely, so every flag is forwarded untouched.

$ErrorActionPreference = "Stop"
$script:MarketplaceName = "bolt-framework"
$ProjectRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path

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

function Get-ClaudeCachePath {
    param([string]$PluginId)
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { return $null }
    try {
        $json = & claude plugin list --json 2>$null
        $parsed = @(($json -join "`n") | ConvertFrom-Json)
    } catch {
        return $null
    }
    $entry = $parsed | Where-Object { $_.id -eq "$PluginId@$script:MarketplaceName" -and $_.scope -eq 'project' } | Select-Object -First 1
    if ($entry -and $entry.installPath -and (Test-Path $entry.installPath)) { return $entry.installPath }
    return $null
}

function Resolve-PluginDir {
    param([string]$PluginId)
    $localPath = Join-Path $ProjectRoot "plugins\$PluginId"
    if (Test-Path $localPath) { return $localPath }
    return Get-ClaudeCachePath -PluginId $PluginId
}

if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
    Write-Host "❌ No se encontró 'copilot' en PATH." -ForegroundColor Red
    exit 1
}

$statePath = Join-Path $ProjectRoot ".boltf\memory\plugins-state.yaml"
$ids = @(Get-PluginsState -Path $statePath)
if ($ids.Count -eq 0) { $ids = @('bolt-core') }

$pluginDirArgs = @()
foreach ($id in $ids) {
    $dir = Resolve-PluginDir -PluginId $id
    if ($dir) {
        $pluginDirArgs += @('--plugin-dir', $dir)
    } else {
        Write-Host "⚠️  No se pudo resolver un directorio local para '$id' (ni plugins/$id ni caché de Claude)." -ForegroundColor Yellow
        Write-Host "    Ejecuta 'bolt plugin config' con Claude Code instalado, o restaura la copia vendorizada." -ForegroundColor Yellow
    }
}

& copilot @pluginDirArgs @args
exit $LASTEXITCODE
