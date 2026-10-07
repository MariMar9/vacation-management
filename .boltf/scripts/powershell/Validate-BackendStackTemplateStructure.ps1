param(
    [Parameter(Mandatory = $false)]
    [string]$CanonicalPath = ".boltf/scopes/backend/memory/constitution.md",

    [Parameter(Mandatory = $true)]
    [string]$TemplatePath,

    [Parameter(Mandatory = $false)]
    [switch]$ShowMatches
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Warn { param([string]$M) Write-Host "[WARN] $M" -ForegroundColor Yellow }
function Write-Err { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red }

function Get-HeadingKey {
    param([string]$Line)
    $n = $Line.Trim()
    $n = [regex]::Replace($n, '\s+', ' ')
    return $n
}

function Get-Structure {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }

    $lines = Get-Content -Path $Path -Encoding UTF8
    $items = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        if ($line -match '^##\s+Article\s+') {
            $items.Add((Get-HeadingKey $line))
            continue
        }
        if ($line -match '^###\s+Section\s+') {
            $items.Add((Get-HeadingKey $line))
            continue
        }
    }

    return $items
}

function Normalize-OptionLabel {
    param([string]$Value)

    # Remove checkbox prefix and collapse whitespace for resilient string matching.
    $n = $Value.Trim()
    $n = [regex]::Replace($n, '^\-\s*\[(x| )\]\s*', '')
    $n = [regex]::Replace($n, '\s+', ' ')
    return $n.Trim()
}

function Get-LineOptionKeys {
    param([string]$Line)

    $normalized = Normalize-OptionLabel $Line
    $keys = New-Object System.Collections.Generic.List[string]

    # Prefer bold option labels when present (canonical frequently keeps descriptions after label).
    $boldMatches = [regex]::Matches($normalized, '\*\*([^*]+)\*\*')
    if ($boldMatches.Count -gt 0) {
        foreach ($m in $boldMatches) {
            $v = $m.Groups[1].Value.Trim()
            if (-not [string]::IsNullOrWhiteSpace($v)) {
                $keys.Add($v)
            }
        }
        return $keys
    }

    # Fallback: remove trailing commentary after " - " and keep the option caption.
    $plain = $normalized
    if ($plain -match '^(.*?)\s+-\s+') {
        $plain = $Matches[1].Trim()
    }
    if (-not [string]::IsNullOrWhiteSpace($plain)) {
        $keys.Add($plain)
    }

    return $keys
}

function Get-CheckedOptionLabels {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }

    $lines = Get-Content -Path $Path -Encoding UTF8
    $checked = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        if ($line -match '^\s*\-\s*\[x\]\s+') {
            $keys = Get-LineOptionKeys -Line $line
            foreach ($k in $keys) {
                $checked.Add($k)
            }
        }
    }

    return $checked
}

function Get-CanonicalSelectableLabels {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }

    $lines = Get-Content -Path $Path -Encoding UTF8
    $labels = New-Object System.Collections.Generic.HashSet[string]

    foreach ($line in $lines) {
        if ($line -match '^\s*\-\s*\[ \]\s+') {
            $keys = Get-LineOptionKeys -Line $line
            foreach ($k in $keys) {
                [void]$labels.Add($k)
            }
        }
    }

    return $labels
}

