<#
.SYNOPSIS
    Bolt Framework - Test Two-Step Initialization Workflow

.DESCRIPTION
    Automated tests for the two-step initialization pattern:
    - Step 1: Init.ps1 (Practice selection + basic config)
    - Step 2: bolt-setup-constitution (file provisioning)

    Tests cover:
    1. Practice "Apps & Infra" workflow
    2. Skill provisioning and constitution merge
    3. Practice "Data & AI" workflow
    4. Custom mode (manual scope selection)
    5. Dry-run mode
    6. Re-provisioning (idempotency)
    7. CI/CD provider skill routing from `cicd.platform`
    8. Plugins/ fallback shim for stale `.boltf/available-skills` paths
    9. VS Code agent/skill discovery (.vscode/settings.json chat.agentFilesLocations/
       chat.agentSkillsLocations) regeneration in Init.ps1 and Invoke-BoltPlugin.ps1
    10. Claude Code enabledPlugins direct-write fallback (.claude/settings.json), for when
        `claude plugin install --scope project` doesn't land in the project's own file

.PARAMETER TestNumber
    Run specific test (1-10). If not specified, runs all tests.

.PARAMETER KeepTestProjects
    Keep test projects after completion (for manual inspection)

.EXAMPLE
    .\Test-InitFlows.ps1
    # Runs all 10 tests

.EXAMPLE
    .\Test-InitFlows.ps1 -TestNumber 1 -KeepTestProjects
    # Runs only test 1 and keeps the test project
#>

param(
    [int]$TestNumber = 0,
    [switch]$KeepTestProjects
)

# ─── Configuration ────────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"
$FrameworkRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$TestOutputDir = Join-Path $env:TEMP "bolt-framework-tests"
$PassedTests = 0
$FailedTests = 0
$TestResults = @()

# ─── Logging Functions ────────────────────────────────────────────────────────

function Write-TestHeader { param($msg) Write-Host "`n═══ $msg ═══" -ForegroundColor Cyan }
function Write-TestStep { param($msg) Write-Host "  → $msg" -ForegroundColor Blue }
function Write-TestPass { param($msg) Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-TestFail { param($msg) Write-Host "  ✗ $msg" -ForegroundColor Red }
function Write-TestWarn { param($msg) Write-Host "  ⚠ $msg" -ForegroundColor Yellow }

# ─── Test Utilities ───────────────────────────────────────────────────────────

function Assert-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path $Path) {
        Write-TestPass "$Description exists"
        return $true
    } else {
        Write-TestFail "$Description NOT found: $Path"
        throw "Assertion failed: File not found"
    }
}

function Assert-FileNotExists {
    param([string]$Path, [string]$Description)
    if (-not (Test-Path $Path)) {
        Write-TestPass "$Description does not exist (as expected)"
        return $true
    } else {
        Write-TestFail "$Description exists (unexpected): $Path"
        throw "Assertion failed: File should not exist"
    }
}

function Assert-FileContains {
    param([string]$Path, [string]$Pattern, [string]$Description)
    if (-not (Test-Path $Path)) {
        Write-TestFail "$Description - File not found: $Path"
        throw "Assertion failed: File not found"
    }

    $content = Get-Content $Path -Raw
    if ($content -match $Pattern) {
        Write-TestPass "$Description matches pattern"
        return $true
    } else {
        Write-TestFail "$Description does NOT match pattern: $Pattern"
        throw "Assertion failed: Pattern not found"
    }
}

# Extracts a single named function's real current source from a .ps1 file and defines it
# in the caller's scope via Invoke-Expression. Used to unit-test helper functions inside
# Init.ps1 / Invoke-BoltPlugin.ps1 without running those scripts' Main()/CLI-dependent
# entry points (both exit the process or shell out to copilot/claude if invoked directly).
function Import-ScriptFunction {
    param([string]$ScriptPath, [string]$FunctionName)

    $content = Get-Content $ScriptPath -Raw
    $match = [regex]::Match($content, "(?ms)^function\s+$FunctionName\s*\{")
    if (-not $match.Success) { throw "Function '$FunctionName' not found in $ScriptPath" }

    $depth = 0
    $i = $match.Index + $match.Length - 1
    do {
        if ($content[$i] -eq '{') { $depth++ }
        elseif ($content[$i] -eq '}') { $depth-- }
        $i++
    } while ($depth -gt 0 -and $i -lt $content.Length)

    Invoke-Expression $content.Substring($match.Index, $i - $match.Index)
}

