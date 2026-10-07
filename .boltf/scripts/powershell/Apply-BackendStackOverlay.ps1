param(
    [Parameter(Mandatory = $false)]
    [string]$CanonicalPath = ".boltf/scopes/backend/memory/constitution.md",

    [Parameter(Mandatory = $false)]
    [string]$TargetPath = ".boltf/memory/backend-constitution.md",

    [Parameter(Mandatory = $true)]
    [string]$TemplatePath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",

    [Parameter(Mandatory = $false)]
    [switch]$SkipStructureValidation,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Warn { param([string]$M) Write-Host "[WARN] $M" -ForegroundColor Yellow }
function Write-Err { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red }

function Normalize-Spaces {
    param([string]$S)
    $n = $S.Trim()
    $n = [regex]::Replace($n, '\s+', ' ')
    return $n
}

function Normalize-OptionKey {
    param([string]$Value)

    $n = $Value
    $n = [regex]::Replace($n, '[*_`]', '')
    $n = [regex]::Replace($n, '\([^)]*\)', '')
    $n = [regex]::Replace($n, '\s+-\s+.*$', '')
    $n = Normalize-Spaces $n
    return $n.Trim(':').Trim()
}

function Get-LineOptionKeys {
    param([string]$Line)

    $keys = New-Object System.Collections.Generic.List[string]
    $checkboxSegments = [regex]::Matches($Line, '\[(?:x|X| )\]\s*([^\[\]]+)')

    foreach ($segment in $checkboxSegments) {
        $k = Normalize-OptionKey $segment.Groups[1].Value
        if (-not [string]::IsNullOrWhiteSpace($k)) {
            $keys.Add($k)
        }
    }

    if ($keys.Count -eq 0 -and $Line -match '\[[xX ]\]') {
        $fallback = Normalize-OptionKey ([regex]::Replace($Line.Trim(), '^\-\s*\[[xX ]\]\s*', ''))
        if (-not [string]::IsNullOrWhiteSpace($fallback)) {
            $keys.Add($fallback)
        }
    }

    return $keys
}

function Resolve-CanonicalKey {
    param([string]$TemplateKey)

    $aliases = @{
        'Service Bus compatible broker' = 'Azure Service Bus'
    }

    if ($aliases.ContainsKey($TemplateKey)) {
        return $aliases[$TemplateKey]
    }

    return $TemplateKey
}

function Normalize-LineKey {
    param([string]$Line)

    $n = $Line

    # Normalize checkboxes to neutral marker for matching.
    $n = [regex]::Replace($n, '\[[xX ]\]', '[ ]')

    # Normalize thresholds/placeholders to allow template defaults to overlay placeholders.
    $n = [regex]::Replace($n, '\\_\\_+%', '<PERCENT>')
    $n = [regex]::Replace($n, '___%', '<PERCENT>')
    $n = [regex]::Replace($n, '\b\d+%\b', '<PERCENT>')

    # Normalize spacing.
    $n = Normalize-Spaces $n
    return $n
}

function Get-Structure {
    param([string]$Path)
    $lines = Get-Content -Path $Path -Encoding UTF8
    $items = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        if ($line -match '^##\s+Article\s+' -or $line -match '^###\s+Section\s+') {
            $items.Add((Normalize-Spaces $line))
        }
    }
    return $items
}

function Validate-Structure {
    param(
        [string]$Canonical,
        [string]$Template
    )

    $canonicalItems = Get-Structure -Path $Canonical
    $templateItems = Get-Structure -Path $Template

    if ($canonicalItems.Count -ne $templateItems.Count) {
        return $false
    }

    for ($i = 0; $i -lt $canonicalItems.Count; $i++) {
        if ($canonicalItems[$i] -ne $templateItems[$i]) {
            return $false
        }
    }

    return $true
}

try {
    if (-not (Test-Path $TargetPath)) {
        throw "Target constitution not found: $TargetPath"
    }
    if (-not (Test-Path $TemplatePath)) {
        throw "Template file not found: $TemplatePath"
    }
    if (-not (Test-Path $CanonicalPath)) {
        throw "Canonical constitution not found: $CanonicalPath"
    }

    if (-not $SkipStructureValidation) {
        Write-Info "Validating template structure before applying overlay"
        $valid = Validate-Structure -Canonical $CanonicalPath -Template $TemplatePath
        if (-not $valid) {
            throw "Template structure mismatch. Run Validate-BackendStackTemplateStructure.ps1 to inspect drift."
        }
        Write-Ok "Structure validation passed"
    }

    $targetLines = Get-Content -Path $TargetPath -Encoding UTF8
    $templateLines = Get-Content -Path $TemplatePath -Encoding UTF8

    $applied = 0
    $ambiguous = 0
    $notFound = 0

    # Build index of option labels in target for resilient matching.
    $index = @{}
    for ($i = 0; $i -lt $targetLines.Count; $i++) {
        $line = $targetLines[$i]
        if ($line -notmatch '\[[xX ]\]') {
            continue
        }

        $keys = Get-LineOptionKeys -Line $line
        foreach ($rawKey in $keys) {
            $k = Resolve-CanonicalKey -TemplateKey $rawKey
            if (-not $index.ContainsKey($k)) {
                $index[$k] = New-Object System.Collections.Generic.List[int]
            }
            $index[$k].Add($i)
        }
    }

    for ($t = 0; $t -lt $templateLines.Count; $t++) {
        $templateLine = $templateLines[$t]

        if ($templateLine -notmatch '\[[xX ]\]') {
            continue
        }

        $resolvedIndex = $null
        $candidateKeys = Get-LineOptionKeys -Line $templateLine

        foreach ($candidateRaw in $candidateKeys) {
            $candidate = Resolve-CanonicalKey -TemplateKey $candidateRaw
            if (-not $index.ContainsKey($candidate)) {
                continue
            }

            $matches = $index[$candidate]
            if ($matches.Count -eq 1) {
                $resolvedIndex = $matches[0]
                break
            }
        }

        if ($null -eq $resolvedIndex) {
            $matchCount = 0
            foreach ($candidateRaw in $candidateKeys) {
                $candidate = Resolve-CanonicalKey -TemplateKey $candidateRaw
                if ($index.ContainsKey($candidate)) {
                    $matchCount += $index[$candidate].Count
                }
            }

            if ($matchCount -eq 0) {
                $notFound++
            }
            else {
                $ambiguous++
            }
            continue
        }

        $targetIndex = $resolvedIndex
        if ($targetLines[$targetIndex] -ne $templateLine) {
            $targetLines[$targetIndex] = $templateLine
            $applied++
        }
    }

    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $OutputPath = $TargetPath
    }

    Write-Host ""
    Write-Info "Overlay summary"
    Write-Host "- Applied line updates: $applied"
    Write-Host "- Not found matches:    $notFound"
    Write-Host "- Ambiguous matches:    $ambiguous"
    Write-Host "- Output path:          $OutputPath"

    if ($DryRun) {
        Write-Warn "Dry run enabled: no file was written"
        exit 0
    }

    $outDir = Split-Path -Path $OutputPath -Parent
    if (-not [string]::IsNullOrWhiteSpace($outDir) -and -not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    Set-Content -Path $OutputPath -Value $targetLines -Encoding UTF8
    Write-Ok "Overlay applied successfully"
    exit 0
}
catch {
    Write-Err $_.Exception.Message
    exit 2
}
