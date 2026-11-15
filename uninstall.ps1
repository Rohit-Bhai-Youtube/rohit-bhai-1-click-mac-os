# ==============================================================================
# Rohit Bhai Mac OS - Uninstaller
# Target: Windows 11 / Windows 10
# Reverts Windhawk mods, cursor schemes, sound schemes, and fonts safely
# Crafted for Rohit Bhai
# ==============================================================================

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

# 1. Reset Sound Scheme to Windows Default
Write-Host "[*] Resetting sound scheme to Windows Default..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value ".Default" -Force -ErrorAction SilentlyContinue
if (Test-Path "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS") {
    Remove-Item "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS" -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. Reset Cursors to Windows Default
Write-Host "[*] Resetting cursors to Windows Default..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "" -Value "Windows Default" -Force -ErrorAction SilentlyContinue

# 3. Disable and remove Windhawk mods
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
Write-Host "[OK] Rohit Bhai Mac OS uninstalled cleanly. Windows defaults restored!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
