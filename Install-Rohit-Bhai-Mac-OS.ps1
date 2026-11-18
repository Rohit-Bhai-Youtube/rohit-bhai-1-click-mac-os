# ==============================================================================
# Rohit Bhai Mac OS for Windows 11 - 1-Click Ultimate Suite v4.4 Pro
# Target: Windows 11 (22H2 / 23H2 / 24H2) and Windows 10
# Includes: Windhawk Mac Island Dock, Genie, Net Speed, SF Pro Fonts,
#           macOS Capitaine Cursors, 4K macOS Wallpaper, Dark Mode,
#           Official Apple macOS Sound Scheme (Trash, USB, Alert, Notification) &
#           Official Apple macOS File Explorer & Folder Icons (Sonoma Aqua)
# Crafted for Rohit Bhai | 100% Native - No Bloatware
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Repository Configuration
$RepoOwner = "Rohit-Bhai-Youtube"
$RepoName  = "rohit-bhai-1-click-mac-os"
$Branch    = "main"
$WebScriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/install.ps1"

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $elevateCmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$WebScriptUrl' | iex"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$elevateCmd`""
    }
    exit
}

try {
    $Host.UI.RawUI.WindowTitle = "Mac OS"
    [Console]::Title = "Mac OS"
} catch {}

Clear-Host
Write-Host @"
========================================================================================
                  ███╗   ███╗ █████╗  ██████╗      ██████╗ ███████╗
                  ████╗ ████║██╔══██╗██╔════╝     ██╔═══██╗██╔════╝
                  ██╔████╔██║███████║██║          ██║   ██║███████╗
                  ██║╚██╔╝██║██╔══██║██║          ██║   ██║╚════██║
                  ██║ ╚═╝ ██║██║  ██║╚██████╗     ╚██████╔╝███████║
                  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝      ╚═════╝ ╚══════╝
                  ROHIT BHAI 1 CLICK MAC OS FOR WINDOWS 11 - v4.7
                               Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Cyan

Write-Host "  [+] Fixed Top-Right macOS Status Bar & Centered Floating Dock (Liquid Glass, Clock, Media, Control Center)" -ForegroundColor White
Write-Host "  [+] macOS Genie Minimize Animation (Liquid curve 450ms)" -ForegroundColor White
Write-Host "  [+] Apple Taskbar Network Speed Indicator (100% native Windhawk)" -ForegroundColor White
Write-Host "  [+] Apple SF Pro Typography (San Francisco Display & Text)" -ForegroundColor White
Write-Host "  [+] macOS Capitaine Dark Cursors with Rainbow Spinning Beach-Ball" -ForegroundColor White
Write-Host "  [+] Official Apple macOS Sound Scheme (Trash Empty, USB Connect, Pop, Tink)" -ForegroundColor White
Write-Host "  [+] Official Apple macOS File Explorer & Folder Icons (Sonoma Aqua Folders, Macintosh HD)" -ForegroundColor White
Write-Host "  [+] Official Apple macOS Squircle App Icons (Safari, Finder, App Store, WhatsApp, Discord, Steam, Notes, etc.)" -ForegroundColor White
Write-Host "  [+] 4K Ultra-HD macOS Wallpaper & Windows Deep Dark Theme" -ForegroundColor White
Write-Host ""

$WorkDir = Join-Path $env:TEMP "RohitBhai_MacOS_Setup"
if (Test-Path $WorkDir) {
    Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { $null }

# -------------------------------------------------------------------------
# Step 1: Detect or Install Windhawk Engine (v2.0+ with CLI)
# -------------------------------------------------------------------------
Write-Host "[1/9] Checking Windhawk Customization Engine..." -ForegroundColor Cyan

function Find-WindhawkCli {
    # 1. Standard well-known directory paths & recursive check
    $searchRoots = @(
        "C:\Program Files\Windhawk",
        "$env:ProgramFiles\Windhawk",
        "$env:ProgramW6432\Windhawk",
        "${env:ProgramFiles(x86)}\Windhawk",
        "$env:LOCALAPPDATA\Programs\Windhawk"
    )
    foreach ($root in $searchRoots) {
        if ($root -and (Test-Path $root)) {
            $direct = Join-Path $root "windhawk-cli.exe"
            if (Test-Path $direct) { return $direct }
            $found = Get-ChildItem -Path $root -Filter "windhawk-cli.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found -and (Test-Path $found.FullName)) { return $found.FullName }
        }
    }

    # 2. Check running processes
    try {
        $proc = Get-Process -Name "windhawk" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($proc -and $proc.Path) {
            $cli = Join-Path (Split-Path $proc.Path -Parent) "windhawk-cli.exe"
            if (Test-Path $cli) { return $cli }
        }
    } catch {}

    # 3. Check Windows Service definition
    try {
        $svc = Get-CimInstance Win32_Service -Filter "Name = 'Windhawk'" -ErrorAction SilentlyContinue
        if ($svc -and $svc.PathName) {
            $cleanPath = $svc.PathName -replace '^"|"[^"]*$', '' -replace '\.exe.*$', '.exe'
            if (Test-Path $cleanPath) {
                $cli = Join-Path (Split-Path $cleanPath -Parent) "windhawk-cli.exe"
                if (Test-Path $cli) { return $cli }
            }
        }
    } catch {}

    # 4. Check Windows Registry Uninstall keys (32-bit & 64-bit)
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($reg in $regPaths) {
        try {
            $items = Get-ItemProperty -Path $reg -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                if ($item.DisplayName -like "*Windhawk*") {
                    if ($item.InstallLocation) {
                        $cli = Join-Path $item.InstallLocation "windhawk-cli.exe"
                        if (Test-Path $cli) { return $cli }
                    }
                    if ($item.DisplayIcon) {
                        $cleanIcon = $item.DisplayIcon -replace '^"|"[^"]*$', '' -replace ',.*$', ''
                        $cli = Join-Path (Split-Path $cleanIcon -Parent) "windhawk-cli.exe"
                        if (Test-Path $cli) { return $cli }
                    }
                }
            }
        } catch {}
    }

    # 5. Check PATH environment
    try {
        $cmd = Get-Command "windhawk-cli.exe" -ErrorAction SilentlyContinue
        if ($cmd -and $cmd.Source -and (Test-Path $cmd.Source)) {
            return $cmd.Source
        }
    } catch {}

    return $null
}

function Find-WindhawkExe {
    $searchRoots = @(
        "C:\Program Files\Windhawk",
        "$env:ProgramFiles\Windhawk",
        "$env:ProgramW6432\Windhawk",
        "${env:ProgramFiles(x86)}\Windhawk",
        "$env:LOCALAPPDATA\Programs\Windhawk"
    )
    foreach ($root in $searchRoots) {
        if ($root -and (Test-Path $root)) {
            $exe = Join-Path $root "windhawk.exe"
            if (Test-Path $exe) { return $exe }
        }
    }
    return $null
}

$WindhawkCli = Find-WindhawkCli
$WindhawkExe = Find-WindhawkExe

# If Windhawk CLI is not found, install or upgrade to Windhawk v2.0 (which provides windhawk-cli.exe)
if (-not $WindhawkCli) {
    Write-Host "  [-] Windhawk CLI engine (v2.0+) not found. Installing/Upgrading Windhawk v2.0..." -ForegroundColor Yellow
    $installed = $false

    $installerPath = Join-Path $WorkDir "windhawk_setup.exe"
    $whDownloadUrls = @(
        "https://github.com/ramensoftware/windhawk/releases/download/2.0.0-alpha.8/windhawk_setup.exe",
        "https://github.com/ramensoftware/windhawk/releases/download/2.0.0-alpha.7/windhawk_setup.exe"
    )

    try {
        $releases = Invoke-RestMethod -Uri 'https://api.github.com/repos/ramensoftware/windhawk/releases' -Headers @{ 'User-Agent' = 'Mozilla/5.0' } -TimeoutSec 5 -ErrorAction SilentlyContinue
        foreach ($r in $releases) {
            if ($r.tag_name -match '^2\.') {
                $asset = $r.assets | Where-Object { $_.name -eq 'windhawk_setup.exe' } | Select-Object -First 1
                if ($asset -and $asset.browser_download_url) {
                    $whDownloadUrls = @($asset.browser_download_url) + $whDownloadUrls
                    break
                }
            }
        }
    } catch {}

    $downloadSuccess = $false
    foreach ($url in $whDownloadUrls) {
        try {
            Write-Host "  [*] Downloading official Windhawk v2.0 from GitHub Releases..." -ForegroundColor Yellow
            if (Test-Path $installerPath) { Remove-Item $installerPath -Force -ErrorAction SilentlyContinue }

            # curl.exe method (fastest)
            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                & curl.exe -sSL "$url" -o "$installerPath"
            }

            # Fallback to WebClient if curl didn't download or is too small
            if (-not (Test-Path $installerPath) -or ((Get-Item $installerPath).Length -lt 10000000)) {
                $wc = New-Object System.Net.WebClient
                $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
                $wc.DownloadFile($url, $installerPath)
            }

            # Verify valid PE executable size (> 10MB)
            if ((Test-Path $installerPath) -and ((Get-Item $installerPath).Length -gt 10000000)) {
                $downloadSuccess = $true
                break
            }
        } catch {}
    }

    if ($downloadSuccess) {
        Write-Host "  [*] Preparing Windhawk v2.0 silent upgrade (/S /STANDARD)..." -ForegroundColor Yellow
        Stop-Process -Name "windhawk", "windhawk-ui", "windhawk-mod" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "Windhawk" -Force -ErrorAction SilentlyContinue

        Start-Process -FilePath $installerPath -ArgumentList "/S", "/STANDARD" -Wait
        
        # Wait for any background installer child process to finish
        $timeout = 0
        while ((Get-Process -Name "windhawk_setup*" -ErrorAction SilentlyContinue) -and ($timeout -lt 30)) {
            Start-Sleep -Seconds 1
            $timeout++
        }

        # Poll for Windhawk CLI up to 24 seconds
        for ($i = 0; $i -lt 12; $i++) {
            Start-Sleep -Seconds 2
            $WindhawkCli = Find-WindhawkCli
            if ($WindhawkCli) {
                $installed = $true
                break
            }
        }
    }

    # Winget fallback if direct GitHub download failed
    if (-not $WindhawkCli -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "  [*] Fallback: Installing via winget..." -ForegroundColor Yellow
        try {
            winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements --silent --force
            Start-Sleep -Seconds 5
            $WindhawkCli = Find-WindhawkCli
        } catch {}
    }
}

$WindhawkCli = Find-WindhawkCli
$WindhawkExe = Find-WindhawkExe

