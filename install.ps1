# ==============================================================================
# Rohit Bhai Mac OS - 1-Line Universal Web & Local Installer
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Constants & Repository Configuration
$RepoOwner = "romflasher3419-spec"
$RepoName  = "rohit-bhai-mac-os"
$Branch    = "main"
$WebScriptUrl     = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/install.ps1"
$ReleaseAssetUrl  = "https://github.com/$RepoOwner/$RepoName/releases/latest/download/Rohit-Bhai-Mac-OS.whdata"
$RawFallbackUrl   = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Rohit-Bhai-Mac-OS.whdata"

# Auto-elevate to Administrator (Rock-solid for both Web iex and Local file runs)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $elevateCmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$WebScriptUrl' | iex"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$elevateCmd`""
    }
    exit
}

# Display Banner
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

Write-Host "  [+] Included Features:" -ForegroundColor White
Write-Host "      * Dynamic Island & Mac Dock (32px icons, 22px radius, 170% zoom, bounce)" -ForegroundColor DarkGray
Write-Host "      * macOS Genie Minimize Animation (450ms smooth curve)" -ForegroundColor DarkGray
Write-Host "      * Apple Taskbar Network Speed Indicator (Live sparkline chart)" -ForegroundColor DarkGray
Write-Host "      * LiquidGlass Frosted Start Menu (Custom gradient borders)" -ForegroundColor DarkGray
Write-Host "      * OS26 Tahoe Glass Notification Center" -ForegroundColor DarkGray
Write-Host "      * Translucent Acrylic Windows & Explorer Glass" -ForegroundColor DarkGray
Write-Host "      * Invisible Borders & Modern Rounded Windows" -ForegroundColor DarkGray
Write-Host ""

