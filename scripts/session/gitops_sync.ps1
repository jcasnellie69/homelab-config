param(
    [switch]$Apply,
    [switch]$Push,
    [switch]$AllowMain,
    [string]$Branch = "",
    [string]$Report = "artifacts/automation/workspace-gitops-monitor-report.json",
    [string]$Message = "chore(workspace): sync monitored updates"
)

$ErrorActionPreference = "Stop"
$RepoDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoDir

Write-Host "[gitops] repository: $RepoDir"

if (Test-Path "scripts/session/workspace_gitops_monitor.py") {
    python scripts/session/workspace_gitops_monitor.py --report $Report
}

git status --short --branch
$currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()

if (-not $Apply) {
    Write-Host "[gitops] dry-run only; no changes staged or pushed"
    exit 0
}

if ($currentBranch -eq "main" -and -not $AllowMain) {
    if (-not $Branch) {
        $Branch = "chore/workspace-sync-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    }

    $existing = git branch --list $Branch
    if ($existing) {
        git switch $Branch
    }
    else {
        git switch -c $Branch
    }

    $currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
    Write-Host "[gitops] using safety branch: $currentBranch"
}

git add -A
& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "[gitops] no staged changes to commit"
    exit 0
}

git commit -m $Message
Write-Host "[gitops] commit created on branch $currentBranch"

if ($Push) {
    git push -u origin $currentBranch
}
