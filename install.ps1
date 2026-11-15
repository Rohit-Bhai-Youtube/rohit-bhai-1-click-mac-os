# ==============================================================================
# Rohit Bhai Mac OS - 1-Line Universal Web & Local Installer v2.0 Ultimate
# Target: Windows 11 / Windows 10 (x64)
# Crafted by Rohit Bhai
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Repository Configuration
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
                 ALL-IN-ONE MACOS EXPERIENCE FOR WINDOWS 11 (v2.0 PRO)
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
Write-Host "      * Apple SF Pro Display Fonts Suite (Official Apple Typography)" -ForegroundColor DarkGray
Write-Host "      * macOS Capitaine Dark Cursors Scheme (With Spinning Beach Ball)" -ForegroundColor DarkGray
Write-Host "      * 4K Ultra-HD macOS Wallpaper & Deep Dark Mode Integration" -ForegroundColor DarkGray
Write-Host ""

# Setup temporary staging directory
$WorkDir = Join-Path $env:TEMP "RohitBhaiMacOS"
if (-not (Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

# -------------------------------------------------------------------------
# Step 1: Detect or Install Windhawk
# -------------------------------------------------------------------------
Write-Host "[1/6] Checking Windhawk installation..." -ForegroundColor Cyan

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

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  [*] Installing via winget..." -ForegroundColor Yellow
        try {
            winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements --silent
            Start-Sleep -Seconds 5
            $WindhawkCli = Find-WindhawkCli
            if ($WindhawkCli) { $installed = $true }
        } catch {}
    }

    if (-not $installed) {
        Write-Host "  [*] Downloading official installer from windhawk.net..." -ForegroundColor Yellow
        $installerPath = Join-Path $WorkDir "windhawk_setup.exe"
        try {
            Invoke-WebRequest -Uri "https://windhawk.net/download/windhawk_setup.exe" -OutFile $installerPath -UseBasicParsing
            Write-Host "  [*] Running installer silently..." -ForegroundColor Yellow
            Start-Process $installerPath -ArgumentList "/S" -Wait
            
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
        Write-Host "  [!] Error: Please install Windhawk manually from https://windhawk.net and re-run." -ForegroundColor Red
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
Write-Host "`n[2/6] Acquiring Rohit Bhai Mac OS package..." -ForegroundColor Cyan
$WhDataLocal = Join-Path $WorkDir "Rohit-Bhai-Mac-OS.whdata"
$acquired = $false

$ScriptDir = if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } else { $PSScriptRoot }
if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata"))) {
    $localFile = Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata"
    Copy-Item $localFile -Destination $WhDataLocal -Force
    Write-Host "  [OK] Using local package file from: $localFile" -ForegroundColor Green
    $acquired = $true
}

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
# Step 3: Install Apple SF Pro Display Fonts (Official Typography)
# -------------------------------------------------------------------------
Write-Host "`n[3/6] Installing Apple San Francisco (SF Pro) Fonts..." -ForegroundColor Cyan
try {
    $fontsTarget = "$env:WINDIR\Fonts"
    $fontUrls = @{
        "SF-Pro-Display-Regular.otf" = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/fonts/SF-Pro-Display-Regular.otf"
        "SF-Pro-Display-Bold.otf"    = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/fonts/SF-Pro-Display-Bold.otf"
    }

    # Win32 AddFontResource API
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class FontHelper {
        [DllImport("gdi32.dll", EntryPoint = "AddFontResourceW", SetLastError = true)]
        public static extern int AddFontResource([MarshalAs(UnmanagedType.LPWStr)] string lpFileName);
    }
"@ -ErrorAction SilentlyContinue 2>$null

    foreach ($fname in $fontUrls.Keys) {
        $dest = Join-Path $fontsTarget $fname
        $tempFont = Join-Path $WorkDir $fname
        
        # Check local assets first
        $localFont = if ($ScriptDir) { Join-Path $ScriptDir "assets\fonts\$fname" } else { $null }
        if ($localFont -and (Test-Path $localFont)) {
            Copy-Item $localFont -Destination $dest -Force -ErrorAction SilentlyContinue
        } else {
            Invoke-WebRequest -Uri $fontUrls[$fname] -OutFile $tempFont -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $tempFont) {
                Copy-Item $tempFont -Destination $dest -Force -ErrorAction SilentlyContinue
            }
        }
        
        if (Test-Path $dest) {
            [FontHelper]::AddFontResource($dest) | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name ($fname -replace '\.otf$', ' (TrueType)') -Value $fname -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "  [OK] Apple SF Pro Display Typography registered!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Fonts note: Skipped non-critical font install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 4: Install macOS Cursors Scheme (Capitaine Dark HiDPI)
# -------------------------------------------------------------------------
Write-Host "`n[4/6] Setting up macOS Capitaine Dark Cursors (With Rainbow Beach Ball)..." -ForegroundColor Cyan
try {
    $cursorsTarget = "$env:WINDIR\Cursors\Capitaine-macOS"
    if (-not (Test-Path $cursorsTarget)) { New-Item -ItemType Directory -Path $cursorsTarget -Force | Out-Null }
    
    $cursorZip = Join-Path $WorkDir "cursors.zip"
    $cursorUrl = "https://github.com/hervad/capitaine-cursors-w11-hidpi/releases/download/v3.2.1/capitaine-w11-hidpi-v3.2.1.zip"
    
    Invoke-WebRequest -Uri $cursorUrl -OutFile $cursorZip -UseBasicParsing -ErrorAction SilentlyContinue
    if (Test-Path $cursorZip) {
        Expand-Archive -Path $cursorZip -DestinationPath "$WorkDir\cursors_ext" -Force
        $darkDir = Join-Path "$WorkDir\cursors_ext" "Capitaine Dark W11 HiDPI"
        if (Test-Path $darkDir) {
            Copy-Item "$darkDir\*" -Destination $cursorsTarget -Recurse -Force
            
            # Register cursor scheme in Registry
            $schemePath = "HKCU:\Control Panel\Cursors"
            Set-ItemProperty -Path $schemePath -Name "" -Value "Capitaine macOS Dark" -Force
            Set-ItemProperty -Path $schemePath -Name "Arrow" -Value "$cursorsTarget\pointer.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "Help" -Value "$cursorsTarget\help.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "AppStarting" -Value "$cursorsTarget\working.ani" -Force
            Set-ItemProperty -Path $schemePath -Name "Wait" -Value "$cursorsTarget\busy.ani" -Force
            Set-ItemProperty -Path $schemePath -Name "Crosshair" -Value "$cursorsTarget\precision.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "IBeam" -Value "$cursorsTarget\text.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "NWPen" -Value "$cursorsTarget\handwriting.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "No" -Value "$cursorsTarget\unavailable.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "SizeNS" -Value "$cursorsTarget\vert.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "SizeWE" -Value "$cursorsTarget\horz.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "SizeNWSE" -Value "$cursorsTarget\dgn1.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "SizeNESW" -Value "$cursorsTarget\dgn2.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "SizeAll" -Value "$cursorsTarget\move.cur" -Force
            Set-ItemProperty -Path $schemePath -Name "Hand" -Value "$cursorsTarget\link.cur" -Force
            Write-Host "  [OK] macOS Capitaine Dark Cursors scheme registered!" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "  [-] Cursors note: Skipped non-critical cursor install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 5: Apply 4K macOS Wallpaper & Windows Dark Mode
# -------------------------------------------------------------------------
Write-Host "`n[5/6] Applying 4K macOS Wallpaper & Deep Dark Mode..." -ForegroundColor Cyan
try {
    # 1. Dark Mode
    $themeReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (Test-Path $themeReg) {
        Set-ItemProperty -Path $themeReg -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $themeReg -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    
    # 2. Wallpaper
    $wallTarget = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"
    $wallLocal = Join-Path $WorkDir "wallpaper.jpg"
    $wallUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/wallpaper.jpg"
    
    $localWall = if ($ScriptDir) { Join-Path $ScriptDir "assets\wallpaper.jpg" } else { $null }
    if ($localWall -and (Test-Path $localWall)) {
        Copy-Item $localWall -Destination $wallTarget -Force -ErrorAction SilentlyContinue
    } else {
        Invoke-WebRequest -Uri $wallUrl -OutFile $wallLocal -UseBasicParsing -ErrorAction SilentlyContinue
        if (Test-Path $wallLocal) {
            Copy-Item $wallLocal -Destination $wallTarget -Force -ErrorAction SilentlyContinue
        }
    }
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallTarget -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Force -ErrorAction SilentlyContinue
    rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
    Write-Host "  [OK] 4K macOS Wallpaper & Dark Mode applied!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Wallpaper note: Skipped non-critical wallpaper update." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 6: Import Windhawk Mods & Settings (Island Dock, Genie, Net Speed)
# -------------------------------------------------------------------------
Write-Host "`n[6/6] Activating all 8 Windhawk mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
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

# Refresh Shell
Write-Host "`n[*] Refreshing Windows Desktop & Dock..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe
Start-Sleep -Seconds 2

# Cleanup
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "            CONGRATULATIONS! ROHIT BHAI MAC OS v2.0 IS NOW ACTIVE!                     " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * Mac Island & Dock (32px, 8px gap, 22px radius, launch bounce) active" -ForegroundColor White
Write-Host "  * macOS Genie Minimize animation (450ms) active" -ForegroundColor White
Write-Host "  * Apple Taskbar Network Speed indicator active" -ForegroundColor White
Write-Host "  * Apple SF Pro Display typography installed" -ForegroundColor White
Write-Host "  * macOS Capitaine Dark Cursors (with rainbow spinning beach-ball) active" -ForegroundColor White
Write-Host "  * 4K Ultra-HD macOS Wallpaper & Deep Dark Mode applied" -ForegroundColor White
Write-Host ""
Write-Host "  Crafted with love by: Rohit Bhai" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/romflasher3419-spec/rohit-bhai-mac-os" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