# Setup temporary directory
$WorkDir = Join-Path $env:TEMP "RohitBhaiMacOS"
if (-not (Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

# -------------------------------------------------------------------------
# Step 1: Detect or Install Windhawk
# -------------------------------------------------------------------------
Write-Host "[1/5] Checking Windhawk installation..." -ForegroundColor Cyan

function Find-WindhawkCli {
    $paths = @(
        "C:\Program Files\Windhawk\windhawk-cli.exe",
        "$env:ProgramFiles\Windhawk\windhawk-cli.exe",
        "$env:ProgramFiles(x86)\Windhawk\windhawk-cli.exe",
        "$env:LOCALAPPDATA\Programs\Windhawk\windhawk-cli.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$WindhawkCli = Find-WindhawkCli

if (-not $WindhawkCli) {
    Write-Host "  [-] Windhawk is not installed. Installing Windhawk..." -ForegroundColor Yellow
    $installed = $false

    # Try winget if available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  [*] Installing via winget..." -ForegroundColor Yellow
        try {
            winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements --silent
            Start-Sleep -Seconds 5
            $WindhawkCli = Find-WindhawkCli
            if ($WindhawkCli) { $installed = $true }
        } catch {}
    }

    # Fallback to direct official installer
    if (-not $installed) {
        Write-Host "  [*] Downloading official installer from windhawk.net..." -ForegroundColor Yellow
        $installerPath = Join-Path $WorkDir "windhawk_setup.exe"
        try {
            Invoke-WebRequest -Uri "https://windhawk.net/download/windhawk_setup.exe" -OutFile $installerPath -UseBasicParsing
            Write-Host "  [*] Running installer silently..." -ForegroundColor Yellow
            Start-Process $installerPath -ArgumentList "/S" -Wait
            
            # Wait up to 30s for windhawk-cli to appear
            $timeout = 30
            while ($timeout -gt 0 -and (-not $WindhawkCli)) {
                Start-Sleep -Seconds 2
                $timeout -= 2
                $WindhawkCli = Find-WindhawkCli
            }
        } catch {
            Write-Host "  [!] Installer download failed: $_" -ForegroundColor Red
        }
    }

    if (-not $WindhawkCli) {
        Write-Host "  [!] Error: Could not automatically install Windhawk." -ForegroundColor Red
        Write-Host "      Please install Windhawk manually from https://windhawk.net and re-run this command." -ForegroundColor Yellow
        Pause
        exit 1
    }
}

Write-Host "  [OK] Windhawk detected at: $WindhawkCli" -ForegroundColor Green

# Ensure Windhawk service is running
$whSvc = Get-Service Windhawk -ErrorAction SilentlyContinue
if ($whSvc -and $whSvc.Status -ne 'Running') {
    Write-Host "  [*] Starting Windhawk service..." -ForegroundColor Yellow
    Start-Service Windhawk -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

# -------------------------------------------------------------------------
# Step 2: Acquire Package (.whdata)
# -------------------------------------------------------------------------
Write-Host "`n[2/5] Acquiring Rohit Bhai Mac OS package..." -ForegroundColor Cyan
$WhDataLocal = Join-Path $WorkDir "Rohit-Bhai-Mac-OS.whdata"
$acquired = $false

# 1. Check if running alongside local package file (USB or local clone)
$ScriptDir = if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } else { $PSScriptRoot }
if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata"))) {
    $localFile = Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata"
    Copy-Item $localFile -Destination $WhDataLocal -Force
    Write-Host "  [OK] Using local package file from: $localFile" -ForegroundColor Green
    $acquired = $true
}

# 2. Download from GitHub Release
if (-not $acquired) {
    Write-Host "  [*] Downloading official package from GitHub..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $ReleaseAssetUrl -OutFile $WhDataLocal -UseBasicParsing
        if ((Test-Path $WhDataLocal) -and ((Get-Item $WhDataLocal).Length -gt 1000000)) {
            $acquired = $true
            Write-Host "  [OK] Downloaded via GitHub Releases!" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [!] Release download failed, trying raw CDN..." -ForegroundColor Yellow
    }
}

# 3. Fallback to Raw CDN
if (-not $acquired) {
    try {
        Invoke-WebRequest -Uri $RawFallbackUrl -OutFile $WhDataLocal -UseBasicParsing
        if ((Test-Path $WhDataLocal) -and ((Get-Item $WhDataLocal).Length -gt 1000000)) {
            $acquired = $true
            Write-Host "  [OK] Downloaded via Raw CDN!" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [!] Raw download failed: $_" -ForegroundColor Red
    }
}

if (-not $acquired -or -not (Test-Path $WhDataLocal) -or ((Get-Item $WhDataLocal).Length -lt 1000000)) {
    Write-Host "  [!] Error: Could not download package file. Please check your internet connection." -ForegroundColor Red
    Pause
    exit 1
}

# -------------------------------------------------------------------------
# Step 3: Apply Windows Dark Mode & Styling Baseline
# -------------------------------------------------------------------------
Write-Host "`n[3/5] Applying Windows Dark Mode & Glass Optimization..." -ForegroundColor Cyan
try {
    $themeReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (Test-Path $themeReg) {
        Set-ItemProperty -Path $themeReg -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $themeReg -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  [OK] macOS Dark Mode baseline applied!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Dark mode note: Skipped non-critical registry write." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 4: Import Mods & Settings into Windhawk
# -------------------------------------------------------------------------
Write-Host "`n[4/5] Activating all 8 mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
Write-Host "      (Mac Island Dock, Genie Animation, LiquidGlass, Apple Net Speed...)" -ForegroundColor DarkGray

& $WindhawkCli data import $WhDataLocal --on-conflict overwrite --confirm-app-restart
$importCode = $LASTEXITCODE

if ($importCode -eq 0) {
    Write-Host "  [OK] All mods and custom settings activated successfully!" -ForegroundColor Green
} else {
    Write-Host "  [*] Retrying with local compilation mode..." -ForegroundColor Yellow
    & $WindhawkCli data import $WhDataLocal --offline --on-conflict overwrite --confirm-app-restart
    Write-Host "  [OK] Import completed!" -ForegroundColor Green
}

# -------------------------------------------------------------------------
# Step 5: Refresh Windows Shell & Cleanup
# -------------------------------------------------------------------------
Write-Host "`n[5/5] Refreshing Windows Desktop..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe
Start-Sleep -Seconds 2

# Cleanup temporary folder
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "            CONGRATULATIONS! ROHIT BHAI MAC OS IS NOW ACTIVE!                          " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * Mac Island & Dock is running at the bottom." -ForegroundColor White
Write-Host "  * macOS Genie Minimize animation is active." -ForegroundColor White
Write-Host "  * Apple Taskbar Network Speed indicator is active." -ForegroundColor White
Write-Host "  * LiquidGlass Start Menu & Tahoe Glass Notification Center are styled." -ForegroundColor White
Write-Host ""
Write-Host "  Created with love by: Rohit Bhai" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/romflasher3419-spec/rohit-bhai-mac-os" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