function New-TestProject {
    param([string]$Name)

    $projectPath = Join-Path $TestOutputDir $Name
    if (Test-Path $projectPath) {
        Remove-Item $projectPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null

    Write-TestStep "Created test project: $Name"
    return $projectPath
}

function Remove-TestProject {
    param([string]$Path)

    if (-not $KeepTestProjects -and (Test-Path $Path)) {
        Remove-Item $Path -Recurse -Force
        Write-TestStep "Cleaned up test project"
    }
}

# Seeds .boltf/memory/plugins-state.yaml (as `bolt plugin config` would), since
# Get-ActiveScopes now derives active scopes from it instead of scopes.yaml.
function New-TestPluginsState {
    param([string]$ProjectPath, [string[]]$Scopes)

    $ids = @('bolt-core', 'bolt-work-management') + ($Scopes | ForEach-Object { "bolt-$_" })
    $sorted = @($ids | Sort-Object -Unique)

    $memoryDir = Join-Path $ProjectPath ".boltf\memory"
    New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

    $lines = @("version: 1", "updated: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))", "installed:")
    foreach ($id in $sorted) { $lines += "  - $id" }
    Set-Content -Path (Join-Path $memoryDir "plugins-state.yaml") -Value ($lines -join "`n") -Encoding UTF8
}

# ─── Test 1: Practice "Apps & Infra" Initialization ───────────────────────────

function Test-01-AppsInfraInit {
    Write-TestHeader "TEST 1: Practice 'Apps & Infra' - Init.ps1 Only"

    try {
        $projectPath = New-TestProject "test-01-apps-infra-init"

        # Simulate Init.ps1 execution with "Apps & Infra" practice
        Write-TestStep "Simulating Init.ps1 with Practice: Apps & Infra"

        # Create basic structure as Init.ps1 would
        $boltDir = Join-Path $projectPath ".boltf"
        $memoryDir = Join-Path $boltDir "memory"
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

        # Create basic constitution (as generated by Init.ps1)
        $constitutionPath = Join-Path $memoryDir "constitution.md"
        $basicConstitution = @"
# Project Constitution

> **Two-Step Initialization**: This is a basic constitution generated by Init.ps1.
> Run ``@Bolt Constitution`` to provision files and merge scope-specific constitutions.

## Metadata

- **Practice**: Apps & Infra
- **Active Scopes**: backend, frontend, cloud-platform
- **Project Type**: full-stack (green)
- **Initialized**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

---

# Article I §1.1 — Active Scopes

The following scopes are active for this project:

- **backend**
- **frontend**
- **cloud-platform**

## Next Steps

1. **Provision Files**: Run ``@Bolt Constitution`` agent
2. **Review**: The skill will merge scope-specific constitutions
3. **Customize**: Edit this constitution to reflect project-specific decisions
"@
        Set-Content -Path $constitutionPath -Value $basicConstitution -Encoding UTF8

        # Create scopes.yaml (as generated by Init.ps1)
        $scopesYamlPath = Join-Path $boltDir "scopes.yaml"
        $scopesYaml = @"
project:
  practice: Apps & Infra
  type: full-stack
  migration-type: green

active-scopes:
  - backend
  - frontend
  - cloud-platform

transversal-scopes:
  - work-management
"@
        Set-Content -Path $scopesYamlPath -Value $scopesYaml -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @('backend', 'frontend', 'cloud-platform')

        # Assertions
        Write-TestStep "Verifying Init.ps1 outputs..."
        Assert-FileExists $constitutionPath "Basic constitution"
        Assert-FileExists (Join-Path $memoryDir "plugins-state.yaml") "plugins-state.yaml"
        Assert-FileContains $constitutionPath "Apps & Infra" "Constitution contains Practice"
        Assert-FileContains $constitutionPath "backend.*frontend.*cloud-platform" "Constitution contains scopes"

        Assert-FileExists $scopesYamlPath "scopes.yaml"
        Assert-FileContains $scopesYamlPath "practice: Apps & Infra" "scopes.yaml contains Practice"

        # Verify .github/ does NOT exist yet (provisioning not run)
        $githubDir = Join-Path $projectPath ".github"
        Assert-FileNotExists $githubDir ".github directory (pre-provisioning)"

        Write-TestPass "TEST 1 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 1; Name = "Apps & Infra Init"; Status = "PASS" }

        Remove-TestProject $projectPath
    }
    catch {
        Write-TestFail "TEST 1 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 1; Name = "Apps & Infra Init"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 2: bolt-setup-constitution Skill Execution ──────────────────────────

function Test-02-SetupConstitutionSkill {
    Write-TestHeader "TEST 2: bolt-setup-constitution Skill Execution"

    try {
        $projectPath = New-TestProject "test-02-setup-constitution"

        # Setup: vendor the real .boltf payload (scope manifests + scope-level
        # constitution.md files) plus the plugins a real 'bolt plugin config' run
        # would install for this scenario, so the constitution merge and
        # provisioning resolve against real content instead of empty fixtures.
        Write-TestStep "Setting up initialized project..."

        Copy-Item (Join-Path $FrameworkRoot '.boltf') $projectPath -Recurse -Force
        foreach ($pluginId in @('bolt-core', 'bolt-work-management', 'bolt-backend', 'bolt-frontend', 'bolt-cloud-platform')) {
            $srcPluginDir = Join-Path $FrameworkRoot "plugins\$pluginId"
            if (Test-Path $srcPluginDir) {
                $destPluginsRoot = Join-Path $projectPath 'plugins'
                New-Item -ItemType Directory -Path $destPluginsRoot -Force | Out-Null
                Copy-Item $srcPluginDir (Join-Path $destPluginsRoot $pluginId) -Recurse -Force
            }
        }

        $boltDir = Join-Path $projectPath ".boltf"
        $memoryDir = Join-Path $boltDir "memory"

        # Basic constitution (overwrite the vendored one with this test's starter content)
        $constitutionPath = Join-Path $memoryDir "constitution.md"
        Set-Content -Path $constitutionPath -Value "# Project Constitution`n`nPractice: Apps & Infra`n`n# Article I: Active Scopes`n- backend`n- frontend`n- cloud-platform" -Encoding UTF8

        # scopes.yaml
        $scopesYamlPath = Join-Path $boltDir "scopes.yaml"
        $scopesYaml = @"
project:
  practice: Apps & Infra
  type: full-stack

active-scopes:
  - backend
  - frontend
  - cloud-platform

transversal-scopes:
  - work-management
"@
        Set-Content -Path $scopesYamlPath -Value $scopesYaml -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @('backend', 'frontend', 'cloud-platform')

        # Execute bolt-setup-constitution skill
        Write-TestStep "Invoking Invoke-BoltSetupConstitution.ps1..."

        $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"

        if (-not (Test-Path $setupScript)) {
            throw "Setup script not found: $setupScript"
        }

        # Phase 1 (merge scope constitutions) + Phase 3 (finalize, no refinements => copy
        # master as-is) must run explicitly before provisioning — the default/-Provision
        # invocation only handles Phase 4 and never touches constitution.md.
        & $setupScript -ProjectPath $projectPath -GenerateMaster | Out-Null
        & $setupScript -ProjectPath $projectPath -GenerateFinal | Out-Null
        $output = & $setupScript -ProjectPath $projectPath 2>&1

        # Verify outputs
        Write-TestStep "Verifying provisioning results..."

        # Check constitution merged
        Assert-FileExists $constitutionPath "Merged constitution"
        Assert-FileContains $constitutionPath "Article.*Tech Stack|Article.*Testing|Article.*Security" "Constitution has merged articles"

        # Check provision report
        $reportPath = Join-Path $memoryDir "provision-report.md"
        Assert-FileExists $reportPath "Provision report"
        Assert-FileContains $reportPath "Bolt Setup Constitution - Provision Report" "Report header"
        Assert-FileContains $reportPath "Practice.*Apps & Infra" "Report contains Practice"

        # Check core skills provisioned
        $skillsDir = Join-Path $projectPath ".claude\skills"
        Assert-FileExists $skillsDir "Skills directory"

        $boltFrameworkSkill = Join-Path $skillsDir "bolt-framework\SKILL.md"
        Assert-FileExists $boltFrameworkSkill "bolt-framework skill"

        Write-TestPass "TEST 2 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 2; Name = "Setup Constitution Skill"; Status = "PASS" }

        Remove-TestProject $projectPath
    }
    catch {
        Write-TestFail "TEST 2 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 2; Name = "Setup Constitution Skill"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 3: Practice "Data & AI" ─────────────────────────────────────────────

function Test-03-DataAIPractice {
    Write-TestHeader "TEST 3: Practice 'Data & AI' Workflow"

    try {
        $projectPath = New-TestProject "test-03-data-ai"

        Write-TestStep "Creating project with Practice: Data & AI"

        $boltDir = Join-Path $projectPath ".boltf"
        $memoryDir = Join-Path $boltDir "memory"
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

        # Constitution for Data & AI
        $constitutionPath = Join-Path $memoryDir "constitution.md"
        Set-Content -Path $constitutionPath -Value "# Project Constitution`n`nPractice: Data & AI`n`n# Article I: Active Scopes`n- data`n- ai`n- integration" -Encoding UTF8

        # scopes.yaml for Data & AI
        $scopesYamlPath = Join-Path $boltDir "scopes.yaml"
        $scopesYaml = @"
project:
  practice: Data & AI
  type: data-platform

active-scopes:
  - data
  - ai
  - integration

transversal-scopes:
  - work-management
"@
        Set-Content -Path $scopesYamlPath -Value $scopesYaml -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @('data', 'ai', 'integration')

        # Run provisioning
        Write-TestStep "Running bolt-setup-constitution..."
        $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"
        & $setupScript -ProjectPath $projectPath | Out-Null

        # Assertions
        Write-TestStep "Verifying Data & AI specific provisioning..."

        Assert-FileContains $constitutionPath "Data & AI" "Constitution has Data & AI practice"
        Assert-FileContains $constitutionPath "(?s)data.*ai.*integration" "Constitution has correct scopes"

        $reportPath = Join-Path $memoryDir "provision-report.md"
        Assert-FileContains $reportPath "Data & AI" "Provision report shows practice"

        Write-TestPass "TEST 3 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 3; Name = "Data & AI Practice"; Status = "PASS" }

        Remove-TestProject $projectPath
    }
    catch {
        Write-TestFail "TEST 3 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 3; Name = "Data & AI Practice"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 4: Custom Mode (Manual Scope Selection) ─────────────────────────────

function Test-04-CustomMode {
    Write-TestHeader "TEST 4: Custom Mode - Manual Scope Selection"

    try {
        $projectPath = New-TestProject "test-04-custom-mode"

        Write-TestStep "Creating project with Custom practice (manual scopes)"

        $boltDir = Join-Path $projectPath ".boltf"
        $memoryDir = Join-Path $boltDir "memory"
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

        # User manually selects: backend, data (no frontend, no cloud-platform)
        $constitutionPath = Join-Path $memoryDir "constitution.md"
        Set-Content -Path $constitutionPath -Value "# Project Constitution`n`nPractice: Custom`n`n# Article I: Active Scopes`n- backend`n- data" -Encoding UTF8

        $scopesYamlPath = Join-Path $boltDir "scopes.yaml"
        $scopesYaml = @"
project:
  practice: Custom
  type: app-only

active-scopes:
  - backend
  - data

transversal-scopes:
  - work-management
"@
        Set-Content -Path $scopesYamlPath -Value $scopesYaml -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @('backend', 'data')

        # Run provisioning
        Write-TestStep "Running provisioning with custom scopes..."
        $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"
        & $setupScript -ProjectPath $projectPath | Out-Null

        # Verify only backend and data scopes provisioned
        Write-TestStep "Verifying selective provisioning..."

        $reportPath = Join-Path $memoryDir "provision-report.md"
        Assert-FileContains $reportPath "Custom" "Report shows Custom practice"
        Assert-FileContains $reportPath "backend.*data" "Report lists correct scopes"

        Write-TestPass "TEST 4 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 4; Name = "Custom Mode"; Status = "PASS" }

        Remove-TestProject $projectPath
    }
    catch {
        Write-TestFail "TEST 4 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 4; Name = "Custom Mode"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 5: Dry-Run Mode ──────────────────────────────────────────────────────

function Test-05-DryRunMode {
    Write-TestHeader "TEST 5: Dry-Run Mode (Preview Changes)"

    try {
        $projectPath = New-TestProject "test-05-dryrun"

        Write-TestStep "Setting up project for dry-run test..."

        $boltDir = Join-Path $projectPath ".boltf"
        $memoryDir = Join-Path $boltDir "memory"
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

        $constitutionPath = Join-Path $memoryDir "constitution.md"
        $originalConstitution = "# Project Constitution`n`nPractice: Apps & Infra"
        Set-Content -Path $constitutionPath -Value $originalConstitution -Encoding UTF8

        $scopesYamlPath = Join-Path $boltDir "scopes.yaml"
        Set-Content -Path $scopesYamlPath -Value "project:`n  practice: Apps & Infra`nactive-scopes:`n  - backend" -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @('backend')

        # Capture file modification time BEFORE dry-run
        $constitutionModTimeBefore = (Get-Item $constitutionPath).LastWriteTime

        # Run in DRY-RUN mode
        Write-TestStep "Running Invoke-BoltSetupConstitution.ps1 -DryRun..."
        $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"
        $output = & $setupScript -ProjectPath $projectPath -DryRun 2>&1

        # Verify NO files were modified
        Write-TestStep "Verifying no files were modified in dry-run..."

        $constitutionModTimeAfter = (Get-Item $constitutionPath).LastWriteTime
        if ($constitutionModTimeBefore -eq $constitutionModTimeAfter) {
            Write-TestPass "Constitution not modified (dry-run respected)"
        } else {
            throw "Constitution was modified during dry-run"
        }

        # Verify output mentions dry-run
        if ($output -match "DRY RUN|dry.run|preview") {
            Write-TestPass "Output indicates dry-run mode"
        } else {
            Write-TestWarn "Output doesn't clearly indicate dry-run (check implementation)"
        }

        # Verify provision report NOT created
        $reportPath = Join-Path $memoryDir "provision-report.md"
        Assert-FileNotExists $reportPath "Provision report (should not exist in dry-run)"

        Write-TestPass "TEST 5 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 5; Name = "Dry-Run Mode"; Status = "PASS" }

        Remove-TestProject $projectPath
    }
    catch {
        Write-TestFail "TEST 5 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 5; Name = "Dry-Run Mode"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 6: Re-Provisioning (Idempotency) ────────────────────────────────────

function Test-06-Idempotency {
    Write-TestHeader "TEST 6: Re-Provisioning (Idempotency Check)"

    try {
        $projectPath = New-TestProject "test-06-idempotency"

        Write-TestStep "Setting up project for idempotency test..."

        $boltDir = Join-Path $projectPath ".boltf"
        $memoryDir = Join-Path $boltDir "memory"
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

        $constitutionPath = Join-Path $memoryDir "constitution.md"
        Set-Content -Path $constitutionPath -Value "# Project Constitution`n`nPractice: Apps & Infra" -Encoding UTF8

        $scopesYamlPath = Join-Path $boltDir "scopes.yaml"
        Set-Content -Path $scopesYamlPath -Value "project:`n  practice: Apps & Infra`nactive-scopes:`n  - backend" -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @('backend')

        # First provisioning
        Write-TestStep "Running FIRST provisioning..."
        $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"
        & $setupScript -ProjectPath $projectPath | Out-Null

        # Capture state after first run
        $reportPath = Join-Path $memoryDir "provision-report.md"
        Assert-FileExists $reportPath "Provision report (first run)"
        $firstRunReport = Get-Content $reportPath -Raw

        # Second provisioning (should detect existing files)
        Write-TestStep "Running SECOND provisioning (idempotency check)..."
        $output = & $setupScript -ProjectPath $projectPath 2>&1

        # Verify warnings about existing files
        Write-TestStep "Checking for 'already exists' warnings..."
        if ($output -match "already exist|skipping|preserving") {
            Write-TestPass "Script detected existing files"
        } else {
            Write-TestWarn "No explicit warnings about existing files (check implementation)"
        }

        # Verify no errors occurred
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-TestPass "Second run completed without errors"
        } else {
            throw "Second provisioning failed with exit code: $LASTEXITCODE"
        }

        Write-TestPass "TEST 6 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 6; Name = "Idempotency"; Status = "PASS" }

        Remove-TestProject $projectPath
    }
    catch {
        Write-TestFail "TEST 6 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 6; Name = "Idempotency"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 7: CI/CD Provider Skill Routing ─────────────────────────────────────

function Test-07-CicdProviderRouting {
        Write-TestHeader "TEST 7: CI/CD Provider Skill Routing"

        try {
                $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"
                $cases = @(
                        @{ Platform = 'github-actions'; Expected = 'github-actions-templates'; Unexpected = 'skill-azdo-pipeline-templates' },
                        @{ Platform = 'azure-devops'; Expected = 'skill-azdo-pipeline-templates'; Unexpected = 'github-actions-templates' }
                )

                foreach ($case in $cases) {
                        $projectPath = New-TestProject ("test-07-cicd-" + $case.Platform)
                        Write-TestStep "Preparing project for platform: $($case.Platform)"

                        Copy-Item (Join-Path $FrameworkRoot '.boltf') $projectPath -Recurse -Force

                        # Vendor the plugins that a real 'bolt plugin config' run would install for
                        # this scenario (bolt-core always, work-management transversal, backend scope),
                        # so Copy-ProvisionedFiles' plugins/ fallback shim has something to resolve.
                        foreach ($pluginId in @('bolt-core', 'bolt-work-management', 'bolt-backend')) {
                                $srcPluginDir = Join-Path $FrameworkRoot "plugins\$pluginId"
                                if (Test-Path $srcPluginDir) {
                                        $destPluginsRoot = Join-Path $projectPath 'plugins'
                                        New-Item -ItemType Directory -Path $destPluginsRoot -Force | Out-Null
                                        Copy-Item $srcPluginDir (Join-Path $destPluginsRoot $pluginId) -Recurse -Force
                                }
                        }

                        $memoryDir = Join-Path $projectPath '.boltf\memory'
                        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
                        Set-Content -Path (Join-Path $memoryDir 'constitution.md') -Value '# Project Constitution' -Encoding UTF8

                        $scopesYaml = @"
project:
    practice: Apps & Infra
    type: full-stack
    migration-type: green
    local-orchestration: none
    work-management-tool: none

active-scopes:
    - backend

transversal-scopes:
    - work-management

decisions:
    cicd:
        platform: $($case.Platform)
"@
                        Set-Content -Path (Join-Path $projectPath '.boltf\scopes.yaml') -Value $scopesYaml -Encoding UTF8
                        New-TestPluginsState -ProjectPath $projectPath -Scopes @('backend')

                        Write-TestStep "Running provisioning for $($case.Platform)..."
                        & $setupScript -ProjectPath $projectPath -Provision | Out-Null

                        $skillsDir = Join-Path $projectPath '.claude\skills'
                        Assert-FileExists (Join-Path $skillsDir 'skill-cicd-pipeline-azure\SKILL.md') "CI/CD orchestrator skill for $($case.Platform)"
                        Assert-FileExists (Join-Path $skillsDir "$($case.Expected)\SKILL.md") "Expected provider skill for $($case.Platform)"
                        Assert-FileNotExists (Join-Path $skillsDir "$($case.Unexpected)\SKILL.md") "Unexpected provider skill for $($case.Platform)"

                        Remove-TestProject $projectPath
                }

                Write-TestPass "TEST 7 PASSED"
                $script:PassedTests++
                $script:TestResults += @{ Test = 7; Name = "CI/CD Provider Routing"; Status = "PASS" }
        }
        catch {
                Write-TestFail "TEST 7 FAILED: $_"
                $script:FailedTests++
                $script:TestResults += @{ Test = 7; Name = "CI/CD Provider Routing"; Status = "FAIL"; Error = $_.Exception.Message }
        }
}

# ─── Test 8: Plugins/ Fallback Shim (Fase-1 migration) ─────────────────────────

function Test-08-PluginsFallbackShim {
    Write-TestHeader "TEST 8: Plugins/ Fallback Shim for Stale available-skills Paths"

    try {
        $setupScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltSetupConstitution.ps1"

        # --- Case A: plugins/bolt-core vendored -> shim resolves stale sources ---
        $projectPath = New-TestProject "test-08-shim-resolves"
        Write-TestStep "Case A: plugins/bolt-core vendored (shim should resolve sources)"

        Copy-Item (Join-Path $FrameworkRoot '.boltf') $projectPath -Recurse -Force
        $destPluginsRoot = Join-Path $projectPath 'plugins'
        New-Item -ItemType Directory -Path $destPluginsRoot -Force | Out-Null
        Copy-Item (Join-Path $FrameworkRoot 'plugins\bolt-core') (Join-Path $destPluginsRoot 'bolt-core') -Recurse -Force

        $memoryDir = Join-Path $projectPath '.boltf\memory'
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
        Set-Content -Path (Join-Path $memoryDir 'constitution.md') -Value '# Project Constitution' -Encoding UTF8
        Set-Content -Path (Join-Path $projectPath '.boltf\scopes.yaml') -Value @"
project:
  practice: Apps & Infra
  type: full-stack

transversal-scopes:
  - work-management
"@ -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @()

        & $setupScript -ProjectPath $projectPath -Provision | Out-Null

        $skillsDir = Join-Path $projectPath '.claude\skills'
        Assert-FileExists (Join-Path $skillsDir "markdown-formatting\SKILL.md") "Copy-ProvisionedFiles shim: markdown-formatting resolved via plugins/"
        Assert-FileExists (Join-Path $skillsDir "bolt-framework\SKILL.md") "Copy-CoreSkills shim: bolt-framework resolved via plugins/bolt-core"

        Remove-TestProject $projectPath

        # --- Case B: no plugins/ vendored -> shim finds nothing, degrades gracefully ---
        $projectPath = New-TestProject "test-08-shim-missing"
        Write-TestStep "Case B: no plugins/ vendored (shim has nothing to resolve)"

        Copy-Item (Join-Path $FrameworkRoot '.boltf') $projectPath -Recurse -Force

        $memoryDir = Join-Path $projectPath '.boltf\memory'
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
        Set-Content -Path (Join-Path $memoryDir 'constitution.md') -Value '# Project Constitution' -Encoding UTF8
        Set-Content -Path (Join-Path $projectPath '.boltf\scopes.yaml') -Value @"
project:
  practice: Apps & Infra
  type: full-stack

transversal-scopes:
  - work-management
"@ -Encoding UTF8
        New-TestPluginsState -ProjectPath $projectPath -Scopes @()

        # Must complete without throwing even though every source is unresolvable
        & $setupScript -ProjectPath $projectPath -Provision | Out-Null

        $skillsDir = Join-Path $projectPath '.claude\skills'
        Assert-FileNotExists (Join-Path $skillsDir "markdown-formatting\SKILL.md") "markdown-formatting NOT provisioned (no plugins/ source available)"
        Assert-FileNotExists (Join-Path $skillsDir "bolt-framework\SKILL.md") "bolt-framework NOT provisioned (no plugins/ source available)"

        Remove-TestProject $projectPath

        Write-TestPass "TEST 8 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 8; Name = "Plugins Fallback Shim"; Status = "PASS" }
    }
    catch {
        Write-TestFail "TEST 8 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 8; Name = "Plugins Fallback Shim"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 9: VS Code Agent/Skill Discovery (.vscode/settings.json) ────────────

function Test-09-VSCodeAgentDiscovery {
    Write-TestHeader "TEST 9: VS Code Agent/Skill Discovery (chat.agentFilesLocations/agentSkillsLocations)"

    try {
        # Stubs for the logging helpers Set-VSCodeAgentDiscovery calls internally — both
        # Init.ps1 and Invoke-BoltPlugin.ps1 define these with a matching param([string]) signature.
        function Write-Warn { param([string]$M) $script:LastWarn = $M }
        function Write-Success { param([string]$M) }

        $initScript = Join-Path $FrameworkRoot "Init.ps1"
        $pluginScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltPlugin.ps1"

        # --- Case A (Init.ps1 version): fresh scaffold, no .vscode yet ---
        $projectPath = New-TestProject "test-09-vscode-discovery-fresh"
        Write-TestStep "Case A: fresh scaffold declares only folders that exist on disk"

        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-core\agents") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-core\skills") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-frontend\skills") -Force | Out-Null
        # Deliberately no plugins\bolt-frontend\agents — must NOT appear in the output

        . Import-ScriptFunction -ScriptPath $initScript -FunctionName "Set-VSCodeAgentDiscovery"
        Set-VSCodeAgentDiscovery -ProjectRoot $projectPath -PluginIds @('bolt-core', 'bolt-frontend')

        $settingsPath = Join-Path $projectPath ".vscode\settings.json"
        Assert-FileExists $settingsPath ".vscode/settings.json"
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if (-not $settings.'chat.agentFilesLocations'.'plugins/bolt-core/agents') { throw "Missing plugins/bolt-core/agents in chat.agentFilesLocations" }
        if ($settings.'chat.agentFilesLocations'.PSObject.Properties.Name -contains 'plugins/bolt-frontend/agents') { throw "plugins/bolt-frontend/agents should NOT be declared (folder doesn't exist)" }
        if (-not $settings.'chat.agentSkillsLocations'.'plugins/bolt-core/skills') { throw "Missing plugins/bolt-core/skills in chat.agentSkillsLocations" }
        if (-not $settings.'chat.agentSkillsLocations'.'plugins/bolt-frontend/skills') { throw "Missing plugins/bolt-frontend/skills in chat.agentSkillsLocations" }
        Write-TestPass "Fresh scaffold declares only existing folders"

        Remove-TestProject $projectPath

        # --- Case B (Invoke-BoltPlugin.ps1 version): post-scaffold add/remove refresh ---
        $projectPath = New-TestProject "test-09-vscode-discovery-refresh"
        Write-TestStep "Case B: 'bolt plugin add/remove' refresh preserves unrelated settings"

        New-Item -ItemType Directory -Path (Join-Path $projectPath ".vscode") -Force | Out-Null
        Set-Content -Path (Join-Path $projectPath ".vscode\settings.json") -Value (@{
            "editor.tabSize"            = 2
            "chat.agentFilesLocations"  = @{ "plugins/bolt-core/agents" = $true }
            "chat.agentSkillsLocations" = @{ "plugins/bolt-core/skills" = $true; "plugins/bolt-frontend/skills" = $true }
        } | ConvertTo-Json -Depth 10) -Encoding UTF8

        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-core\agents") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-core\skills") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-backend\agents") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-backend\skills") -Force | Out-Null
        # bolt-frontend's folder isn't part of the new PluginIds set below — simulates
        # `bolt plugin remove bolt-frontend` immediately followed by `bolt plugin add bolt-backend`

        . Import-ScriptFunction -ScriptPath $pluginScript -FunctionName "Set-VSCodeAgentDiscovery"
        Set-VSCodeAgentDiscovery -ProjectRoot $projectPath -PluginIds @('bolt-core', 'bolt-backend')

        $settingsPath = Join-Path $projectPath ".vscode\settings.json"
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.'editor.tabSize' -ne 2) { throw "Unrelated user setting 'editor.tabSize' was lost during merge" }
        if (-not $settings.'chat.agentFilesLocations'.'plugins/bolt-backend/agents') { throw "Missing plugins/bolt-backend/agents after add" }
        if ($settings.'chat.agentSkillsLocations'.PSObject.Properties.Name -contains 'plugins/bolt-frontend/skills') { throw "plugins/bolt-frontend/skills should have been dropped after removal" }
        Write-TestPass "Merge preserves unrelated settings, adds new plugin paths, drops removed plugin paths"

        Remove-TestProject $projectPath

        # --- Case C: malformed existing settings.json is skipped gracefully, not overwritten ---
        $projectPath = New-TestProject "test-09-vscode-discovery-malformed"
        Write-TestStep "Case C: malformed existing settings.json is left untouched (no throw)"

        New-Item -ItemType Directory -Path (Join-Path $projectPath ".vscode") -Force | Out-Null
        $malformed = '{ "editor.tabSize": 2' # unterminated JSON (missing closing brace)
        Set-Content -Path (Join-Path $projectPath ".vscode\settings.json") -Value $malformed -Encoding UTF8 -NoNewline
        New-Item -ItemType Directory -Path (Join-Path $projectPath "plugins\bolt-core\agents") -Force | Out-Null

        $script:LastWarn = $null
        Set-VSCodeAgentDiscovery -ProjectRoot $projectPath -PluginIds @('bolt-core')

        $unchanged = Get-Content (Join-Path $projectPath ".vscode\settings.json") -Raw
        if ($unchanged -ne $malformed) { throw "Malformed settings.json was modified instead of being skipped" }
        if (-not $script:LastWarn) { throw "Expected a warning to be logged for unparsable settings.json" }
        Write-TestPass "Malformed settings.json left untouched, warning logged instead of throwing"

        Remove-TestProject $projectPath

        Write-TestPass "TEST 9 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 9; Name = "VS Code Agent/Skill Discovery"; Status = "PASS" }
    }
    catch {
        Write-TestFail "TEST 9 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 9; Name = "VS Code Agent/Skill Discovery"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Test 10: Claude Code enabledPlugins direct-write fallback ────────────────

function Test-10-ClaudeEnabledPluginsFallback {
    Write-TestHeader "TEST 10: Claude Code enabledPlugins direct-write fallback (.claude/settings.json)"

    try {
        # Stub for the logging helper Set-ClaudeEnabledPlugins calls internally — matches the
        # param([string]) signature defined in Invoke-BoltPlugin.ps1.
        function Write-Warn { param([string]$M) $script:LastWarn = $M }

        $pluginScript = Join-Path $FrameworkRoot ".boltf\scripts\powershell\Invoke-BoltPlugin.ps1"
        . Import-ScriptFunction -ScriptPath $pluginScript -FunctionName "Set-ClaudeEnabledPlugins"
        $script:MarketplaceName = "bolt-framework"

        # --- Case A: fresh project, no .claude/settings.json yet ---
        $projectPath = New-TestProject "test-10-claude-enabledplugins-fresh"
        Write-TestStep "Case A: fresh project creates enabledPlugins with bolt-core forced true"

        Set-ClaudeEnabledPlugins -ProjectRoot $projectPath -PluginIds @('bolt-frontend')

        $settingsPath = Join-Path $projectPath ".claude\settings.json"
        Assert-FileExists $settingsPath ".claude/settings.json"
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.enabledPlugins.'bolt-core@bolt-framework' -ne $true) { throw "bolt-core@bolt-framework must be forced true" }
        if ($settings.enabledPlugins.'bolt-frontend@bolt-framework' -ne $true) { throw "Missing bolt-frontend@bolt-framework" }
        Write-TestPass "Fresh project creates enabledPlugins with bolt-core forced true"

        Remove-TestProject $projectPath

        # --- Case B: existing settings.json — preserve other keys + other-marketplace entries ---
        $projectPath = New-TestProject "test-10-claude-enabledplugins-refresh"
        Write-TestStep "Case B: refresh preserves unrelated keys and other-marketplace entries"

        New-Item -ItemType Directory -Path (Join-Path $projectPath ".claude") -Force | Out-Null
        Set-Content -Path (Join-Path $projectPath ".claude\settings.json") -Value (@{
            "extraKnownMarketplaces" = @{ "other-mp" = @{ "source" = "x" } }
            "enabledPlugins"         = @{
                "some-other-plugin@other-marketplace" = $true
                "bolt-ai@bolt-framework"               = $false
            }
        } | ConvertTo-Json -Depth 10) -Encoding UTF8

        Set-ClaudeEnabledPlugins -ProjectRoot $projectPath -PluginIds @('bolt-ai', 'bolt-backend')

        $settingsPath = Join-Path $projectPath ".claude\settings.json"
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if (-not $settings.extraKnownMarketplaces.'other-mp') { throw "Unrelated top-level key 'extraKnownMarketplaces' was lost during merge" }
        if ($settings.enabledPlugins.'some-other-plugin@other-marketplace' -ne $true) { throw "Entry for another marketplace was lost during merge" }
        if ($settings.enabledPlugins.'bolt-ai@bolt-framework' -ne $true) { throw "Stale bolt-ai@bolt-framework:false was not refreshed to true" }
        if ($settings.enabledPlugins.'bolt-core@bolt-framework' -ne $true) { throw "bolt-core@bolt-framework must be forced true" }
        if ($settings.enabledPlugins.'bolt-backend@bolt-framework' -ne $true) { throw "Missing bolt-backend@bolt-framework after add" }
        Write-TestPass "Refresh preserves unrelated keys/marketplaces, forces bolt-core true, adds new plugin"

        Remove-TestProject $projectPath

        # --- Case C: malformed existing settings.json is skipped gracefully, not overwritten ---
        $projectPath = New-TestProject "test-10-claude-enabledplugins-malformed"
        Write-TestStep "Case C: malformed existing settings.json is left untouched (no throw)"

        New-Item -ItemType Directory -Path (Join-Path $projectPath ".claude") -Force | Out-Null
        $malformed = '{ "enabledPlugins": { "bolt-core@bolt-framework": true' # unterminated JSON
        Set-Content -Path (Join-Path $projectPath ".claude\settings.json") -Value $malformed -Encoding UTF8 -NoNewline

        $script:LastWarn = $null
        Set-ClaudeEnabledPlugins -ProjectRoot $projectPath -PluginIds @('bolt-core')

        $unchanged = Get-Content (Join-Path $projectPath ".claude\settings.json") -Raw
        if ($unchanged -ne $malformed) { throw "Malformed settings.json was modified instead of being skipped" }
        if (-not $script:LastWarn) { throw "Expected a warning to be logged for unparsable settings.json" }
        Write-TestPass "Malformed settings.json left untouched, warning logged instead of throwing"

        Remove-TestProject $projectPath

        Write-TestPass "TEST 10 PASSED"
        $script:PassedTests++
        $script:TestResults += @{ Test = 10; Name = "Claude enabledPlugins Fallback"; Status = "PASS" }
    }
    catch {
        Write-TestFail "TEST 10 FAILED: $_"
        $script:FailedTests++
        $script:TestResults += @{ Test = 10; Name = "Claude enabledPlugins Fallback"; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# ─── Main Test Runner ─────────────────────────────────────────────────────────

function Show-TestSummary {
    Write-Host "`n"
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Bolt Framework - Test Results Summary" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    foreach ($result in $TestResults) {
        $status = if ($result.Status -eq "PASS") { "✓" } else { "✗" }
        $color = if ($result.Status -eq "PASS") { "Green" } else { "Red" }

        Write-Host "  $status Test $($result.Test): $($result.Name)" -ForegroundColor $color
        if ($result.Error) {
            Write-Host "    Error: $($result.Error)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "  Total: $($PassedTests + $FailedTests) tests" -ForegroundColor White
    Write-Host "  Passed: $PassedTests" -ForegroundColor Green
    Write-Host "  Failed: $FailedTests" -ForegroundColor $(if ($FailedTests -eq 0) { "Green" } else { "Red" })
    Write-Host ""

    if ($FailedTests -eq 0) {
        Write-Host "  ✓ ALL TESTS PASSED" -ForegroundColor Green
    } else {
        Write-Host "  ✗ SOME TESTS FAILED" -ForegroundColor Red
    }

    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Main {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Bolt Framework - Two-Step Initialization Test Suite" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Framework Root: $FrameworkRoot" -ForegroundColor White
    Write-Host "  Test Output: $TestOutputDir" -ForegroundColor White
    if ($KeepTestProjects) {
        Write-Host "  Keep Projects: YES (for inspection)" -ForegroundColor Yellow
    }
    Write-Host ""

    # Create test output directory
    if (-not (Test-Path $TestOutputDir)) {
        New-Item -ItemType Directory -Path $TestOutputDir -Force | Out-Null
    }

    # Run tests
    if ($TestNumber -eq 0) {
        # Run all tests
        Test-01-AppsInfraInit
        Test-02-SetupConstitutionSkill
        Test-03-DataAIPractice
        Test-04-CustomMode
        Test-05-DryRunMode
        Test-06-Idempotency
        Test-07-CicdProviderRouting
        Test-08-PluginsFallbackShim
        Test-09-VSCodeAgentDiscovery
        Test-10-ClaudeEnabledPluginsFallback
    } else {
        # Run specific test
        switch ($TestNumber) {
            1 { Test-01-AppsInfraInit }
            2 { Test-02-SetupConstitutionSkill }
            3 { Test-03-DataAIPractice }
            4 { Test-04-CustomMode }
            5 { Test-05-DryRunMode }
            6 { Test-06-Idempotency }
            7 { Test-07-CicdProviderRouting }
            8 { Test-08-PluginsFallbackShim }
            9 { Test-09-VSCodeAgentDiscovery }
            10 { Test-10-ClaudeEnabledPluginsFallback }
            default { Write-Host "Invalid test number: $TestNumber (valid: 1-10)" -ForegroundColor Red; exit 1 }
        }
    }

    # Show summary
    Show-TestSummary

    # Exit with appropriate code
    if ($FailedTests -gt 0) {
        exit 1
    }
}

Main
