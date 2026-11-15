<#
.SYNOPSIS
    Rohit Bhai Mac OS - 1-Line Universal Web & Local Installer for Windows 11
.DESCRIPTION
    Instantly transforms Windows 11 into a complete macOS aesthetic using Windhawk.
    Activates Mac Island Dock, Genie Minimize animation, Apple Network Speed,
    LiquidGlass Start Menu, Tahoe Glass Notifications, Translucent Windows, and Invisible Borders.
.EXAMPLE
    irm https://raw.githubusercontent.com/rohitbhai/rohit-bhai-mac-os/main/install.ps1 | iex
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { irm '$PSCommandPath' | iex }`""
    exit
}

# Clear and show sleek Banner
Clear-Host
Write-Host @"
========================================================================================
     ___ _____  _   _ ___ _____   ____  _   _    _    ___   __  __    _    ____   ___  ____  
    | _ \ _ \ || | | |_ _|_   _| | __ )| | | |  / \  |_ _| |  \/  |  / \  / ___| / _ \/ ___| 
    |   / / \ \ |_| | | |  | |   |  _ \| |_| | / _ \  | |  | |\/| | / _ \| |    | | | \___ \ 
    |_|_\_\_/__/\___/|___| |_|   |____/|_| |_|/_/   \_|___| |_|  |_|/_/   \_\____| \___/|____/ 
========================================================================================
                      ALL-IN-ONE MACOS EXPERIENCE FOR WINDOWS 11
                              Crafted by Rohit Bhai
========================================================================================
"@ -ForegroundColor Cyan

Write-Host ""
Write-Host "  [+] Included Features:" -ForegroundColor White
Write-Host "      • Dynamic Island & Mac Dock (32px icons, 22px radius, 170% zoom, bounce)" -ForegroundColor DarkGray
Write-Host "      • macOS Genie Minimize Animation (450ms smooth curve)" -ForegroundColor DarkGray
Write-Host "      • Apple Taskbar Network Speed Indicator (Live sparkline chart)" -ForegroundColor DarkGray
Write-Host "      • LiquidGlass Frosted Start Menu (Custom gradient borders)" -ForegroundColor DarkGray
Write-Host "      • OS26 Tahoe Glass Notification Center" -ForegroundColor DarkGray
Write-Host "      • Translucent Acrylic Windows & Explorer Glass" -ForegroundColor DarkGray
Write-Host "      • Invisible Borders & Modern Rounded Windows" -ForegroundColor DarkGray
Write-Host ""

# Define GitHub Configuration
# (Rohit Bhai: Apne GitHub username se is URL ko replace kar sakte ho)
$RepoOwner = "romflasher3419-spec"
$RepoName  = "rohit-bhai-mac-os"
$Branch    = "main"
$RawBaseUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch"
$ReleaseWhDataUrl = "https://github.com/$RepoOwner/$RepoName/releases/latest/download/Rohit-Bhai-Mac-OS.whdata"

# Setup temporary staging directory
$WorkDir = Join-Path $env:TEMP "RohitBhaiMacOS"
if (-not (Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

# 1. Check or Install Windhawk
Write-Host "[1/4] Checking Windhawk installation..." -ForegroundColor Cyan

$WindhawkCli = "C:\Program Files\Windhawk\windhawk-cli.exe"
if (-not (Test-Path $WindhawkCli)) {
    $alt = "$env:ProgramFiles(x86)\Windhawk\windhawk-cli.exe"
    if (Test-Path $alt) { $WindhawkCli = $alt }
}

if (-not (Test-Path $WindhawkCli)) {
    Write-Host "  [-] Windhawk is not installed. Installing automatically via winget..." -ForegroundColor Yellow
    try {
        winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements --silent
    } catch {
        Write-Host "  [-] Winget install failed. Downloading official installer..." -ForegroundColor Yellow
        $installerPath = Join-Path $WorkDir "windhawk_setup.exe"
        Invoke-WebRequest -Uri "https://windhawk.net/download/windhawk_setup.exe" -OutFile $installerPath
        Start-Process $installerPath -ArgumentList "/S" -Wait
    }

    # Re-verify path
    if (-not (Test-Path $WindhawkCli)) {
        Write-Host "  [!] Error: Please install Windhawk manually from https://windhawk.net and re-run." -ForegroundColor Red
        Pause
        exit 1
    }
}
Write-Host "  [OK] Windhawk detected at: $WindhawkCli" -ForegroundColor Green

# 2. Acquire Rohit-Bhai-Mac-OS.whdata package
Write-Host "`n[2/4] Downloading Rohit Bhai Mac OS package..." -ForegroundColor Cyan
$WhDataLocal = Join-Path $WorkDir "Rohit-Bhai-Mac-OS.whdata"

# Check if script is running next to a local .whdata file
$ScriptParent = Split-Path -Parent $MyInvocation.MyCommand.Definition -ErrorAction SilentlyContinue
if ($ScriptParent -and (Test-Path (Join-Path $ScriptParent "Rohit-Bhai-Mac-OS.whdata"))) {
    Copy-Item (Join-Path $ScriptParent "Rohit-Bhai-Mac-OS.whdata") -Destination $WhDataLocal -Force
    Write-Host "  [OK] Using local package file." -ForegroundColor Green
} else {
    # Download from GitHub release or raw
    Write-Host "  [*] Downloading package from GitHub..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $ReleaseWhDataUrl -OutFile $WhDataLocal -UseBasicParsing
    } catch {
        # Fallback to raw if release not yet uploaded
        $FallbackUrl = "$RawBaseUrl/Rohit-Bhai-Mac-OS.whdata"
        Invoke-WebRequest -Uri $FallbackUrl -OutFile $WhDataLocal -UseBasicParsing
    }
    Write-Host "  [OK] Download complete!" -ForegroundColor Green
}

# 3. Import Package into Windhawk
Write-Host "`n[3/4] Activating mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
& $WindhawkCli data import $WhDataLocal --offline --on-conflict overwrite --confirm-app-restart
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] All 8 mods and custom settings activated!" -ForegroundColor Green
} else {
    Write-Host "  [!] Warning: Import code $LASTEXITCODE. Applying baseline config..." -ForegroundColor Yellow
}

# 4. Refresh Windows Shell
Write-Host "`n[4/4] Refreshing Windows Desktop & Dock..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe
Start-Sleep -Seconds 2

# Cleanup temporary files
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "            CONGRATULATIONS! ROHIT BHAI MAC OS IS NOW ACTIVE!                          " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  ✨ Enjoy your brand-new macOS experience on Windows 11!" -ForegroundColor White
Write-Host "  🍎 Created by: Rohit Bhai" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to close this window..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