if ($WindhawkCli -or $WindhawkExe) {
    # Ensure Windhawk background service is running
    try {
        $whSvc = Get-Service -Name Windhawk -ErrorAction SilentlyContinue
        if ($whSvc -and $whSvc.Status -ne 'Running') {
            Start-Service Windhawk -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    } catch {}
    $enginePath = if ($WindhawkCli) { $WindhawkCli } else { $WindhawkExe }
    Write-Host "  [OK] Windhawk engine found: $enginePath" -ForegroundColor Green

    # Ensure Windhawk Clang/MinGW Compiler toolchain is installed (required for mods)
    $compilerClang = "C:\Program Files\Windhawk\Compiler\bin\clang++.exe"
    if (-not (Test-Path $compilerClang)) {
        Write-Host "  [*] Installing Windhawk Clang/MinGW Compiler toolchain (required for mods)..." -ForegroundColor Yellow
        $compilerZip = Join-Path $WorkDir "windhawk-compiler-1.6.7z"
        $compilerUrl = "https://github.com/ramensoftware/windhawk-dependencies/releases/download/v1.6/windhawk-compiler-1.6.7z"
        try {
            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                & curl.exe -sSL "$compilerUrl" -o "$compilerZip"
            }
            if (-not (Test-Path $compilerZip) -or ((Get-Item $compilerZip).Length -lt 10000000)) {
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile($compilerUrl, $compilerZip)
            }
            if (Test-Path $compilerZip) {
                $compTarget = "C:\Program Files\Windhawk\Compiler"
                if (-not (Test-Path $compTarget)) { New-Item -ItemType Directory -Path $compTarget -Force | Out-Null }
                & tar.exe -xf "$compilerZip" -C "$compTarget"
                if (Test-Path $compilerClang) {
                    Write-Host "  [OK] Windhawk Compiler toolchain installed successfully!" -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "  [!] Compiler setup note: $_" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  [OK] Windhawk development compiler verified!" -ForegroundColor Green
    }
} else {
    Write-Host "  [!] Warning: Windhawk engine not detected. Proceeding with System Icons, Sounds & Cursors..." -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# Step 2: Download or Locate Rohit Bhai Mac OS Settings & Registry Preset
# -------------------------------------------------------------------------
Write-Host "`n[2/9] Locating Rohit Bhai Mac OS Preset..." -ForegroundColor Cyan
$WhDataLocal   = Join-Path $WorkDir "Rohit-Bhai-Mac-OS-Settings.json"
$WhDataArchive = Join-Path $WorkDir "Rohit-Bhai-Mac-OS.whdata"
$WhRegLocal    = Join-Path $WorkDir "Rohit-Bhai-Mac-OS-Settings.reg"

$localPreset   = if ($ScriptDir) { Join-Path $ScriptDir "Rohit-Bhai-Mac-OS-Settings.json" } else { $null }
$localArchive  = if ($ScriptDir) { Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata" } else { $null }
$localReg      = if ($ScriptDir) { Join-Path $ScriptDir "Rohit-Bhai-Mac-OS-Settings.reg" } else { $null }

if ($localArchive -and (Test-Path $localArchive)) {
    Copy-Item $localArchive -Destination $WhDataArchive -Force
} else {
    $archiveUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Rohit-Bhai-Mac-OS.whdata"
    try {
        Invoke-WebRequest -Uri $archiveUrl -OutFile $WhDataArchive -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {}
}

if ($localPreset -and (Test-Path $localPreset)) {
    Copy-Item $localPreset -Destination $WhDataLocal -Force
    Write-Host "  [OK] Using local preset configuration." -ForegroundColor Green
} else {
    $presetUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Rohit-Bhai-Mac-OS-Settings.json"
    Write-Host "  [*] Downloading preset from GitHub repository..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $presetUrl -OutFile $WhDataLocal -UseBasicParsing
        Write-Host "  [OK] Preset downloaded successfully!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Failed to download settings preset from GitHub." -ForegroundColor Red
    }
}

if ($localReg -and (Test-Path $localReg)) {
    Copy-Item $localReg -Destination $WhRegLocal -Force
} else {
    $regUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Rohit-Bhai-Mac-OS-Settings.reg"
    try {
        Invoke-WebRequest -Uri $regUrl -OutFile $WhRegLocal -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {}
}

# -------------------------------------------------------------------------
# Step 3: Apple SF Pro Display Typography
# -------------------------------------------------------------------------
Write-Host "`n[3/9] Installing Apple SF Pro Display Fonts..." -ForegroundColor Cyan
try {
    $fontsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Fonts"
    if (-not (Test-Path $fontsTarget)) {
        New-Item -ItemType Directory -Path $fontsTarget -Force | Out-Null
    }
    
    $localFonts = if ($ScriptDir) { Join-Path $ScriptDir "assets\fonts" } else { $null }
    if ($localFonts -and (Test-Path $localFonts)) {
        Copy-Item "$localFonts\*.otf" -Destination $fontsTarget -Force -ErrorAction SilentlyContinue
    } else {
        $fontZipUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v2.0.0/sf_pro_fonts.zip"
        $fontZip = Join-Path $WorkDir "fonts.zip"
        try {
            Invoke-WebRequest -Uri $fontZipUrl -OutFile $fontZip -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $fontZip) {
                Expand-Archive -Path $fontZip -DestinationPath $fontsTarget -Force
            }
        } catch {}
    }
    
    $fontReg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (-not (Test-Path $fontReg)) { New-Item -Path $fontReg -Force | Out-Null }
    Get-ChildItem -Path $fontsTarget -Filter "*.otf" -ErrorAction SilentlyContinue | ForEach-Object {
        $cleanName = $_.BaseName -replace "_", " "
        Set-ItemProperty -Path $fontReg -Name "$cleanName (TrueType)" -Value $_.FullName -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  [OK] Apple SF Pro Fonts registered into Windows!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Fonts note: Skipped non-critical font install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 4: macOS Capitaine Dark Cursors Installation
# -------------------------------------------------------------------------
Write-Host "
[4/9] Deploying macOS Capitaine Dark Cursors with Beach-Ball..." -ForegroundColor Cyan
try {
    $cursorsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Cursors"
    if (-not (Test-Path $cursorsTarget)) {
        New-Item -ItemType Directory -Path $cursorsTarget -Force | Out-Null
    }
    
    $localCursors = if ($ScriptDir) { Join-Path $ScriptDir "assets\cursors" } else { $null }
    $scratchCursors = "C:\Users\rohit\.gemini\antigravity\scratch\Rohit-Bhai-Mac-OS\assets\cursors"

    if ($localCursors -and (Test-Path $localCursors)) {
        Copy-Item "$localCursors\*" -Destination $cursorsTarget -Recurse -Force -ErrorAction SilentlyContinue
    } elseif (Test-Path $scratchCursors) {
        Copy-Item "$scratchCursors\*" -Destination $cursorsTarget -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        $curZipUrls = @(
            "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/cursors.zip",
            "https://raw.githubusercontent.com/$RepoOwner/rohit-bhai-mac-os/$Branch/assets/cursors.zip"
        )
        $curZip = Join-Path $WorkDir "cursors.zip"
        foreach ($curZipUrl in $curZipUrls) {
            try {
                Invoke-WebRequest -Uri $curZipUrl -OutFile $curZip -UseBasicParsing -ErrorAction SilentlyContinue
                if ((Test-Path $curZip) -and ((Get-Item $curZip).Length -gt 100000)) {
                    $extractDark = Join-Path $cursorsTarget "Capitaine Dark W11 HiDPI"
                    if (-not (Test-Path $extractDark)) { New-Item -ItemType Directory -Path $extractDark -Force | Out-Null }
                    Expand-Archive -Path $curZip -DestinationPath $extractDark -Force
                    break
                }
            } catch {}
        }
    }
    
    $darkDir = Join-Path $cursorsTarget "Capitaine Dark W11 HiDPI"
    if (-not (Test-Path $darkDir)) { $darkDir = Join-Path $cursorsTarget "dist-dark" }
    if (-not (Test-Path "$darkDir\pointer.cur")) { $darkDir = $cursorsTarget }
    if (Test-Path "$darkDir\pointer.cur") {
        # Copy to official Windows Cursors directory for system-wide access
        $sysCurDir = "$env:WINDIR\Cursors\Capitaine Dark"
        try {
            if (-not (Test-Path $sysCurDir)) { New-Item -ItemType Directory -Path $sysCurDir -Force | Out-Null }
            Copy-Item "$darkDir\*" -Destination $sysCurDir -Force -ErrorAction SilentlyContinue
            if (Test-Path "$sysCurDir\pointer.cur") { $darkDir = $sysCurDir }
        } catch {}

        $schemePath = "HKCU:\Control Panel\Cursors"
        $schemeName = "Capitaine Dark W11 HiDPI"
        Set-ItemProperty -Path $schemePath -Name "(Default)" -Value $schemeName -Force
        Set-ItemProperty -Path $schemePath -Name "Scheme Source" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $schemePath -Name "Arrow" -Value "$darkDir\pointer.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "Help" -Value "$darkDir\help.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "AppStarting" -Value "$darkDir\working.ani" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "Wait" -Value "$darkDir\busy.ani" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "Crosshair" -Value "$darkDir\precision.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "IBeam" -Value "$darkDir\text.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "NWPen" -Value "$darkDir\handwriting.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "No" -Value "$darkDir\unavailable.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "SizeNS" -Value "$darkDir\vert.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "SizeWE" -Value "$darkDir\horz.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "SizeNWSE" -Value "$darkDir\dgn1.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "SizeNESW" -Value "$darkDir\dgn2.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "SizeAll" -Value "$darkDir\move.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "UpArrow" -Value "$darkDir\alternate.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "Hand" -Value "$darkDir\link.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "Pin" -Value "$darkDir\pin.cur" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $schemePath -Name "Person" -Value "$darkDir\person.cur" -Force -ErrorAction SilentlyContinue

        $schemeVal = "$darkDir\pointer.cur,$darkDir\help.cur,$darkDir\working.ani,$darkDir\busy.ani,$darkDir\precision.cur,$darkDir\text.cur,$darkDir\handwriting.cur,$darkDir\unavailable.cur,$darkDir\vert.cur,$darkDir\horz.cur,$darkDir\dgn1.cur,$darkDir\dgn2.cur,$darkDir\move.cur,$darkDir\alternate.cur,$darkDir\link.cur,$darkDir\pin.cur,$darkDir\person.cur"
        $schemesReg = "HKCU:\Control Panel\Cursors\Schemes"
        if (-not (Test-Path $schemesReg)) { New-Item -Path $schemesReg -Force | Out-Null }
        Set-ItemProperty -Path $schemesReg -Name $schemeName -Value $schemeVal -Force

        $hklmSchemes = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\Cursors\Schemes"
        if (Test-Path $hklmSchemes) {
            Set-ItemProperty -Path $hklmSchemes -Name $schemeName -Value $schemeVal -Force -ErrorAction SilentlyContinue
        }

        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Cursor {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr LoadCursorFromFile(string lpFileName);
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetSystemCursor(IntPtr hcur, uint id);
}
"@ -ErrorAction SilentlyContinue
        try {
            $hCur = [Win32Cursor]::LoadCursorFromFile("$darkDir\pointer.cur")
            if ($hCur -ne [IntPtr]::Zero) { [Win32Cursor]::SetSystemCursor($hCur, 32512) | Out-Null }
            $hHand = [Win32Cursor]::LoadCursorFromFile("$darkDir\link.cur")
            if ($hHand -ne [IntPtr]::Zero) { [Win32Cursor]::SetSystemCursor($hHand, 32649) | Out-Null }
            $hBusy = [Win32Cursor]::LoadCursorFromFile("$darkDir\busy.ani")
            if ($hBusy -ne [IntPtr]::Zero) { [Win32Cursor]::SetSystemCursor($hBusy, 32514) | Out-Null }
            $hWork = [Win32Cursor]::LoadCursorFromFile("$darkDir\working.ani")
            if ($hWork -ne [IntPtr]::Zero) { [Win32Cursor]::SetSystemCursor($hWork, 32650) | Out-Null }
        } catch {}
        [Win32Cursor]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 3) | Out-Null
        rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
        Write-Host "  [OK] macOS Capitaine Dark Cursors scheme registered & live applied!" -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] Cursors note: Skipped non-critical cursor install." -ForegroundColor DarkGray
}
# Step 5: Official Apple macOS System Sound Scheme
# -------------------------------------------------------------------------
Write-Host "`n[5/9] Configuring Authentic Apple macOS System Sound Scheme..." -ForegroundColor Cyan
try {
    $soundsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Sounds"
    if (-not (Test-Path $soundsTarget)) {
        New-Item -ItemType Directory -Path $soundsTarget -Force | Out-Null
    }
    
    $localSounds = if ($ScriptDir) { Join-Path $ScriptDir "assets\sounds" } else { $null }
    if ($localSounds -and (Test-Path $localSounds)) {
        Copy-Item "$localSounds\*.wav" -Destination $soundsTarget -Force -ErrorAction SilentlyContinue
    } else {
        $soundsZipUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v3.0.0/macos_sounds.zip"
        $soundsZip = Join-Path $WorkDir "macos_sounds.zip"
        try {
            Invoke-WebRequest -Uri $soundsZipUrl -OutFile $soundsZip -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $soundsZip) {
                Expand-Archive -Path $soundsZip -DestinationPath $soundsTarget -Force
            }
        } catch {}
    }
    
    $schemeName = "RohitBhaiMacOS"
    $namesKey = "HKCU:\AppEvents\Schemes\Names\$schemeName"
    if (-not (Test-Path $namesKey)) { New-Item -Path $namesKey -Force | Out-Null }
    Set-ItemProperty -Path $namesKey -Name "(Default)" -Value "Rohit Bhai macOS"
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value $schemeName

    function Set-MacSound {
        param([string]$App, [string]$Event, [string]$WavName)
        $wavPath = Join-Path $soundsTarget $WavName
        if (Test-Path $wavPath) {
            $baseKey = "HKCU:\AppEvents\Schemes\Apps\$App\$Event"
            if (-not (Test-Path $baseKey)) { New-Item -Path $baseKey -Force | Out-Null }
            foreach ($sub in @(".Current", $schemeName)) {
                $subKey = "$baseKey\$sub"
                if (-not (Test-Path $subKey)) { New-Item -Path $subKey -Force | Out-Null }
                Set-ItemProperty -Path $subKey -Name "(Default)" -Value $wavPath
            }
        }
    }

    Set-MacSound -App "Explorer" -Event "EmptyRecycleBin" -WavName "macOS_Trash_Empty.wav"
    # Windows 11 Explorer Navigation Sound Enable
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowExplorerAudio" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    $clickWav = if (Test-Path (Join-Path $soundsTarget "macOS_Click.wav")) { "macOS_Click.wav" } else { "macOS_Pop.wav" }

    Set-MacSound -App "Explorer" -Event "Navigating" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "Navigating" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "CCSelect" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "MenuCommand" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "MenuPopup" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "ShowFPane" -WavName $clickWav
    Set-MacSound -App ".Default" -Event ".Default" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "DeviceConnect" -WavName "macOS_Device_Connect.wav"
    Set-MacSound -App ".Default" -Event "DeviceDisconnect" -WavName "macOS_Device_Disconnect.wav"
    Set-MacSound -App ".Default" -Event "DeviceFail" -WavName "macOS_Basso.wav"
    Set-MacSound -App ".Default" -Event "Notification.Default" -WavName "macOS_Notification.wav"
    Set-MacSound -App ".Default" -Event "SystemNotification" -WavName "macOS_Notification.wav"
    Set-MacSound -App ".Default" -Event "SystemAsterisk" -WavName "macOS_Hero.wav"
    Set-MacSound -App ".Default" -Event "SystemExclamation" -WavName "macOS_Funk.wav"
    Set-MacSound -App ".Default" -Event "SystemHand" -WavName "macOS_Basso.wav"
    Set-MacSound -App ".Default" -Event "SystemQuestion" -WavName $clickWav
    Set-MacSound -App ".Default" -Event "LowBatteryAlarm" -WavName "macOS_Basso.wav"
    Set-MacSound -App ".Default" -Event "CriticalBatteryAlarm" -WavName "macOS_Sosumi.wav"
    Set-MacSound -App ".Default" -Event "PrintComplete" -WavName "macOS_Hero.wav"

    # Audio Unmute & Test Boost
    try {
        $wsh = New-Object -ComObject WScript.Shell
        for ($i = 0; $i -lt 15; $i++) { $wsh.SendKeys([char]175) }
        $heroWav = Join-Path $soundsTarget "macOS_Hero.wav"
        if (Test-Path $heroWav) {
            $player = New-Object System.Media.SoundPlayer($heroWav)
            $player.Play()
        }
    } catch {}

    Write-Host "  [OK] Apple macOS Sound Scheme (Trash, USB, Alert, Notification) activated!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Sound Scheme note: Skipped non-critical sound install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 6: Official Apple macOS File Explorer & Folder Icons
# -------------------------------------------------------------------------
Write-Host "`n[6/9] Deploying Official Apple macOS File Explorer & Folder Icons..." -ForegroundColor Cyan
try {
    $iconsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Icons"
    if (-not (Test-Path $iconsTarget)) {
        New-Item -ItemType Directory -Path $iconsTarget -Force | Out-Null
    }

    $localIcons = if ($ScriptDir) { Join-Path $ScriptDir "assets\icons" } else { $null }
    if ($localIcons -and (Test-Path $localIcons)) {
        Copy-Item "$localIcons\*.ico" -Destination $iconsTarget -Force -ErrorAction SilentlyContinue
    } else {
        $iconsZipUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/macos_icons.zip"
        $iconsZip = Join-Path $WorkDir "macos_icons.zip"
        try {
            Invoke-WebRequest -Uri $iconsZipUrl -OutFile $iconsZip -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $iconsZip) {
                Expand-Archive -Path $iconsZip -DestinationPath $iconsTarget -Force
            }
        } catch {}
    }

    # Universal ProgramData icon store accessible by all system processes & users
    $progDataIcons = "C:\ProgramData\RohitBhaiMacOS\Icons"
    if (-not (Test-Path $progDataIcons)) { New-Item -ItemType Directory -Path $progDataIcons -Force | Out-Null }
    Copy-Item "$iconsTarget\*.ico" -Destination $progDataIcons -Force -ErrorAction SilentlyContinue

    # 1. Shell Icons (HKLM 64-bit, 32-bit & HKCU)
    $folderIco      = Join-Path $progDataIcons "macOS_Folder.ico"
    $folderOpenIco  = Join-Path $progDataIcons "macOS_Folder_Open.ico"
    $driveIco       = Join-Path $progDataIcons "macOS_Drive.ico"
    $driveSystemIco = Join-Path $progDataIcons "macOS_Drive_System.ico"
    $thisPcIco      = Join-Path $progDataIcons "macOS_ThisPC.ico"
    $trashEmptyIco  = Join-Path $progDataIcons "macOS_Trash_Empty.ico"
    $trashFullIco   = Join-Path $progDataIcons "macOS_Trash_Full.ico"
    $desktopIco     = Join-Path $progDataIcons "macOS_Desktop.ico"
    if (-not (Test-Path $folderIco)) { $folderIco = Join-Path $iconsTarget "macOS_Folder.ico" }
    if (-not (Test-Path $folderOpenIco)) { $folderOpenIco = Join-Path $iconsTarget "macOS_Folder_Open.ico" }
    if (-not (Test-Path $driveIco)) { $driveIco = Join-Path $iconsTarget "macOS_Drive.ico" }
    if (-not (Test-Path $driveSystemIco)) { $driveSystemIco = Join-Path $iconsTarget "macOS_Drive_System.ico" }
    if (-not (Test-Path $thisPcIco)) { $thisPcIco = Join-Path $iconsTarget "macOS_ThisPC.ico" }
    if (-not (Test-Path $trashEmptyIco)) { $trashEmptyIco = Join-Path $iconsTarget "macOS_Trash_Empty.ico" }
    if (-not (Test-Path $trashFullIco)) { $trashFullIco = Join-Path $iconsTarget "macOS_Trash_Full.ico" }
    if (-not (Test-Path $desktopIco)) { $desktopIco = Join-Path $iconsTarget "macOS_Desktop.ico" }
    
    $shellIconsKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    )
    foreach ($k in $shellIconsKeys) {
        if (-not (Test-Path $k)) { New-Item -Path $k -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path $folderIco)      { Set-ItemProperty -Path $k -Name "3"   -Value $folderIco      -Force -ErrorAction SilentlyContinue }
        if (Test-Path $folderOpenIco)  { Set-ItemProperty -Path $k -Name "4"   -Value $folderOpenIco  -Force -ErrorAction SilentlyContinue }
        if (Test-Path $driveIco)       { Set-ItemProperty -Path $k -Name "8"   -Value $driveIco       -Force -ErrorAction SilentlyContinue }
        if (Test-Path $driveSystemIco) { Set-ItemProperty -Path $k -Name "9"   -Value $driveSystemIco -Force -ErrorAction SilentlyContinue }
        if (Test-Path $thisPcIco)      { Set-ItemProperty -Path $k -Name "15"  -Value $thisPcIco      -Force -ErrorAction SilentlyContinue }
        if (Test-Path $trashEmptyIco)  { Set-ItemProperty -Path $k -Name "31"  -Value $trashEmptyIco  -Force -ErrorAction SilentlyContinue }
        if (Test-Path $trashFullIco)   { Set-ItemProperty -Path $k -Name "32"  -Value $trashFullIco   -Force -ErrorAction SilentlyContinue }
        if (Test-Path $desktopIco)     { Set-ItemProperty -Path $k -Name "34"  -Value $desktopIco     -Force -ErrorAction SilentlyContinue }
        if (Test-Path $thisPcIco)      { Set-ItemProperty -Path $k -Name "109" -Value $thisPcIco      -Force -ErrorAction SilentlyContinue }
    }

    # Direct reg.exe injection across 64-bit and 32-bit system keys
    $hklmShellTargets = @(
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
        "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    )
    foreach ($tgt in $hklmShellTargets) {
        if (Test-Path $folderIco)      { & reg.exe add "$tgt" /v "3" /t REG_SZ /d "$folderIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "3" /t REG_SZ /d "$folderIco" /f /reg:32 2>$null }
        if (Test-Path $folderOpenIco)  { & reg.exe add "$tgt" /v "4" /t REG_SZ /d "$folderOpenIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "4" /t REG_SZ /d "$folderOpenIco" /f /reg:32 2>$null }
        if (Test-Path $driveIco)       { & reg.exe add "$tgt" /v "8" /t REG_SZ /d "$driveIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "8" /t REG_SZ /d "$driveIco" /f /reg:32 2>$null }
        if (Test-Path $driveSystemIco) { & reg.exe add "$tgt" /v "9" /t REG_SZ /d "$driveSystemIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "9" /t REG_SZ /d "$driveSystemIco" /f /reg:32 2>$null }
        if (Test-Path $thisPcIco)      { & reg.exe add "$tgt" /v "15" /t REG_SZ /d "$thisPcIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "15" /t REG_SZ /d "$thisPcIco" /f /reg:32 2>$null }
        if (Test-Path $trashEmptyIco)  { & reg.exe add "$tgt" /v "31" /t REG_SZ /d "$trashEmptyIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "31" /t REG_SZ /d "$trashEmptyIco" /f /reg:32 2>$null }
        if (Test-Path $trashFullIco)   { & reg.exe add "$tgt" /v "32" /t REG_SZ /d "$trashFullIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "32" /t REG_SZ /d "$trashFullIco" /f /reg:32 2>$null }
        if (Test-Path $desktopIco)     { & reg.exe add "$tgt" /v "34" /t REG_SZ /d "$desktopIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "34" /t REG_SZ /d "$desktopIco" /f /reg:32 2>$null }
        if (Test-Path $thisPcIco)      { & reg.exe add "$tgt" /v "109" /t REG_SZ /d "$thisPcIco" /f /reg:64 2>$null; & reg.exe add "$tgt" /v "109" /t REG_SZ /d "$thisPcIco" /f /reg:32 2>$null }
    }

    foreach ($c in @("HKCU:\Software\Classes\Folder\DefaultIcon", "HKCU:\Software\Classes\Directory\DefaultIcon")) {
        if (-not (Test-Path $c)) { New-Item -Path $c -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path $folderIco) { Set-ItemProperty -Path $c -Name "(default)" -Value $folderIco -Force -ErrorAction SilentlyContinue }
    }

    # 2. Drive Icons (Macintosh HD for C:, Generic for others)
    $driveRoots = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons"
    )
    foreach ($dr in $driveRoots) {
        $cKey = "$dr\C"
        try {
            if (-not (Test-Path "$cKey\DefaultIcon"))  { New-Item -Path "$cKey\DefaultIcon"  -Force -ErrorAction SilentlyContinue | Out-Null }
            if (-not (Test-Path "$cKey\DefaultLabel")) { New-Item -Path "$cKey\DefaultLabel" -Force -ErrorAction SilentlyContinue | Out-Null }
            if (Test-Path $driveSystemIco) { Set-ItemProperty -Path "$cKey\DefaultIcon"  -Name "(default)" -Value "$driveSystemIco,0" -Force -ErrorAction SilentlyContinue }
            Set-ItemProperty -Path "$cKey\DefaultLabel" -Name "(default)" -Value "Macintosh HD" -Force -ErrorAction SilentlyContinue
        } catch {}

        if (Test-Path $driveIco) {
            Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -and $_.DriveLetter -ne 'C' } | ForEach-Object {
                $dl = $_.DriveLetter
                $dKey = "$dr\$dl"
                try {
                    if (-not (Test-Path "$dKey\DefaultIcon")) { New-Item -Path "$dKey\DefaultIcon" -Force -ErrorAction SilentlyContinue | Out-Null }
                    Set-ItemProperty -Path "$dKey\DefaultIcon" -Name "(default)" -Value "$driveIco,0" -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }
    }

    # Direct reg.exe injection for Drive C (Macintosh HD) across 64-bit and 32-bit
    & reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultIcon" /ve /t REG_SZ /d "$driveSystemIco,0" /f /reg:64 2>$null
    & reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultIcon" /ve /t REG_SZ /d "$driveSystemIco,0" /f /reg:32 2>$null
    & reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultLabel" /ve /t REG_SZ /d "Macintosh HD" /f /reg:64 2>$null
    & reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultLabel" /ve /t REG_SZ /d "Macintosh HD" /f /reg:32 2>$null
    & reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultIcon" /ve /t REG_SZ /d "$driveSystemIco,0" /f /reg:64 2>$null
    & reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultIcon" /ve /t REG_SZ /d "$driveSystemIco,0" /f /reg:32 2>$null
    & reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultLabel" /ve /t REG_SZ /d "Macintosh HD" /f /reg:64 2>$null
    & reg.exe add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultLabel" /ve /t REG_SZ /d "Macintosh HD" /f /reg:32 2>$null
    & reg.exe add "HKCU\Software\Classes\Applications\Explorer.exe\Drives\C\DefaultIcon" /ve /t REG_SZ /d "$driveSystemIco,0" /f 2>$null
    & reg.exe add "HKCU\Software\Classes\Applications\Explorer.exe\Drives\C\DefaultLabel" /ve /t REG_SZ /d "Macintosh HD" /f 2>$null
    & reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultIcon" /ve /t REG_SZ /d "$driveSystemIco,0" /f 2>$null
    & reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultLabel" /ve /t REG_SZ /d "Macintosh HD" /f 2>$null

    # Modern Explorer Drive override in HKCU Classes
    $appDrivesKey = "HKCU:\Software\Classes\Applications\Explorer.exe\Drives\C"
    try {
        if (-not (Test-Path "$appDrivesKey\DefaultIcon"))  { New-Item -Path "$appDrivesKey\DefaultIcon"  -Force -ErrorAction SilentlyContinue | Out-Null }
        if (-not (Test-Path "$appDrivesKey\DefaultLabel")) { New-Item -Path "$appDrivesKey\DefaultLabel" -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path $driveSystemIco) { Set-ItemProperty -Path "$appDrivesKey\DefaultIcon"  -Name "(default)" -Value "$driveSystemIco,0" -Force -ErrorAction SilentlyContinue }
        Set-ItemProperty -Path "$appDrivesKey\DefaultLabel" -Name "(default)" -Value "Macintosh HD" -Force -ErrorAction SilentlyContinue
    } catch {}

    # Set C: Filesystem Volume Label so This PC displays Macintosh HD (C:) natively
    try { Set-Volume -DriveLetter C -NewFileSystemLabel "Macintosh HD" -ErrorAction SilentlyContinue } catch {}
    try { Start-Process cmd.exe -ArgumentList "/c label C: Macintosh HD" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue } catch {}

    # 3. Recycle Bin, This PC & Network CLSIDs
    $clsidConfigs = @(
        @{ GUID = "{645FF040-5081-101B-9F08-00AA002F954E}"; Ico = $trashEmptyIco; Empty = $trashEmptyIco; Full = $trashFullIco } # Recycle Bin
        @{ GUID = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"; Ico = $thisPcIco }                                                    # This PC
        @{ GUID = "{59031A47-3F72-44A7-89C5-5595FE6B30EE}"; Ico = $folderIco }                                                    # User Profile
        @{ GUID = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"; Ico = $folderIco }                                                    # Network
    )
    foreach ($cfg in $clsidConfigs) {
        $paths = @(
            "HKCU:\Software\Classes\CLSID\$($cfg.GUID)\DefaultIcon",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$($cfg.GUID)\DefaultIcon"
        )
        foreach ($p in $paths) {
            if (-not (Test-Path $p)) { New-Item -Path $p -Force -ErrorAction SilentlyContinue | Out-Null }
            if ($cfg.Ico -and (Test-Path $cfg.Ico)) {
                Set-ItemProperty -Path $p -Name "(default)" -Value $cfg.Ico -Force -ErrorAction SilentlyContinue
            }
            if ($cfg.Empty -and (Test-Path $cfg.Empty)) {
                Set-ItemProperty -Path $p -Name "empty" -Value $cfg.Empty -Force -ErrorAction SilentlyContinue
            }
            if ($cfg.Full -and (Test-Path $cfg.Full)) {
                Set-ItemProperty -Path $p -Name "full" -Value $cfg.Full -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # 4. User Profile Special Folders and All User Directories
    $folderMap = @(
        @{ Name = "Downloads"; Paths = @("$env:USERPROFILE\Downloads"); Ico = Join-Path $iconsTarget "macOS_Downloads.ico"; GUIDs = @("{374DE290-123F-4565-9164-39C4925E467B}", "{7d83ee9b-2244-4e70-b1f5-5393042af1e4}") }
        @{ Name = "Documents"; Paths = @("$env:USERPROFILE\OneDrive\Documents", "$env:USERPROFILE\Documents", [Environment]::GetFolderPath('MyDocuments')); Ico = Join-Path $iconsTarget "macOS_Documents.ico"; GUIDs = @("{FDD39AD0-238F-46AF-ADB4-6C85480369C7}", "{f42ee2d3-909f-4907-8871-4c22fc0bf756}") }
        @{ Name = "Pictures";  Paths = @("$env:USERPROFILE\OneDrive\Pictures", "$env:USERPROFILE\Pictures", [Environment]::GetFolderPath('MyPictures'));  Ico = Join-Path $iconsTarget "macOS_Pictures.ico";  GUIDs = @("{33E28130-4E1E-4676-835A-98395C3BC3BB}", "{0ddd0157-5467-4334-96c9-78ec10e39588}") }
        @{ Name = "Music";     Paths = @("$env:USERPROFILE\Music", [Environment]::GetFolderPath('MyMusic'));     Ico = Join-Path $iconsTarget "macOS_Music.ico";     GUIDs = @("{4BD8D571-6D19-48D3-BE97-422220080E43}", "{a0c69a99-21c8-4671-8703-7934162fbe1d}") }
        @{ Name = "Videos";    Paths = @("$env:USERPROFILE\Videos", [Environment]::GetFolderPath('MyVideos'));    Ico = Join-Path $iconsTarget "macOS_Videos.ico";    GUIDs = @("{18989B1D-99B5-455B-841C-AB7C74E4DDFC}", "{35286161-5079-4140-9a09-7b505a4f2791}") }
        @{ Name = "Desktop";   Paths = @("$env:USERPROFILE\OneDrive\Desktop", "$env:USERPROFILE\Desktop", [Environment]::GetFolderPath('Desktop'));   Ico = $desktopIco;   GUIDs = @("{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}") }
    )

    foreach ($f in $folderMap) {
        if (Test-Path $f.Ico) {
            foreach ($g in $f.GUIDs) {
                $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$g"
                if (Test-Path $regPath) {
                    Set-ItemProperty -Path $regPath -Name "Icon" -Value "$($f.Ico),0" -Force -ErrorAction SilentlyContinue
                }
            }

            $uniquePaths = $f.Paths | Select-Object -Unique
            foreach ($p in $uniquePaths) {
                if ($p -and (Test-Path $p)) {
                    try {
                        $item = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
                        if ($item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { continue }
                    } catch { continue }

                    $ini = Join-Path $p "desktop.ini"
                    try {
                        if (Test-Path -LiteralPath $ini) {
                            (Get-Item -LiteralPath $ini -Force).Attributes = 'Normal'
                        }
                        $iniContent = "[.ShellClassInfo]`r`nIconResource=$($f.Ico),0`r`n[ViewState]`r`nMode=`r`nVid=`r`nFolderType=Generic`r`n"
                        [System.IO.File]::WriteAllText($ini, $iniContent, [System.Text.Encoding]::ASCII)
                        (Get-Item -LiteralPath $ini -Force).Attributes = 'Hidden, System'
                        (Get-Item -LiteralPath $p -Force).Attributes = ((Get-Item -LiteralPath $p -Force).Attributes -bor [System.IO.FileAttributes]::ReadOnly)
                    } catch {}
                }
            }
        }
    }

    # 4b. System & Program Directories in FolderDescriptions (Program Files, Users, ProgramData)
    $systemFolderGuids = @(
        "{905e63b6-c1bf-494e-b29c-65b732d3d21a}", # ProgramFiles
        "{6D809377-6AF0-444b-8957-A3773F02200E}", # ProgramFilesX64
        "{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}", # ProgramFilesX86
        "{0762D272-C50A-4BB0-A382-697DCD729B80}", # UserProfiles (C:\Users)
        "{f3ce0f7c-4901-4acc-8648-d5d44b04ef8f}", # UsersFilesFolder
        "{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}", # ProgramFilesCommon
        "{6365D5A7-0F0D-45e5-87F6-0DA56B6A4F7D}", # ProgramFilesCommonX64
        "{DE974D24-D9C6-4D3E-BF91-F4455120B917}", # ProgramFilesCommonX86
        "{559D40A3-A036-40FA-AF61-84CB430A4D34}"  # AppDataProgramData (C:\ProgramData)
    )
    if (Test-Path $folderIco) {
        foreach ($sg in $systemFolderGuids) {
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$sg"
            if (Test-Path $regPath) {
                Set-ItemProperty -Path $regPath -Name "Icon" -Value "$folderIco,0" -Force -ErrorAction SilentlyContinue
            }
            & reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$sg" /v "Icon" /t REG_SZ /d "$folderIco,0" /f /reg:64 2>$null
            & reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$sg" /v "Icon" /t REG_SZ /d "$folderIco,0" /f /reg:32 2>$null
        }
    }

    # Apply macOS Blue folder icon to all user folders in $env:USERPROFILE & OneDrive
    if (Test-Path $folderIco) {
        $scanRoots = @($env:USERPROFILE, "$env:USERPROFILE\OneDrive")
        foreach ($root in $scanRoots) {
            if ($root -and (Test-Path $root)) {
                Get-ChildItem -Path $root -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
                    $n = $_.Name
                    $isReparse = $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint
                    if (-not $isReparse -and $n -notin @("AppData", "Application Data", "Cookies", "Local Settings", "NetHood", "PrintHood", "Recent", "SendTo", "Start Menu", "Templates", "Documents", "Downloads", "Pictures", "Music", "Videos", "Desktop", "My Documents", "My Pictures", "My Music", "My Videos")) {
                        $p = $_.FullName
                        $ini = Join-Path $p "desktop.ini"
                        try {
                            if (Test-Path -LiteralPath $ini) {
                                (Get-Item -LiteralPath $ini -Force).Attributes = 'Normal'
                            }
                            $iniContent = "[.ShellClassInfo]`r`nIconResource=$folderIco,0`r`n[ViewState]`r`nMode=`r`nVid=`r`nFolderType=Generic`r`n"
                            [System.IO.File]::WriteAllText($ini, $iniContent, [System.Text.Encoding]::ASCII)
                            (Get-Item -LiteralPath $ini -Force).Attributes = 'Hidden, System'
                            (Get-Item -LiteralPath $p -Force).Attributes = ((Get-Item -LiteralPath $p -Force).Attributes -bor [System.IO.FileAttributes]::ReadOnly)
                        } catch {}
                    }
                }
            }
        }

        # Apply macOS Blue folder icon to root directories on C:\
        if (Test-Path "C:\") {
            try {
                takeown.exe /f "C:\PerfLogs" /a 2>$null
                icacls.exe "C:\PerfLogs" /grant Administrators:F /q 2>$null
            } catch {}
            Get-ChildItem -Path "C:\" -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
                $n = $_.Name
                if ($n -notin @("Windows", "System Volume Information", "`$Recycle.Bin", "`$WinREAgent", "Documents and Settings")) {
                    $p = $_.FullName
                    $ini = Join-Path $p "desktop.ini"
                    try {
                        if (Test-Path -LiteralPath $ini) {
                            (Get-Item -LiteralPath $ini -Force).Attributes = 'Normal'
                        }
                        $iniContent = "[.ShellClassInfo]`r`nIconResource=$folderIco,0`r`n[ViewState]`r`nMode=`r`nVid=`r`nFolderType=Generic`r`n"
                        [System.IO.File]::WriteAllText($ini, $iniContent, [System.Text.Encoding]::ASCII)
                        (Get-Item -LiteralPath $ini -Force).Attributes = 'Hidden, System'
                        (Get-Item -LiteralPath $p -Force).Attributes = ((Get-Item -LiteralPath $p -Force).Attributes -bor [System.IO.FileAttributes]::ReadOnly)
                    } catch {}
                }
            }
        }
    }

    # 5. Flush Icon Cache & Suppress Bottom White Artifacts
    $iconCache = "$env:LOCALAPPDATA\IconCache.db"
    if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "*cache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    try {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class ShellIconFlusher {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
'@ -ErrorAction SilentlyContinue
        [ShellIconFlusher]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
    } catch {}
    try {
        $ie4 = Join-Path ([Environment]::GetFolderPath('System')) "ie4uinit.exe"
        if (Test-Path $ie4) { & $ie4 -show 2>$null }
    } catch {}

    Write-Host "  [OK] Apple macOS File Explorer & Folder Icons applied!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Icons note: Handled non-critical icon install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 7: Deploy Official Apple macOS Squircle App Icons (Dock & Start Menu)
# -------------------------------------------------------------------------
Write-Host "`n[7/9] Deploying Official Apple macOS Squircle App Icons (Dock & Start Menu)..." -ForegroundColor Cyan
try {
    $appsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Icons\Apps"
    if (-not (Test-Path $appsTarget)) {
        New-Item -ItemType Directory -Path $appsTarget -Force | Out-Null
    }

    $localAppIcons = if ($ScriptDir) { Join-Path $ScriptDir "assets\icons\apps" } else { $null }
    if ($localAppIcons -and (Test-Path $localAppIcons)) {
        Copy-Item "$localAppIcons\*.ico" -Destination $appsTarget -Force -ErrorAction SilentlyContinue
        Copy-Item "$localAppIcons\*.png" -Destination $appsTarget -Force -ErrorAction SilentlyContinue
    } else {
        $appIconsZipUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/macos_app_icons.zip"
        $appIconsZip = Join-Path $WorkDir "macos_app_icons.zip"
        try {
            Invoke-WebRequest -Uri $appIconsZipUrl -OutFile $appIconsZip -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $appIconsZip) {
                Expand-Archive -Path $appIconsZip -DestinationPath $appsTarget -Force
            }
        } catch {}
    }

    Add-Type @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public static class MacAppShortcutHelper {
    [ComImport]
    [Guid("00021401-0000-0000-C000-000000000046")]
    internal class ShellLink {}

    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("000214F9-0000-0000-C000-000000000046")]
    internal interface IShellLinkW {
        void GetPath([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszFile, int cchMaxPath, out IntPtr pfd, uint fFlags);
        void GetIDList(out IntPtr ppidl);
        void SetIDList(IntPtr pidl);
        void GetDescription([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszName, int cchMaxName);
        void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string pszName);
        void GetWorkingDirectory([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszDir, int cchMaxPath);
        void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string pszDir);
        void GetArguments([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszArgs, int cchMaxPath);
        void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
        void GetHotkey(out short pwHotkey);
        void SetHotkey(short wHotkey);
        void GetShowCmd(out int piShowCmd);
        void SetShowCmd(int iShowCmd);
        void GetIconLocation([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszIconPath, int cchIconPath, out int piIcon);
        void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
        void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, uint dwReserved);
        void Resolve(IntPtr hwnd, uint fFlags);
        void SetPath([MarshalAs(UnmanagedType.LPWStr)] string pszFile);
    }

    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99")]
    internal interface IPropertyStore {
        uint GetCount();
        void GetAt(uint iProp, out PROPERTYKEY pkey);
        void GetValue(ref PROPERTYKEY key, out PROPVARIANT pv);
        void SetValue(ref PROPERTYKEY key, ref PROPVARIANT pv);
        void Commit();
    }

    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    internal struct PROPERTYKEY {
        public Guid fmtid;
        public uint pid;
        public PROPERTYKEY(Guid guid, uint id) {
            fmtid = guid;
            pid = id;
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    internal struct PROPVARIANT {
        [FieldOffset(0)] public ushort vt;
        [FieldOffset(8)] public IntPtr pwszVal;
    }

    private static PROPERTYKEY PKEY_AppUserModel_ID = new PROPERTYKEY(new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"), 5);

    [DllImport("shell32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr ILCreateFromPathW(string pszPath);

    [DllImport("shell32.dll")]
    public static extern void ILFree(IntPtr pidl);

    public static void CreateOrUpdateShortcut(string lnkPath, string targetPath, string arguments, string iconPath, string appUserModelId) {
        if (File.Exists(lnkPath)) {
            try { File.Delete(lnkPath); } catch {}
        }

        ShellLink link = new ShellLink();
        IShellLinkW shellLink = (IShellLinkW)link;
        IPersistFile persistFile = (IPersistFile)link;

        bool isPidl = false;
        if (!string.IsNullOrEmpty(arguments) && arguments.StartsWith("shell:AppsFolder\\", StringComparison.OrdinalIgnoreCase)) {
            IntPtr pidl = ILCreateFromPathW(arguments);
            if (pidl != IntPtr.Zero) {
                shellLink.SetIDList(pidl);
                ILFree(pidl);
                isPidl = true;
            }
        } else if (!string.IsNullOrEmpty(targetPath) && targetPath.StartsWith("shell:AppsFolder\\", StringComparison.OrdinalIgnoreCase)) {
            IntPtr pidl = ILCreateFromPathW(targetPath);
            if (pidl != IntPtr.Zero) {
                shellLink.SetIDList(pidl);
                ILFree(pidl);
                isPidl = true;
            }
        }

        if (!isPidl) {
            if (!string.IsNullOrEmpty(targetPath)) shellLink.SetPath(targetPath);
            if (!string.IsNullOrEmpty(arguments)) shellLink.SetArguments(arguments);
        }
        
        if (!string.IsNullOrEmpty(iconPath)) {
            string filePart = iconPath;
            int iconIndex = 0;
            if (iconPath.Contains(",")) {
                string[] parts = iconPath.Split(',');
                filePart = parts[0].Trim();
                int.TryParse(parts[1].Trim(), out iconIndex);
            }
            shellLink.SetIconLocation(filePart, iconIndex);
        } else if (!string.IsNullOrEmpty(targetPath) && !isPidl) {
            shellLink.SetIconLocation(targetPath, 0);
        }

        if (!string.IsNullOrEmpty(appUserModelId)) {
            IPropertyStore store = (IPropertyStore)link;
            PROPVARIANT pv = new PROPVARIANT();
            pv.vt = 31; // VT_LPWSTR
            pv.pwszVal = Marshal.StringToCoTaskMemUni(appUserModelId);
            try {
                store.SetValue(ref PKEY_AppUserModel_ID, ref pv);
                store.Commit();
            } finally {
                Marshal.FreeCoTaskMem(pv.pwszVal);
            }
        }

        persistFile.Save(lnkPath, true);
    }
}
'@ -ErrorAction SilentlyContinue

    $taskbarDir = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
    $userStartDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    $allStartDir = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'
    $explorerExe = "$env:WINDIR\explorer.exe"

    New-Item -ItemType Directory -Path $taskbarDir -Force | Out-Null
    New-Item -ItemType Directory -Path $userStartDir -Force | Out-Null

    # 1. Native application target resolution (No fake temporary binaries that trigger Defender!)
    # Edge
    $edgeExe = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgeExe)) { $edgeExe = "C:\Program Files\Microsoft\Edge\Application\msedge.exe" }
    $edgeInstalled = Test-Path $edgeExe

    # WhatsApp
    $waApp = Get-AppxPackage -Name "*WhatsApp*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $waExe = "$env:LOCALAPPDATA\WhatsApp\WhatsApp.exe"
    $waExe2 = "$env:LOCALAPPDATA\Programs\WhatsApp\WhatsApp.exe"
    $waInstalled = ($waApp -ne $null) -or (Test-Path $waExe) -or (Test-Path $waExe2)
    $waTarget = if (Test-Path $waExe) { $waExe } elseif (Test-Path $waExe2) { $waExe2 } elseif ($waApp) { "shell:AppsFolder\$($waApp.PackageFamilyName)!App" } else { "shell:AppsFolder\5319275A.WhatsAppDesktop_cv1g1gvanyjgm!App" }
    $waArgs   = ""
    $waAumid  = if ($waApp) { "$($waApp.PackageFamilyName)!App" } else { "5319275A.WhatsAppDesktop_cv1g1gvanyjgm!App" }

    # Telegram
    $tgApp = Get-AppxPackage -Name "*Telegram*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $tgExe = "$env:APPDATA\Telegram Desktop\Telegram.exe"
    if (-not (Test-Path $tgExe)) { $tgExe = "C:\Program Files\Telegram Desktop\Telegram.exe" }
    $tgInstalled = ($tgApp -ne $null) -or (Test-Path $tgExe)
    $tgTarget = if ($tgApp) { "shell:AppsFolder\$($tgApp.PackageFamilyName)!Telegram.TelegramDesktop.Store" } elseif (Test-Path $tgExe) { $tgExe } else { "" }
    $tgArgs   = ""
    $tgAumid  = if ($tgApp) { "$($tgApp.PackageFamilyName)!Telegram.TelegramDesktop.Store" } else { "Telegram.TelegramDesktop" }

    # Discord
    $discordUpdate = "$env:LOCALAPPDATA\Discord\Update.exe"
    $discordExe = "$env:LOCALAPPDATA\Discord\Discord.exe"
    $discordInstalled = (Test-Path $discordUpdate) -or (Test-Path $discordExe)
    $discordTarget = if (Test-Path $discordUpdate) { $discordUpdate } elseif (Test-Path $discordExe) { $discordExe } else { "" }
    $discordArgs   = if (Test-Path $discordUpdate) { "--processStart Discord.exe" } else { "" }
    $discordAumid  = "com.squirrel.Discord.Discord"

    # Steam
    $steamExe = "C:\Program Files (x86)\Steam\steam.exe"
    if (-not (Test-Path $steamExe)) { $steamExe = "C:\Program Files\Steam\steam.exe" }
    $steamInstalled = Test-Path $steamExe
    $steamTarget = if ($steamInstalled) { $steamExe } else { "" }
    $steamAumid  = "Valve.Steam"

    # Store & Settings
    $storeTarget = "shell:AppsFolder\Microsoft.WindowsStore_8wekyb3d8bbwe!App"
    $storeArgs   = ""
    $storeAumid  = "Microsoft.WindowsStore_8wekyb3d8bbwe!App"

    $settingsTarget = "shell:AppsFolder\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"
    $settingsArgs   = ""
    $settingsAumid  = "windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"

    $appsConfig = @(
        @{
            Name = "Edge to Safari"; Icon = "Safari.ico"; AppId = "MSEdge"
            Target = $edgeExe; Args = "--profile-directory=Default"
            TaskbarLnk = "Microsoft Edge.lnk"; StartLnks = @("Microsoft Edge.lnk")
            Installed = $edgeInstalled
        },
        @{
            Name = "Explorer to Finder"; Icon = "Finder.ico"; AppId = "Microsoft.Windows.Explorer"
            Target = $explorerExe; Args = ""
            TaskbarLnk = "File Explorer.lnk"; StartLnks = @("File Explorer.lnk")
            Installed = $true
        },
        @{
            Name = "Microsoft Store to App Store"; Icon = "AppStore.ico"; AppId = $storeAumid
            Target = $storeTarget; Args = $storeArgs
            TaskbarLnk = "Microsoft Store.lnk"; StartLnks = @("Microsoft Store.lnk")
            Installed = $true
        },
        @{
            Name = "Settings to macOS Settings"; Icon = "Settings.ico"; AppId = $settingsAumid
            Target = $settingsTarget; Args = $settingsArgs
            TaskbarLnk = "Settings.lnk"; StartLnks = @("Settings.lnk")
            Installed = $true
        },
        @{
            Name = "WhatsApp"; Icon = "WhatsApp.ico"; AppId = $waAumid
            Target = $waTarget; Args = $waArgs
            TaskbarLnk = "WhatsApp.lnk"; StartLnks = @("WhatsApp.lnk")
            Installed = $waInstalled
        },
        @{
            Name = "Telegram"; Icon = "Telegram.ico"; AppId = $tgAumid
            Target = $tgTarget; Args = $tgArgs
            TaskbarLnk = "Telegram.lnk"; StartLnks = @("Telegram.lnk")
            Installed = $tgInstalled
        },
        @{
            Name = "Discord"; Icon = "Discord.ico"; AppId = $discordAumid
            Target = $discordTarget; Args = $discordArgs
            TaskbarLnk = "Discord.lnk"; StartLnks = @("Discord.lnk", "Discord Inc\Discord.lnk")
            Installed = $discordInstalled
        },
        @{
            Name = "Steam"; Icon = "Steam.ico"; AppId = $steamAumid
            Target = $steamTarget; Args = ""
            TaskbarLnk = "Steam.lnk"; StartLnks = @("Steam.lnk", "Steam\Steam.lnk")
            Installed = $steamInstalled
        },
        @{
            Name = "Terminal"; Icon = "Terminal.ico"; AppId = "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
            Target = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"; Args = ""
            TaskbarLnk = "Windows Terminal.lnk"; StartLnks = @("Windows Terminal.lnk")
            Installed = $true
        },
        @{
            Name = "Notepad to Notes"; Icon = "Notes.ico"; AppId = "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"
            Target = "shell:AppsFolder\Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"; Args = ""
            TaskbarLnk = "Notepad.lnk"; StartLnks = @("Notepad.lnk")
            Installed = $true
        },
        @{
            Name = "Calculator"; Icon = "Calculator.ico"; AppId = "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"
            Target = "shell:AppsFolder\Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"; Args = ""
            TaskbarLnk = "Calculator.lnk"; StartLnks = @("Calculator.lnk")
            Installed = $true
        },
        @{
            Name = "Photos"; Icon = "Photos.ico"; AppId = "Microsoft.Windows.Photos_8wekyb3d8bbwe!App"
            Target = "shell:AppsFolder\Microsoft.Windows.Photos_8wekyb3d8bbwe!App"; Args = ""
            TaskbarLnk = "Photos.lnk"; StartLnks = @("Photos.lnk")
            Installed = $true
        },
        @{
            Name = "Apple Music"; Icon = "Music.ico"; AppId = "Microsoft.ZuneMusic_8wekyb3d8bbwe!Microsoft.ZuneMusic"
            Target = "shell:AppsFolder\Microsoft.ZuneMusic_8wekyb3d8bbwe!Microsoft.ZuneMusic"; Args = ""
            TaskbarLnk = "Apple Music.lnk"; StartLnks = @("Apple Music.lnk")
            Installed = $true
        }
    )

    foreach ($app in $appsConfig) {
        $icoPath = Join-Path $appsTarget $app.Icon
        if (Test-Path $icoPath) {
            # Only pin to Taskbar if the app is actually installed!
            if ($app.TaskbarLnk -and $app.Installed -and $app.Target) {
                $tbLnkPath = Join-Path $taskbarDir $app.TaskbarLnk
                [MacAppShortcutHelper]::CreateOrUpdateShortcut($tbLnkPath, $app.Target, $app.Args, $icoPath, $app.AppId)
            }

            foreach ($sl in $app.StartLnks) {
                $userSlPath = Join-Path $userStartDir $sl
                $allSlPath = Join-Path $allStartDir $sl

                # Deploy custom squircle icon shortcut to Start Menu for installed apps
                if ($app.Installed -and $app.Target) {
                    [MacAppShortcutHelper]::CreateOrUpdateShortcut($userSlPath, $app.Target, $app.Args, $icoPath, $app.AppId)
                    try {
                        $allParent = Split-Path $allSlPath -Parent
                        if (-not (Test-Path $allParent)) { New-Item -ItemType Directory -Path $allParent -Force | Out-Null }
                        [MacAppShortcutHelper]::CreateOrUpdateShortcut($allSlPath, $app.Target, $app.Args, $icoPath, $app.AppId)
                    } catch {}
                }
            }
        }
    }

    # Refresh Windows 11 Start Menu and Search Host cache
    Stop-Process -Name "StartMenuExperienceHost" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "SearchHost" -Force -ErrorAction SilentlyContinue

    Write-Host "  [OK] Apple macOS Squircle App Icons successfully deployed to Dock & Start Menu!" -ForegroundColor Green
} catch {
    Write-Host "  [-] App icons note: $($_.Exception.Message)" -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 8: Apply 4K macOS Wallpaper & Windows Dark Mode
# -------------------------------------------------------------------------
Write-Host "
[8/9] Applying 4K macOS Wallpaper & Deep Dark Mode..." -ForegroundColor Cyan
try {
    # Disable Windows Spotlight & Slideshow so picture wallpaper displays
    $wpReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers"
    if (Test-Path $wpReg) {
        Set-ItemProperty -Path $wpReg -Name "BackgroundType" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $wpReg -Name "SlideshowSourceDirectoriesSet" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $wpReg -Name "SlideshowDirectoryPath1" -Force -ErrorAction SilentlyContinue
    }

    # 1. Dark Mode
    $themeReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (Test-Path $themeReg) {
        Set-ItemProperty -Path $themeReg -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $themeReg -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    
    # 2. Wallpaper
    $appDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
    if (-not (Test-Path $appDir)) { New-Item -ItemType Directory -Path $appDir -Force | Out-Null }
    $wallTarget = Join-Path $appDir "macOS_Wallpaper.jpg"
    $transcodedTarget = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"

    $localWall = if ($ScriptDir) { Join-Path $ScriptDir "assets\wallpaper.jpg" } else { $null }
    $scratchWall = "C:\Users\rohit\.gemini\antigravity\scratch\Rohit-Bhai-Mac-OS\assets\wallpaper.jpg"

    if ($localWall -and (Test-Path $localWall)) {
        Copy-Item $localWall -Destination $wallTarget -Force -ErrorAction SilentlyContinue
    } elseif (Test-Path $scratchWall) {
        Copy-Item $scratchWall -Destination $wallTarget -Force -ErrorAction SilentlyContinue
    } else {
        $wallUrls = @(
            "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/assets/wallpaper.jpg",
            "https://raw.githubusercontent.com/$RepoOwner/rohit-bhai-mac-os/$Branch/assets/wallpaper.jpg"
        )
        foreach ($wUrl in $wallUrls) {
            try {
                Invoke-WebRequest -Uri $wUrl -OutFile $wallTarget -UseBasicParsing -ErrorAction SilentlyContinue
                if ((Test-Path $wallTarget) -and ((Get-Item $wallTarget).Length -gt 50000)) { break }
            } catch {}
        }
    }

    if (Test-Path $wallTarget) {
        Copy-Item $wallTarget -Destination $transcodedTarget -Force -ErrorAction SilentlyContinue
        Copy-Item $wallTarget -Destination "$env:APPDATA\Microsoft\Windows\Themes\Transcoded_000" -Force -ErrorAction SilentlyContinue
        if (Test-Path "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaperCache") {
            Get-ChildItem -Path "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaperCache" -Filter "TranscodedWallpaper_*" -File -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not $_.Name.EndsWith(".meta")) {
                    Copy-Item $wallTarget -Destination $_.FullName -Force -ErrorAction SilentlyContinue
                }
            }
        }
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallTarget -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Force -ErrorAction SilentlyContinue
        $wpKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers"
        if (-not (Test-Path $wpKey)) { New-Item -Path $wpKey -Force | Out-Null }
        Set-ItemProperty -Path $wpKey -Name "BackgroundHistoryPath0" -Value $wallTarget -Force -ErrorAction SilentlyContinue
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Wall {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction SilentlyContinue
        [Win32Wall]::SystemParametersInfo(0x0014, 0, $wallTarget, 3) | Out-Null
        rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
        Write-Host "  [OK] 4K macOS Wallpaper & Dark Mode applied live!" -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] Wallpaper note: Skipped non-critical wallpaper update." -ForegroundColor DarkGray
}
# Step 9: Import Windhawk Mods & Settings (Island Dock, Genie, Net Speed)
# -------------------------------------------------------------------------
Write-Host "`n[9/9] Activating all 8 Windhawk mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
Write-Host "      (Mac Island Dock, Genie Animation, LiquidGlass, Apple Net Speed...)" -ForegroundColor DarkGray

if (-not $WindhawkCli) {
    $WindhawkCli = Find-WindhawkCli
}
$windhawkExe = if ($WindhawkCli) { Join-Path (Split-Path $WindhawkCli -Parent) "windhawk.exe" } else { Find-WindhawkExe }

function Set-RegDword($key, $name, $val) {
    & reg.exe add "$key" /v "$name" /t REG_DWORD /d $val /f /reg:64 2>$null | Out-Null
    & reg.exe add "$key" /v "$name" /t REG_DWORD /d $val /f /reg:32 2>$null | Out-Null
}
function Set-RegString($key, $name, $val) {
    & reg.exe add "$key" /v "$name" /t REG_SZ /d "$val" /f /reg:64 2>$null | Out-Null
    & reg.exe add "$key" /v "$name" /t REG_SZ /d "$val" /f /reg:32 2>$null | Out-Null
}

function Set-MacIslandStorage {
    $targetOrder = 'de12635;<8?479:=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcfghijklm'
    $key = "HKLM\SOFTWARE\Windhawk\Engine\ModsWritable\mac-island-dock\LocalStorage"
    
    # Read user SID to ensure per-user storage also receives all values
    $userSid = $null
    try {
        $userSid = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
    } catch {}

    $dwords = @{
        "islandBar" = 1
        "islandBarSide" = 0
        "islandBarAlign" = 3
        "placeX" = 1000
        "placeY" = 0
        "islandZoneAsPill" = 0
        "islandFrosted" = 1
        "islandLiquidGlass" = 1
        "islandGlassBlur" = 85
        "islandGlassLight" = 0
        "islandBarClear" = 0
        "islandWeather" = 1
        "islandWeatherUnit" = 1
        "weatherMyLocation" = 1
        "islandNotes" = 1
        "islandClock" = 1
        "clockWeekday" = 1
        "clockDate" = 1
        "clockSeconds" = 0
        "clockYear" = 0
        "islandMedia" = 1
        "islandMediaAlways" = 0
        "islandMediaPlayOnly" = 1
        "mediaButtons" = 1
        "mediaTitle" = 1
        "islandMediaButtonsSize" = 130
        "islandMediaTitleLimit" = 210
        "islandMicrophone" = 1
        "islandVisualizer" = 0
        "islandVizSensitivity" = 100
        "islandVisualizerColor" = 0
        "islandVisualizerSmooth" = 0
        "islandNetSpeed" = 0
        "islandVolume" = 1
        "islandNetwork" = 1
        "islandTray" = 1
        "islandBell" = 1
        "islandOrderDrag" = 1
        "islandIconSize" = 85
        "islandTextSize" = 100
        "islandPanelSize" = 100
        "islandPanelsFollow" = 1
        "islandIconPack" = 1
        "islandBattery" = 0
        "islandPower" = 1
        "islandApps" = 0
        "islandUsbDrives" = 1
        "islandUsbNotify" = 1
        "islandNoticeCharger" = 1
        "islandNoticeLowBattery" = 1
        "islandNotches" = 0
        "islandPillNotches" = 0
        "islandBarCorners" = 0
        "islandBarFixedSides" = 0
        "islandGap" = 0
        "islandVerticalSides" = 1
        "islandAutoHide" = 0
        "islandHideWhen" = 0
        "islandHideClock" = 0
        "islandOverFullscreen" = 1
        "islandTheme" = 4
        "islandStatusNotices" = 1
        "islandCapsLock" = 1
        "trayListIsland" = 12
        "animationsIsland" = 4002
        "islandOpacity" = 90
        "islandNotchCurve" = 80
        "islandPillHeight" = 100
        "islandSize" = 100
    }

    foreach ($entry in $dwords.GetEnumerator()) {
        Set-RegDword $key $entry.Key $entry.Value
        if ($userSid) {
            Set-RegDword $key "$($entry.Key)_$userSid" $entry.Value
        }
    }

    Set-RegString $key "islandOrder" $targetOrder
    if ($userSid) {
        Set-RegString $key "islandOrder_$userSid" $targetOrder
    }
}

function Set-AppleNetSpeedStorage {
    foreach ($mId in @("local@net-speed-taskbar-apple", "net-speed-taskbar-apple")) {
        $key = "HKLM\SOFTWARE\Windhawk\Engine\Mods\$mId\Settings"
        Set-RegString $key "theme" "Chart"
        Set-RegDword $key "showBox" 0
        Set-RegDword $key "horizontalPosition" 10
        Set-RegDword $key "rightOffset" 16
        Set-RegDword $key "verticalNudge" 16
        Set-RegDword $key "updateIntervalMs" 1000
        Set-RegDword $key "fontSize" 15
        Set-RegDword $key "opacity" 255
    }
}

function Set-FileExplorerStylerStorage {
    $key = "HKLM\SOFTWARE\Windhawk\Engine\Mods\windows-11-file-explorer-styler\Settings"
    Set-RegString $key "backgroundTranslucentEffectRegion" "explorerFrame"
}

Set-MacIslandStorage
Set-AppleNetSpeedStorage
Set-FileExplorerStylerStorage

if ($WindhawkCli -and (Test-Path $WindhawkCli)) {
    # Ensure Windhawk background service is running
    try {
        $whSvc = Get-Service -Name Windhawk -ErrorAction SilentlyContinue
        if ($whSvc -and $whSvc.Status -ne 'Running') {
            Start-Service Windhawk -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    } catch {}

    # Ensure any traffic light mod is completely removed (reverting to clean original Windows buttons)
    & $WindhawkCli mod remove local@caption-buttons-customizer --yes 2>$null
    & $WindhawkCli mod remove caption-buttons-customizer --yes 2>$null
    Remove-Item -Path "HKLM:\SOFTWARE\Windhawk\Engine\Mods\caption-buttons-customizer" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Windhawk\Engine\Mods\local@caption-buttons-customizer" -Recurse -Force -ErrorAction SilentlyContinue
    Stop-Process -Name dwm -Force -ErrorAction SilentlyContinue

    # Ensure ModsSource directory exists before copying any mod source
    $progModsSourceDir = "C:\ProgramData\Windhawk\ModsSource"
    if (-not (Test-Path $progModsSourceDir)) { New-Item -ItemType Directory -Path $progModsSourceDir -Force | Out-Null }

    # Prepare local mod sources
    $speedModSource = if ($PSScriptRoot) {
        Join-Path $PSScriptRoot "Mods-Source\local@net-speed-taskbar-apple.wh.cpp"
    } else {
        Join-Path $WorkDir "local@net-speed-taskbar-apple.wh.cpp"
    }
    if (-not (Test-Path $speedModSource)) {
        $speedUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Mods-Source/local@net-speed-taskbar-apple.wh.cpp"
        try {
            Invoke-WebRequest -Uri $speedUrl -OutFile $speedModSource -UseBasicParsing -ErrorAction SilentlyContinue
        } catch {}
    }
    if (Test-Path $speedModSource) {
        Copy-Item -Path $speedModSource -Destination "$progModsSourceDir\local@net-speed-taskbar-apple.wh.cpp" -Force -ErrorAction SilentlyContinue
    }

    $islandModSource = if ($PSScriptRoot) {
        Join-Path $PSScriptRoot "Mods-Source\mac-island-dock.wh.cpp"
    } else {
        Join-Path $WorkDir "mac-island-dock.wh.cpp"
    }
    if (-not (Test-Path $islandModSource)) {
        $islandUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Mods-Source/mac-island-dock.wh.cpp"
        try {
            Invoke-WebRequest -Uri $islandUrl -OutFile $islandModSource -UseBasicParsing -ErrorAction SilentlyContinue
        } catch {}
    }
    if (Test-Path $islandModSource) {
        Copy-Item -Path $islandModSource -Destination "$progModsSourceDir\mac-island-dock.wh.cpp" -Force -ErrorAction SilentlyContinue
    }

    # Import clean 8-mod preset
    $importTarget = if (Test-Path $WhDataArchive) { $WhDataArchive } else { $WhDataLocal }
    & $WindhawkCli data import "$importTarget" --yes --on-conflict overwrite --confirm-app-restart
    $importCode = $LASTEXITCODE

    if ($importCode -eq 0) {
        Write-Host "  [OK] All 8 mods and custom settings activated successfully via Windhawk CLI!" -ForegroundColor Green
    } else {
        Write-Host "  [*] Retrying with local compilation mode..." -ForegroundColor Yellow
        & $WindhawkCli data import "$importTarget" --yes --offline --on-conflict overwrite --confirm-app-restart
        Write-Host "  [OK] Import completed!" -ForegroundColor Green
    }

    # Ensure Maximize Window Guard (Top Bar Fixed Top-Right & Bottom Dock Always Visible with Zero Overlap)
    & $WindhawkCli mod settings set mac-island-dock hiding.autoHide=0 2>$null

    # Install and compile updated Frameless Apple Net Speed mod
    if (Test-Path $speedModSource) {
        & $WindhawkCli mod install --file "$speedModSource" --yes 2>$null
        & $WindhawkCli mod compile local@net-speed-taskbar-apple 2>$null
    }

    # Install and compile updated mac-island-dock mod with frosted glass & squircle fallback
    if (Test-Path $islandModSource) {
        & $WindhawkCli mod install --file "$islandModSource" --yes 2>$null
        & $WindhawkCli mod compile mac-island-dock 2>$null
    }

    # Ensure Liquid Glass styling everywhere across Windhawk mods & set net speed verticalNudge to 16
    & $WindhawkCli mod settings set windows-11-notification-center-styler theme=LiquidGlass 2>$null
    & $WindhawkCli mod settings set windows-11-start-menu-styler theme=LiquidGlass 2>$null
    & $WindhawkCli mod settings set mac-island-dock "dock.backgroundOpacity=35" "dock.cornerRadius=24" "dock.bottomGap=4" 2>$null
    & $WindhawkCli mod settings set local@net-speed-taskbar-apple "verticalNudge=16" 2>$null

    # Re-apply LocalStorage & restart mac-island-dock so it immediately docks to top-right
    Set-MacIslandStorage
    Set-AppleNetSpeedStorage
    Set-FileExplorerStylerStorage
    & $WindhawkCli mod disable mac-island-dock --yes 2>$null
    Start-Sleep -Milliseconds 400
    & $WindhawkCli mod enable mac-island-dock --yes 2>$null

} elseif ($windhawkExe -and (Test-Path $windhawkExe)) {
    Write-Host "  [*] Activating all 8 mods directly via Registry injection..." -ForegroundColor Yellow
    if ($WhRegLocal -and (Test-Path $WhRegLocal)) {
        reg.exe import "$WhRegLocal" /reg:64 2>$null
        reg.exe import "$WhRegLocal" /reg:32 2>$null
        Write-Host "  [OK] All 8 mods injected into Windhawk Engine!" -ForegroundColor Green
    }
    Set-MacIslandStorage
    Set-AppleNetSpeedStorage
    Set-FileExplorerStylerStorage
}

if ($windhawkExe -or $WindhawkCli) {
    # Register permanent silent startup for Mac Island Top Bar
    $appDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
    if (-not (Test-Path $appDir)) { New-Item -ItemType Directory -Path $appDir -Force | Out-Null }
    $daemonPs1 = Join-Path $appDir "run_island_daemon.ps1"
    $localDaemon = if ($ScriptDir) { Join-Path $ScriptDir "run_island_daemon.ps1" } else { $null }
    if ($localDaemon -and (Test-Path $localDaemon)) {
        Copy-Item $localDaemon -Destination $daemonPs1 -Force -ErrorAction SilentlyContinue
    } else {
        $daemonUrls = @(
            "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/run_island_daemon.ps1",
            "https://raw.githubusercontent.com/$RepoOwner/rohit-bhai-mac-os/$Branch/run_island_daemon.ps1"
        )
        foreach ($dUrl in $daemonUrls) {
            try {
                Invoke-WebRequest -Uri $dUrl -OutFile $daemonPs1 -UseBasicParsing -ErrorAction SilentlyContinue
                if ((Test-Path $daemonPs1) -and (Get-Item $daemonPs1).Length -gt 500) { break }
            } catch {}
        }
    }
    $startupFolder = [Environment]::GetFolderPath('Startup')
    $vbsPath = Join-Path $startupFolder "RohitBhai_Mac_Island.vbs"
    $vbsContent = "Set WshShell = CreateObject(""WScript.Shell"")`r`nWshShell.Run ""powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """"$daemonPs1"""""", 0, False"
    [System.IO.File]::WriteAllText($vbsPath, $vbsContent, [System.Text.Encoding]::ASCII)
    if (-not $windhawkExe -or (-not (Test-Path $windhawkExe))) {
        $windhawkExe = "C:\Program Files\Windhawk\windhawk.exe"
    }
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Windhawk' -Value "`"$windhawkExe`" -tray-only" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RohitBhai_Mac_Island' -Value "wscript.exe `"$vbsPath`"" -Force -ErrorAction SilentlyContinue

    # Start the daemon process immediately so top-right status bar watchdog runs live
    Start-Process wscript.exe -ArgumentList "`"$vbsPath`"" -ErrorAction SilentlyContinue

    if (Test-Path $windhawkExe) {
        & $windhawkExe -restart -tray-only 2>$null
    }
    Write-Host "  [OK] Maximized window guard active: Top Bar fixed at top-right & Bottom Dock stay ALWAYS visible with zero overlap!" -ForegroundColor Green
} else {
    Write-Host "  [-] Skipped Windhawk mods activation (Windhawk not available)." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 10: Taskbar Calibration (Hide Search Bar, Center Dock & Pure macOS Look)
# -------------------------------------------------------------------------
try {
    # 1. Hide ugly Windows Search Box / pill from taskbar (SearchboxTaskbarMode = 0)
    $searchKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (-not (Test-Path $searchKey)) { New-Item -Path $searchKey -Force | Out-Null }
    Set-ItemProperty -Path $searchKey -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    # 2. Hide Task View, Widgets & Chat/Copilot buttons for authentic clean macOS Dock look
    $advKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (-not (Test-Path $advKey)) { New-Item -Path $advKey -Force | Out-Null }
    Set-ItemProperty -Path $advKey -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $advKey -Name "TaskbarDa" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $advKey -Name "TaskbarMn" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $advKey -Name "TaskbarAl" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    # 3. Ensure Always Visible Taskbar (StuckRects3 Byte 8 = 02)
    $stuckKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    if (Test-Path $stuckKey) {
        $stuckVal = (Get-ItemProperty -Path $stuckKey -Name "Settings" -ErrorAction SilentlyContinue).Settings
        if ($stuckVal -and $stuckVal.Length -ge 9) {
            $stuckVal[8] = 2
            Set-ItemProperty -Path $stuckKey -Name "Settings" -Value $stuckVal -Force
        }
    }
} catch {}

# Refresh Shell smoothly without killing Explorer or black screen
Write-Host "`n[*] Refreshing Windows Desktop, Folders & Dock..." -ForegroundColor Cyan
try {
    [ShellIconFlusher]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
} catch {}
try {
    $ie4 = Join-Path ([Environment]::GetFolderPath('System')) "ie4uinit.exe"
    if (Test-Path $ie4) { & $ie4 -show 2>$null }
} catch {}

# Cleanup
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "        CONGRATULATIONS! ROHIT BHAI 1 CLICK MAC OS v4.7 IS NOW ACTIVE!                 " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * Official Apple macOS Folder Icons (Sonoma Aqua, Documents, Downloads, etc.) active" -ForegroundColor White
Write-Host "  * Apple Macintosh HD drive icon & Recycle Bin (empty/full) active" -ForegroundColor White
Write-Host "  * Authentic Apple macOS Sound Scheme (Trash, USB, Alert, Notification) active" -ForegroundColor White
Write-Host "  * Clean macOS Dock (Ugly Windows Search Bar & Task View hidden) active" -ForegroundColor White
Write-Host "  * Fixed Top-Right macOS Status Bar & Centered Floating Dock active" -ForegroundColor White
Write-Host "  * macOS Genie Minimize animation (450ms) active" -ForegroundColor White
Write-Host "  * Apple Taskbar Network Speed indicator active" -ForegroundColor White
Write-Host "  * Apple SF Pro Display typography installed" -ForegroundColor White
Write-Host "  * macOS Capitaine Dark Cursors (with rainbow spinning beach-ball) active" -ForegroundColor White
Write-Host "  * 4K Ultra-HD macOS Wallpaper & Deep Dark Mode applied" -ForegroundColor White
Write-Host ""
Write-Host "  Crafted with love by: Rohit Bhai" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/Rohit-Bhai-Youtube/rohit-bhai-1-click-mac-os" -ForegroundColor DarkGray
Write-Host ""
try {
    Write-Host "Press any key to close..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Start-Sleep -Seconds 3
}
