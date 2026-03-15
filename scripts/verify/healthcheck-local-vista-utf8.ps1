#Requires -Version 5.1
<#
.SYNOPSIS
  Run all readiness levels for the local-vista-utf8 lane and output pass/fail.
.DESCRIPTION
  Levels: CONTAINER_STARTED, NETWORK_REACHABLE, SERVICE_READY, TERMINAL_READY, RPC_READY.
  Uses canonical ports 9434 (RPC) and 2226 (SSH) unless overridden by env or parameters.
  -ValidatePathsOnly: print canonical paths and assumptions only; do not call Docker.
.EXAMPLE
  .\healthcheck-local-vista-utf8.ps1 -ValidatePathsOnly
.EXAMPLE
  .\healthcheck-local-vista-utf8.ps1 -HostPortRpc 9434 -HostPortSsh 2226
#>
[CmdletBinding()]
param(
  [string]$HostPortRpc = $(if ($env:LOCAL_VISTA_UTF8_PORT) { [int]$env:LOCAL_VISTA_UTF8_PORT } else { 9434 }),
  [string]$HostPortSsh = $(if ($env:LOCAL_VISTA_UTF8_SSH_PORT) { [int]$env:LOCAL_VISTA_UTF8_SSH_PORT } else { 2226 }),
  [string]$ContainerName = "local-vista-utf8",
  [int]$TcpTimeoutMs = 3000,
  [switch]$ValidatePathsOnly
)

$ErrorActionPreference = "Stop"

$_ScriptPath = if ($PSCommandPath) {
  $PSCommandPath
} elseif ($MyInvocation.MyCommand.Path) {
  $MyInvocation.MyCommand.Path
} else {
  throw "Unable to determine script path. Run via & or powershell.exe -File."
}
$_ScriptDir = Split-Path -Parent $_ScriptPath
$script:RepoRoot = (Resolve-Path (Join-Path $_ScriptDir "..\..")).Path

if ($ValidatePathsOnly) {
  Write-Host "`n=== healthcheck-local-vista-utf8.ps1 (ValidatePathsOnly) ===" -ForegroundColor Cyan
  Write-Host "  Repo root:       $script:RepoRoot"
  Write-Host "  Script dir:      $_ScriptDir"
  Write-Host "  Container name:  $ContainerName"
  Write-Host "  RPC port:        $HostPortRpc"
  Write-Host "  SSH port:        $HostPortSsh"
  Write-Host "  TCP timeout ms:  $TcpTimeoutMs"
  Write-Host "  Docker:          Not invoked (validate only)"
  if (-not (Test-Path -LiteralPath $script:RepoRoot)) {
    Write-Host "  FAIL: Repo root does not exist." -ForegroundColor Red
    exit 1
  }
  Write-Host "`n  No Docker or network calls performed.`n" -ForegroundColor Gray
  exit 0
}

$script:PassCount = 0
$script:FailCount = 0

function Test-TcpPort {
  param([string]$HostAddr, [int]$Port, [int]$TimeoutMs)
  try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $async = $tcp.BeginConnect($HostAddr, $Port, $null, $null)
    $wait = $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
    if (-not $wait) { $tcp.Close(); return $false }
    $tcp.EndConnect($async)
    $tcp.Close()
    return $true
  } catch {
    return $false
  }
}

function Write-Level {
  param([string]$Level, [bool]$Pass, [string]$Detail = "")
  $status = if ($Pass) { "PASS" } else { "FAIL" }
  if ($Pass) { $script:PassCount++ } else { $script:FailCount++ }
  $color = if ($Pass) { "Green" } else { "Red" }
  $line = "  $Level : $status"
  if ($Detail) { $line += " ($Detail)" }
  Write-Host $line -ForegroundColor $color
}

Write-Host "`n=== Local Vista UTF-8 readiness check ===" -ForegroundColor Cyan
Write-Host "  RPC port: $HostPortRpc  SSH port: $HostPortSsh  Container: $ContainerName`n"

$status = docker ps -a --filter "name=$ContainerName" --format "{{.Status}}" 2>&1
$containerUp = $status -match "^Up"
Write-Level -Level "CONTAINER_STARTED" -Pass $containerUp -Detail $(if ($status) { $status.Trim() } else { "container not found" })

$rpcReach = Test-TcpPort -HostAddr "127.0.0.1" -Port $HostPortRpc -TimeoutMs $TcpTimeoutMs
$sshReach = Test-TcpPort -HostAddr "127.0.0.1" -Port $HostPortSsh -TimeoutMs $TcpTimeoutMs
Write-Level -Level "NETWORK_REACHABLE" -Pass ($rpcReach -and $sshReach) -Detail "RPC=$rpcReach SSH=$sshReach"

$health = docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' $ContainerName 2>$null
if ($LASTEXITCODE -ne 0) { $health = "none" }
$healthOk = $health -eq "healthy"
Write-Level -Level "SERVICE_READY" -Pass $healthOk -Detail $(if ($health -and $health -ne "none") { $health.Trim() } else { "no health status" })

Write-Level -Level "TERMINAL_READY" -Pass $sshReach -Detail "TCP 127.0.0.1:$HostPortSsh"
Write-Level -Level "RPC_READY" -Pass $rpcReach -Detail "TCP 127.0.0.1:$HostPortRpc"

Write-Host ""
Write-Host "  Total: $script:PassCount PASS, $script:FailCount FAIL" -ForegroundColor $(if ($script:FailCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($script:FailCount -gt 0) {
  exit 1
}
exit 0