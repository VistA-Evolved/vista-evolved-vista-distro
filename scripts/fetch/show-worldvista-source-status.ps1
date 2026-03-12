#Requires -Version 5.1
<#
.SYNOPSIS
  Show status of WorldVistA upstream sources: local path, branch, commit SHA, fetch date.
.DESCRIPTION
  Reads locks/worldvista-sources.lock.json and optionally scans upstream/ to show current state.
  Canonical paths: lock at locks/worldvista-sources.lock.json, upstream at upstream/.
.EXAMPLE
  .\show-worldvista-source-status.ps1
.EXAMPLE
  .\show-worldvista-source-status.ps1 -UseLockOnly
#>
[CmdletBinding()]
param(
  [string]$RepoRoot,
  [switch]$UseLockOnly
)

$ErrorActionPreference = "Stop"
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Split-Path -Parent $MyInvocation.MyCommand.Path) }
if (-not $RepoRoot) { $RepoRoot = (Resolve-Path (Join-Path $scriptDir "..\..")).Path }
if (-not [System.IO.Path]::IsPathRooted($RepoRoot)) { $RepoRoot = (Resolve-Path $RepoRoot).Path }
$LockPath = Join-Path $RepoRoot "locks\worldvista-sources.lock.json"
$UpstreamPath = Join-Path $RepoRoot "upstream"

Write-Host "`n=== WorldVistA upstream source status ===" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host "Lock file: $LockPath`n"

if (Test-Path -LiteralPath $LockPath) {
  $raw = Get-Content -LiteralPath $LockPath -Raw -Encoding UTF8
  if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) { $raw = $raw.Substring(1) }
  $lock = $raw | ConvertFrom-Json
  Write-Host "Lock file updated at: $($lock.updatedAt)" -ForegroundColor Gray
  Write-Host ""
  foreach ($r in $lock.repos) {
    $absPath = Join-Path $RepoRoot $r.localPath
    $exists = Test-Path -LiteralPath $absPath
    $status = if ($exists) { "OK" } else { "MISSING" }
    Write-Host "  $($r.name)" -ForegroundColor White
    Write-Host "    Purpose:   $($r.purpose)"
    Write-Host "    Local path: $($r.localPath)"
    Write-Host "    Branch:    $($r.branch)"
    Write-Host "    Commit:    $($r.commitSha)"
    Write-Host "    Fetch date: $($r.fetchDate)"
    Write-Host "    On disk:   $status"
    Write-Host ""
  }
} else {
  Write-Host "Lock file not found: $LockPath" -ForegroundColor Yellow
  Write-Host "Run scripts\fetch\fetch-worldvista-sources.ps1 first.`n"
}

if (-not $UseLockOnly -and (Test-Path -LiteralPath $UpstreamPath)) {
  Write-Host "upstream/ contents:" -ForegroundColor Cyan
  Get-ChildItem -LiteralPath $UpstreamPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $gitDir = Join-Path $_.FullName ".git"
    $isRepo = Test-Path -LiteralPath $gitDir
    $head = $null
    if ($isRepo) {
      Push-Location $_.FullName
      try {
        $head = & git rev-parse HEAD 2>&1
        if ($LASTEXITCODE -eq 0) { $head = $head.Trim().Substring(0, [Math]::Min(12, $head.Trim().Length)) }
        else { $head = "?" }
      } finally { Pop-Location }
    }
    Write-Host "  $($_.Name)  $(if($isRepo){ "git: $head" } else { "not a git repo" })"
  }
  Write-Host ""
}
