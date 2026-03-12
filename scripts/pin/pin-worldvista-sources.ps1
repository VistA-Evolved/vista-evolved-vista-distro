#Requires -Version 5.1
<#
.SYNOPSIS
  Pin WorldVistA upstream repos to exact commits. Updates the lock file with the given SHAs.
.DESCRIPTION
  Canonical paths: config at scripts/fetch/worldvista-sources.config.json, lock at locks/worldvista-sources.lock.json.
  -ValidateOnly: validate config and paths only; do not run git.
.EXAMPLE
  .\pin-worldvista-sources.ps1 -ValidateOnly
.EXAMPLE
  .\pin-worldvista-sources.ps1
#>
[CmdletBinding()]
param(
  [string]$RepoRoot,
  [string]$ConfigPath,
  [string]$LockPath,
  [string]$VistAM,
  [string]$VistA,
  [string]$VistAVEHUM,
  [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Split-Path -Parent $MyInvocation.MyCommand.Path) }
if (-not $RepoRoot) { $RepoRoot = (Resolve-Path (Join-Path $scriptDir "..\..")).Path }
if (-not [System.IO.Path]::IsPathRooted($RepoRoot)) { $RepoRoot = (Resolve-Path $RepoRoot).Path }
$script:RepoRoot = $RepoRoot
if (-not $ConfigPath) { $ConfigPath = (Join-Path $script:RepoRoot "scripts\fetch\worldvista-sources.config.json") }
if (-not $LockPath) { $LockPath = (Join-Path $script:RepoRoot "locks\worldvista-sources.lock.json") }
$script:ConfigPath = if ([System.IO.Path]::IsPathRooted($ConfigPath)) { $ConfigPath } else { (Join-Path $script:RepoRoot (Join-Path "scripts" (Join-Path "fetch" (Split-Path -Leaf $ConfigPath)))) }
$script:LockPath = if ([System.IO.Path]::IsPathRooted($LockPath)) { $LockPath } else { (Join-Path $script:RepoRoot "locks\worldvista-sources.lock.json") }

function Write-Log { param([string]$Message) Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" }

# --- ValidateOnly ---
if ($ValidateOnly) {
  Write-Host "`n=== pin-worldvista-sources.ps1 (ValidateOnly) ===" -ForegroundColor Cyan
  Write-Host "  Repo root:  $script:RepoRoot"
  Write-Host "  Config:     $script:ConfigPath"
  Write-Host "  Lock file:  $script:LockPath"
  $fail = $false
  if (-not (Test-Path -LiteralPath $script:RepoRoot)) {
    Write-Host "  FAIL: Repo root does not exist." -ForegroundColor Red
    $fail = $true
  }
  if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
    Write-Host "  FAIL: Config file not found." -ForegroundColor Red
    $fail = $true
  } else {
    $raw = Get-Content -LiteralPath $script:ConfigPath -Raw -Encoding UTF8
    if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
    try {
      $cfg = $raw | ConvertFrom-Json
      Write-Host "  Config:     Valid JSON ($($cfg.sources.Count) sources)"
    } catch {
      Write-Host "  FAIL: Config is not valid JSON." -ForegroundColor Red
      $fail = $true
    }
  }
  $lockDir = Split-Path -Parent $script:LockPath
  if (-not (Test-Path -LiteralPath $lockDir)) {
    Write-Host "  Lock dir:   Does not exist (will be created on first pin)"
  } else {
    Write-Host "  Lock dir:   Exists"
  }
  if ($fail) { exit 1 }
  Write-Host "`n  No git operations performed.`n" -ForegroundColor Gray
  exit 0
}

$pins = @{
  "VistA-M"     = $VistAM
  "VistA"       = $VistA
  "VistA-VEHU-M" = $VistAVEHUM
}

if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
  Write-Error "Config not found: $script:ConfigPath"
  exit 1
}

$config = Get-Content -LiteralPath $script:ConfigPath -Raw -Encoding UTF8
if ($config[0] -eq [char]0xFEFF) { $config = $config.Substring(1) }
$cfg = $config | ConvertFrom-Json

$lockDir = Split-Path -Parent $script:LockPath
if (-not (Test-Path -LiteralPath $lockDir)) {
  New-Item -ItemType Directory -Path $lockDir -Force | Out-Null
}

$lock = @{
  description = "Pinned WorldVistA upstream sources. Updated by fetch-worldvista-sources.ps1 and pin-worldvista-sources.ps1."
  updatedAt   = (Get-Date -Format "o")
  repos       = [System.Collections.ArrayList]::new()
}

foreach ($s in $cfg.sources) {
  if ($s.optional -and -not $cfg.vehuEnabled) { continue }
  $absPath = Join-Path $RepoRoot $s.localPath
  if (-not (Test-Path -LiteralPath (Join-Path $absPath ".git"))) {
    Write-Log "Skipping $($s.name): not cloned yet. Run scripts\fetch\fetch-worldvista-sources.ps1 first."
    continue
  }
  $targetSha = $pins[$s.name]
  Push-Location $absPath
  try {
    if ($targetSha) {
      & git fetch origin 2>&1 | Out-Null
      & git checkout $targetSha 2>&1
      if ($LASTEXITCODE -ne 0) { throw "git checkout $targetSha failed" }
      $sha = & git rev-parse HEAD 2>&1
      $sha = $sha.Trim()
    } else {
      $sha = & git rev-parse HEAD 2>&1
      $sha = $sha.Trim()
    }
    $branch = & git rev-parse --abbrev-ref HEAD 2>&1
    if (-not $branch -or $branch -eq "HEAD") { $branch = $s.branch }
    else { $branch = $branch.Trim() }
    [void]$lock.repos.Add([PSCustomObject]@{
        name      = $s.name
        url       = $s.url
        branch    = $branch
        commitSha = $sha
        localPath = $s.localPath
        fetchDate = (Get-Date -Format "o")
        purpose   = $s.purpose
      })
    Write-Log "Pinned $($s.name) -> $sha"
  } finally {
    Pop-Location
  }
}

$lock.repos = @($lock.repos)
$lockJson = $lock | ConvertTo-Json -Depth 5
Set-Content -LiteralPath $script:LockPath -Value $lockJson -Encoding UTF8 -NoNewline
Write-Log "Lock file updated: $script:LockPath"
