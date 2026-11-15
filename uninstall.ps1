<#
.SYNOPSIS
    Rohit Bhai Mac OS - Uninstaller
.DESCRIPTION
    Safely disables and uninstalls all mods applied by the Rohit Bhai Mac OS suite.
#>

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Clear-Host
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host "                ROHIT BHAI MAC OS - UNINSTALLER                     " -ForegroundColor Yellow
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host ""

$WindhawkCli = "C:\Program Files\Windhawk\windhawk-cli.exe"
if (-not (Test-Path $WindhawkCli)) {
    $alt = "$env:ProgramFiles(x86)\Windhawk\windhawk-cli.exe"
    if (Test-Path $alt) { $WindhawkCli = $alt }
}

if (Test-Path $WindhawkCli) {
    $mods = @(
        "mac-island-dock",
        "macos-minimize-animation",
        "local@net-speed-taskbar-apple",
        "windows-11-start-menu-styler",
        "windows-11-notification-center-styler",
        "windows-11-file-explorer-styler",
        "translucent-windows",
        "invisible-borders",
        "rohit-bhai-mac-os"
    )

    foreach ($m in $mods) {
        Write-Host "[*] Removing mod: $m..." -ForegroundColor Cyan
        & $WindhawkCli mod disable $m --yes 2>$null
        & $WindhawkCli mod remove $m --yes 2>$null
    }
}

Write-Host "[*] Refreshing Windows Explorer..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe

Write-Host ""
Write-Host "[OK] Rohit Bhai Mac OS uninstalled. Windows default restored!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