try {
    Write-Info "Validating stack template structure against canonical backend constitution"
    Write-Info "Canonical: $CanonicalPath"
    Write-Info "Template:  $TemplatePath"

    $canonical = Get-Structure -Path $CanonicalPath
    $template = Get-Structure -Path $TemplatePath
    $templateChecked = Get-CheckedOptionLabels -Path $TemplatePath
    $canonicalSelectable = Get-CanonicalSelectableLabels -Path $CanonicalPath

    if ($canonical.Count -eq 0) {
        throw "No Article/Section headings found in canonical file"
    }
    if ($template.Count -eq 0) {
        throw "No Article/Section headings found in template file"
    }

    $max = [Math]::Max($canonical.Count, $template.Count)
    $mismatches = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $max; $i++) {
        $c = if ($i -lt $canonical.Count) { $canonical[$i] } else { '<MISSING>' }
        $t = if ($i -lt $template.Count) { $template[$i] } else { '<MISSING>' }

        if ($c -ne $t) {
            $mismatches.Add("[$i] canonical='$c' template='$t'")
        }
    }

    # Set-style checks for missing/extra identifiers.
    $canonicalSet = @{}
    foreach ($item in $canonical) { $canonicalSet[$item] = $true }
    $templateSet = @{}
    foreach ($item in $template) { $templateSet[$item] = $true }

    $missingInTemplate = @()
    foreach ($item in $canonical) {
        if (-not $templateSet.ContainsKey($item)) {
            $missingInTemplate += $item
        }
    }

    $extraInTemplate = @()
    foreach ($item in $template) {
        if (-not $canonicalSet.ContainsKey($item)) {
            $extraInTemplate += $item
        }
    }

    # Option parity check: every [x] in template should map to a selectable option [ ] in canonical.
    $optionMismatches = @()
    $allowedAliases = @{
        'Service Bus compatible broker' = @('Azure Service Bus')
    }

    foreach ($opt in $templateChecked) {
        if ($canonicalSelectable.Contains($opt)) {
            continue
        }

        $isAliasMatch = $false
        if ($allowedAliases.ContainsKey($opt)) {
            foreach ($target in $allowedAliases[$opt]) {
                if ($canonicalSelectable.Contains($target)) {
                    $isAliasMatch = $true
                    break
                }
            }
        }

        if (-not $isAliasMatch) {
            $optionMismatches += $opt
        }
    }

    if ($ShowMatches) {
        Write-Host ""
        Write-Info "Resolved structure (canonical vs template):"
        for ($i = 0; $i -lt [Math]::Min($canonical.Count, $template.Count); $i++) {
            $marker = if ($canonical[$i] -eq $template[$i]) { '==' } else { '!=' }
            Write-Host ("{0,3} {1} {2}" -f $i, $marker, $canonical[$i])
        }
    }

    Write-Host ""
    Write-Info "Summary"
    Write-Host "- Canonical headings: $($canonical.Count)"
    Write-Host "- Template headings:  $($template.Count)"
    Write-Host "- Positional mismatches: $($mismatches.Count)"
    Write-Host "- Missing in template:   $($missingInTemplate.Count)"
    Write-Host "- Extra in template:     $($extraInTemplate.Count)"
    Write-Host "- Checked option mismatches: $($optionMismatches.Count)"

    if ($mismatches.Count -eq 0 -and $missingInTemplate.Count -eq 0 -and $extraInTemplate.Count -eq 0 -and $optionMismatches.Count -eq 0) {
        Write-Ok "Template structure and checked options are consistent with canonical backend constitution"
        exit 0
    }

    if ($mismatches.Count -gt 0) {
        Write-Host ""
        Write-Err "Order/position drift detected:"
        foreach ($m in $mismatches) { Write-Host "  - $m" }
    }

    if ($missingInTemplate.Count -gt 0) {
        Write-Host ""
        Write-Err "Headings missing in template:"
        foreach ($h in $missingInTemplate) { Write-Host "  - $h" }
    }

    if ($extraInTemplate.Count -gt 0) {
        Write-Host ""
        Write-Err "Extra headings in template:"
        foreach ($h in $extraInTemplate) { Write-Host "  - $h" }
    }

    if ($optionMismatches.Count -gt 0) {
        Write-Host ""
        Write-Err "Checked options not found as selectable labels in canonical ([ ]):"
        foreach ($o in $optionMismatches) { Write-Host "  - $o" }
    }

    exit 1
}
catch {
    Write-Err $_.Exception.Message
    exit 2
}
