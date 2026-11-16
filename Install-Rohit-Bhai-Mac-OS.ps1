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
$RepoName  = "rohit-bhai-mac-os"
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

Clear-Host
Write-Host @"
========================================================================================
   ██████╗  ██████╗ ██████╗    ███████╗██╗     █████╗ ███████╗██╗  ██╗
   ██╔══██╗██╔═══██╗██╔══██╗   ██╔════╝██║    ██╔══██╗██╔════╝██║  ██║
   ██████╔╝██║   ██║██████╔╝   █████╗  ██║    ███████║███████╗███████║
   ██╔══██╗██║   ██║██╔══██╗   ██╔══╝  ██║    ██╔══██║╚════██║██╔══██║
   ██║  ██║╚██████╔╝██████╔╝   ██║     ███████╗██║  ██║███████║██║  ██║
   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
              ROHIT BHAI MAC OS FOR WINDOWS 11 - v4.7 [TOP-RIGHT STATUS BAR & DOCK]
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
# Step 1: Detect or Install Windhawk
# -------------------------------------------------------------------------
Write-Host "[1/9] Checking Windhawk Customization Engine..." -ForegroundColor Cyan

function Find-WindhawkCli {
    # 1. Standard well-known directory paths
    $candidatePaths = @(
        "C:\Program Files\Windhawk\windhawk-cli.exe",
        "$env:ProgramFiles\Windhawk\windhawk-cli.exe",
        "$env:ProgramW6432\Windhawk\windhawk-cli.exe",
        "${env:ProgramFiles(x86)}\Windhawk\windhawk-cli.exe",
        "$env:LOCALAPPDATA\Programs\Windhawk\windhawk-cli.exe"
    )
    foreach ($p in $candidatePaths) {
        if ($p -and (Test-Path $p)) { return $p }
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

$WindhawkCli = Find-WindhawkCli

if (-not $WindhawkCli) {
    Write-Host "  [-] Windhawk is not installed. Installing Windhawk..." -ForegroundColor Yellow
    $installed = $false

    # Attempt 1: winget (with --force to reinstall if package registry is already present)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  [*] Installing via winget..." -ForegroundColor Yellow
        try {
            winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements --silent --force
            for ($i = 0; $i -lt 6; $i++) {
                Start-Sleep -Seconds 2
                $WindhawkCli = Find-WindhawkCli
                if ($WindhawkCli) {
                    $installed = $true
                    break
                }
            }
        } catch {}
    }

    # Attempt 2: Direct download official installer from GitHub Releases
    if (-not $installed) {
        Write-Host "  [*] Downloading official Windhawk installer from GitHub Releases..." -ForegroundColor Yellow
        $installerPath = Join-Path $WorkDir "windhawk_setup.exe"
        $whDownloadUrls = @(
            "https://github.com/ramensoftware/windhawk/releases/latest/download/windhawk_setup.exe",
            "https://github.com/ramensoftware/windhawk/releases/download/v1.5.1/windhawk_setup.exe"
        )
        $downloadSuccess = $false

        foreach ($url in $whDownloadUrls) {
            try {
                if (Test-Path $installerPath) { Remove-Item $installerPath -Force -ErrorAction SilentlyContinue }

                # Use curl.exe if available for fast direct download
                if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                    & curl.exe -sSL "$url" -o "$installerPath"
                }

                # Fallback to WebClient if curl didn't download or is too small
                if (-not (Test-Path $installerPath) -or ((Get-Item $installerPath).Length -lt 5000000)) {
                    $wc = New-Object System.Net.WebClient
                    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
                    $wc.DownloadFile($url, $installerPath)
                }

                # Verify valid PE executable size (> 5MB)
                if ((Test-Path $installerPath) -and ((Get-Item $installerPath).Length -gt 5000000)) {
                    $downloadSuccess = $true
                    break
                }
            } catch {}
        }

        if ($downloadSuccess) {
            Write-Host "  [*] Executing Windhawk silent installer (/S /STANDARD)..." -ForegroundColor Yellow
            Start-Process -FilePath $installerPath -ArgumentList "/S", "/STANDARD" -Wait
            for ($i = 0; $i -lt 10; $i++) {
                Start-Sleep -Seconds 2
                $WindhawkCli = Find-WindhawkCli
                if ($WindhawkCli) {
                    $installed = $true
                    break
                }
            }
        } else {
            Write-Host "  [!] Windhawk auto-download failed. Please install Windhawk manually." -ForegroundColor Red
        }
    }
}

if ($WindhawkCli) {
    # Ensure Windhawk background service is running
    try {
        $whSvc = Get-Service -Name Windhawk -ErrorAction SilentlyContinue
        if ($whSvc -and $whSvc.Status -ne 'Running') {
            Start-Service Windhawk -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    } catch {}
    Write-Host "  [OK] Windhawk engine found: $WindhawkCli" -ForegroundColor Green
} else {
    Write-Host "  [!] Warning: Windhawk not found. Proceeding with System Icons, Sounds & Cursors..." -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# Step 2: Download or Locate Rohit Bhai Mac OS Settings
# -------------------------------------------------------------------------
Write-Host "`n[2/9] Locating Rohit Bhai Mac OS Preset..." -ForegroundColor Cyan
$WhDataLocal = Join-Path $WorkDir "Rohit-Bhai-Mac-OS-Settings.json"

$localPreset = if ($ScriptDir) { Join-Path $ScriptDir "Rohit-Bhai-Mac-OS-Settings.json" } else { $null }
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
Write-Host "`n[4/9] Deploying macOS Capitaine Dark Cursors with Beach-Ball..." -ForegroundColor Cyan
try {
    $cursorsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Cursors"
    if (-not (Test-Path $cursorsTarget)) {
        New-Item -ItemType Directory -Path $cursorsTarget -Force | Out-Null
    }
    
    $localCursors = if ($ScriptDir) { Join-Path $ScriptDir "assets\cursors" } else { $null }
    if ($localCursors -and (Test-Path $localCursors)) {
        Copy-Item "$localCursors\*" -Destination $cursorsTarget -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        $curZipUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v2.0.0/capitaine_cursors.zip"
        $curZip = Join-Path $WorkDir "cursors.zip"
        try {
            Invoke-WebRequest -Uri $curZipUrl -OutFile $curZip -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $curZip) {
                Expand-Archive -Path $curZip -DestinationPath $cursorsTarget -Force
            }
        } catch {}
    }
    
    $darkDir = Join-Path $cursorsTarget "Capitaine Dark W11 HiDPI"
    if (-not (Test-Path $darkDir)) { $darkDir = Join-Path $cursorsTarget "dist-dark" }
    if (-not (Test-Path $darkDir)) { $darkDir = $cursorsTarget }
    if (Test-Path $darkDir) {
        $schemePath = "HKCU:\Control Panel\Cursors"
        Set-ItemProperty -Path $schemePath -Name "(Default)" -Value "Capitaine Dark W11 HiDPI" -Force
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
        Set-ItemProperty -Path $schemePath -Name "Hand" -Value "$darkDir\link.cur" -Force -ErrorAction SilentlyContinue
        
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Cursor {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@ -ErrorAction SilentlyContinue
        [Win32Cursor]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 3) | Out-Null
        Write-Host "  [OK] macOS Capitaine Dark Cursors scheme registered & live applied!" -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] Cursors note: Skipped non-critical cursor install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
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

    # 1. Shell Icons (HKLM 64-bit, 32-bit & HKCU)
    $folderIco      = Join-Path $iconsTarget "macOS_Folder.ico"
    $folderOpenIco  = Join-Path $iconsTarget "macOS_Folder_Open.ico"
    $driveIco       = Join-Path $iconsTarget "macOS_Drive.ico"
    $driveSystemIco = Join-Path $iconsTarget "macOS_Drive_System.ico"
    $thisPcIco      = Join-Path $iconsTarget "macOS_ThisPC.ico"
    $trashEmptyIco  = Join-Path $iconsTarget "macOS_Trash_Empty.ico"
    $trashFullIco   = Join-Path $iconsTarget "macOS_Trash_Full.ico"
    $desktopIco     = Join-Path $iconsTarget "macOS_Desktop.ico"
    
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

    foreach ($c in @("HKCU:\Software\Classes\Folder\DefaultIcon", "HKCU:\Software\Classes\Directory\DefaultIcon")) {
        if (-not (Test-Path $c)) { New-Item -Path $c -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path $folderIco) { Set-ItemProperty -Path $c -Name "(default)" -Value $folderIco -Force -ErrorAction SilentlyContinue }
    }

    # 2. Drive Icons (Macintosh HD for C:, Generic for others)
    $driveRoots = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons"
    )
    foreach ($dr in $driveRoots) {
        $cKey = "$dr\C"
        if (-not (Test-Path "$cKey\DefaultIcon"))  { New-Item -Path "$cKey\DefaultIcon"  -Force -ErrorAction SilentlyContinue | Out-Null }
        if (-not (Test-Path "$cKey\DefaultLabel")) { New-Item -Path "$cKey\DefaultLabel" -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path $driveSystemIco) { Set-ItemProperty -Path "$cKey\DefaultIcon"  -Name "(default)" -Value "$driveSystemIco,0" -Force -ErrorAction SilentlyContinue }
        Set-ItemProperty -Path "$cKey\DefaultLabel" -Name "(default)" -Value "Macintosh HD" -Force -ErrorAction SilentlyContinue

        if (Test-Path $driveIco) {
            Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -and $_.DriveLetter -ne 'C' } | ForEach-Object {
                $dl = $_.DriveLetter
                $dKey = "$dr\$dl"
                if (-not (Test-Path "$dKey\DefaultIcon")) { New-Item -Path "$dKey\DefaultIcon" -Force -ErrorAction SilentlyContinue | Out-Null }
                Set-ItemProperty -Path "$dKey\DefaultIcon" -Name "(default)" -Value "$driveIco,0" -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Modern Explorer Drive override in HKCU Classes
    $appDrivesKey = "HKCU:\Software\Classes\Applications\Explorer.exe\Drives\C"
    if (-not (Test-Path "$appDrivesKey\DefaultIcon"))  { New-Item -Path "$appDrivesKey\DefaultIcon"  -Force -ErrorAction SilentlyContinue | Out-Null }
    if (-not (Test-Path "$appDrivesKey\DefaultLabel")) { New-Item -Path "$appDrivesKey\DefaultLabel" -Force -ErrorAction SilentlyContinue | Out-Null }
    if (Test-Path $driveSystemIco) { Set-ItemProperty -Path "$appDrivesKey\DefaultIcon"  -Name "(default)" -Value "$driveSystemIco,0" -Force -ErrorAction SilentlyContinue }
    Set-ItemProperty -Path "$appDrivesKey\DefaultLabel" -Name "(default)" -Value "Macintosh HD" -Force -ErrorAction SilentlyContinue

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
                        $item = Get-Item -LiteralPath $p -Force -ErrorAction Stop
                        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
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
    }

    # 5. Flush Icon Cache & Suppress Bottom White Artifacts
    $iconCache = "$env:LOCALAPPDATA\IconCache.db"
    if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "*cache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    & ie4uinit.exe -show 2>$null

    Write-Host "  [OK] Apple macOS File Explorer & Folder Icons applied!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Icons note: Skipped non-critical icon install." -ForegroundColor DarkGray
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

    public static void CreateOrUpdateShortcut(string lnkPath, string targetPath, string arguments, string iconPath, string appUserModelId) {
        if (File.Exists(lnkPath)) {
            try { File.Delete(lnkPath); } catch {}
        }

        ShellLink link = new ShellLink();
        IShellLinkW shellLink = (IShellLinkW)link;
        IPersistFile persistFile = (IPersistFile)link;

        if (!string.IsNullOrEmpty(targetPath)) shellLink.SetPath(targetPath);
        if (!string.IsNullOrEmpty(arguments)) shellLink.SetArguments(arguments);
        if (!string.IsNullOrEmpty(iconPath)) shellLink.SetIconLocation(iconPath, 0);

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

    # Compile native Win32 protocol launcher binaries for UWP apps
    # This solves the Dock click glitch and prevents grey squares permanently
    $launchersDir = Join-Path $env:LOCALAPPDATA "RohitBhaiMacOS\Apps"
    if (-not (Test-Path $launchersDir)) { New-Item -ItemType Directory -Path $launchersDir -Force | Out-Null }

    $protocolLaunchers = @(
        @{ Name = "WhatsApp"; Exe = "WhatsApp.exe"; Icon = "WhatsApp.ico"; Protocol = "whatsapp://"; FallbackAumid = "5319275A.WhatsAppDesktop_cv1g1gvanyjgm!App" },
        @{ Name = "Telegram"; Exe = "Telegram.exe"; Icon = "Telegram.ico"; Protocol = "tg://"; FallbackAumid = "TelegramMessengerLLP.TelegramDesktop_t4vj0pshhgkwm!Telegram.TelegramDesktop.Store" },
        @{ Name = "AppStore"; Exe = "AppStore.exe"; Icon = "AppStore.ico"; Protocol = "ms-windows-store:"; FallbackAumid = "Microsoft.WindowsStore_8wekyb3d8bbwe!App" }
    )

    try {
        $codeProvider = New-Object Microsoft.CSharp.CSharpCodeProvider
        foreach ($pl in $protocolLaunchers) {
            $exeOut = Join-Path $launchersDir $pl.Exe
            $iconSrc = Join-Path $appsTarget $pl.Icon
            $protoUri = $pl.Protocol
            $aumidFb = $pl.FallbackAumid

            $baseProc = [System.IO.Path]::GetFileNameWithoutExtension($pl.Exe)
            Get-Process -Name $baseProc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

            $launcherCode = @"
using System;
using System.Diagnostics;
class Program {
    [STAThread]
    static void Main(string[] args) {
        try {
            ProcessStartInfo psi = new ProcessStartInfo("$protoUri");
            psi.UseShellExecute = true;
            Process.Start(psi);
        } catch {
            try {
                ProcessStartInfo psi = new ProcessStartInfo("explorer.exe", "shell:AppsFolder\\$aumidFb");
                psi.UseShellExecute = true;
                Process.Start(psi);
            } catch {}
        }
    }
}
"@
            $cParams = New-Object System.CodeDom.Compiler.CompilerParameters
            $cParams.GenerateExecutable = $true
            $cParams.OutputAssembly = $exeOut
            $cParams.ReferencedAssemblies.Add("System.dll") | Out-Null
            if (Test-Path $iconSrc) {
                $cParams.CompilerOptions = "/target:winexe /win32icon:`"$iconSrc`""
            } else {
                $cParams.CompilerOptions = "/target:winexe"
            }
            $codeProvider.CompileAssemblyFromSource($cParams, $launcherCode) | Out-Null
        }
    } catch {}

    $appsConfig = @(
        @{
            Name = "Edge to Safari"; Icon = "Safari.ico"; AppId = "MSEdge"
            Target = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"; Args = "--profile-directory=Default"
            TaskbarLnk = "Microsoft Edge.lnk"; StartLnks = @("Microsoft Edge.lnk")
        },
        @{
            Name = "Explorer to Finder"; Icon = "Finder.ico"; AppId = "Microsoft.Windows.Explorer"
            Target = $explorerExe; Args = ""
            TaskbarLnk = "File Explorer.lnk"; StartLnks = @("File Explorer.lnk")
        },
        @{
            Name = "Microsoft Store to App Store"; Icon = "AppStore.ico"; AppId = ""
            Target = (Join-Path $launchersDir "AppStore.exe"); Args = ""
            TaskbarLnk = "Microsoft Store.lnk"; StartLnks = @("Microsoft Store.lnk")
        },
        @{
            Name = "Settings to macOS Settings"; Icon = "Settings.ico"; AppId = "windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"
            Target = $explorerExe; Args = "shell:AppsFolder\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"
            TaskbarLnk = "Settings.lnk"; StartLnks = @("Settings.lnk", "System Tools\Control Panel.lnk")
        },
        @{
            Name = "WhatsApp"; Icon = "WhatsApp.ico"; AppId = ""
            Target = (Join-Path $launchersDir "WhatsApp.exe"); Args = ""
            TaskbarLnk = "WhatsApp.lnk"; StartLnks = @("WhatsApp.lnk")
        },
        @{
            Name = "Telegram"; Icon = "Telegram.ico"; AppId = ""
            Target = (Join-Path $launchersDir "Telegram.exe"); Args = ""
            TaskbarLnk = "Telegram.lnk"; StartLnks = @("Telegram.lnk")
        },
        @{
            Name = "Discord"; Icon = "Discord.ico"; AppId = "com.squirrel.Discord.Discord"
            Target = "$env:LOCALAPPDATA\Discord\Discord.exe"; Args = ""
            TaskbarLnk = "Discord.lnk"; StartLnks = @("Discord.lnk", "Discord Inc\Discord.lnk")
        },
        @{
            Name = "Steam"; Icon = "Steam.ico"; AppId = "Valve.Steam"
            Target = "C:\Program Files (x86)\Steam\steam.exe"; Args = ""
            TaskbarLnk = "Steam.lnk"; StartLnks = @("Steam.lnk", "Steam\Steam.lnk")
        },
        @{
            Name = "Terminal"; Icon = "Terminal.ico"; AppId = "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
            Target = $explorerExe; Args = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
            TaskbarLnk = "Windows Terminal.lnk"; StartLnks = @("Windows Terminal.lnk", "Windows PowerShell\Windows PowerShell.lnk", "System Tools\Command Prompt.lnk")
        },
        @{
            Name = "Notepad to Notes"; Icon = "Notes.ico"; AppId = "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"
            Target = $explorerExe; Args = "shell:AppsFolder\Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"
            TaskbarLnk = "Notepad.lnk"; StartLnks = @("Notepad.lnk")
        },
        @{
            Name = "Calculator"; Icon = "Calculator.ico"; AppId = "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"
            Target = $explorerExe; Args = "shell:AppsFolder\Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"
            TaskbarLnk = "Calculator.lnk"; StartLnks = @("Calculator.lnk")
        },
        @{
            Name = "Photos"; Icon = "Photos.ico"; AppId = "Microsoft.Windows.Photos_8wekyb3d8bbwe!App"
            Target = $explorerExe; Args = "shell:AppsFolder\Microsoft.Windows.Photos_8wekyb3d8bbwe!App"
            TaskbarLnk = "Photos.lnk"; StartLnks = @("Photos.lnk")
        },
        @{
            Name = "Apple Music"; Icon = "Music.ico"; AppId = "Microsoft.ZuneMusic_8wekyb3d8bbwe!Microsoft.ZuneMusic"
            Target = $explorerExe; Args = "shell:AppsFolder\Microsoft.ZuneMusic_8wekyb3d8bbwe!Microsoft.ZuneMusic"
            TaskbarLnk = "Apple Music.lnk"; StartLnks = @("Apple Music.lnk", "Media Player.lnk")
        },
        @{
            Name = "Task Manager to Activity Monitor"; Icon = "ActivityMonitor.ico"; AppId = ""
            Target = "$env:WINDIR\System32\Taskmgr.exe"; Args = ""
            TaskbarLnk = ""; StartLnks = @("Task Manager.lnk", "System Tools\Task Manager.lnk")
        },
        @{
            Name = "Word to Pages"; Icon = "Word.ico"; AppId = ""
            Target = ""; Args = ""
            TaskbarLnk = ""; StartLnks = @("Word.lnk")
        },
        @{
            Name = "Excel to Numbers"; Icon = "Excel.ico"; AppId = ""
            Target = ""; Args = ""
            TaskbarLnk = ""; StartLnks = @("Excel.lnk")
        },
        @{
            Name = "PowerPoint to Keynote"; Icon = "PowerPoint.ico"; AppId = ""
            Target = ""; Args = ""
            TaskbarLnk = ""; StartLnks = @("PowerPoint.lnk")
        }
    )

    foreach ($app in $appsConfig) {
        $icoPath = Join-Path $appsTarget $app.Icon
        if (Test-Path $icoPath) {
            if ($app.TaskbarLnk) {
                $tbLnkPath = Join-Path $taskbarDir $app.TaskbarLnk
                [MacAppShortcutHelper]::CreateOrUpdateShortcut($tbLnkPath, $app.Target, $app.Args, $icoPath, $app.AppId)
            }

            foreach ($sl in $app.StartLnks) {
                $userSlPath = Join-Path $userStartDir $sl
                $allSlPath = Join-Path $allStartDir $sl

                $parent = Split-Path $userSlPath -Parent
                if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

                if (Test-Path $userSlPath) {
                    [MacAppShortcutHelper]::CreateOrUpdateShortcut($userSlPath, $app.Target, $app.Args, $icoPath, $app.AppId)
                } elseif ($app.Target -and -not (Test-Path $allSlPath)) {
                    [MacAppShortcutHelper]::CreateOrUpdateShortcut($userSlPath, $app.Target, $app.Args, $icoPath, $app.AppId)
                }

                if (Test-Path $allSlPath) {
                    try {
                        [MacAppShortcutHelper]::CreateOrUpdateShortcut($allSlPath, $app.Target, $app.Args, $icoPath, $app.AppId)
                    } catch {}
                }
            }
        }
    }

    Write-Host "  [OK] Apple macOS Squircle App Icons successfully deployed to Dock & Start Menu!" -ForegroundColor Green
} catch {
    Write-Host "  [-] App icons note: $($_.Exception.Message)" -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 8: Apply 4K macOS Wallpaper & Windows Dark Mode
# -------------------------------------------------------------------------
Write-Host "`n[8/9] Applying 4K macOS Wallpaper & Deep Dark Mode..." -ForegroundColor Cyan
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
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Wall {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
}
"@ -ErrorAction SilentlyContinue
    [Win32Wall]::SystemParametersInfo(0x0014, 0, $wallTarget, 3) | Out-Null
    rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
    Write-Host "  [OK] 4K macOS Wallpaper & Dark Mode applied live!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Wallpaper note: Skipped non-critical wallpaper update." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 9: Import Windhawk Mods & Settings (Island Dock, Genie, Net Speed)
# -------------------------------------------------------------------------
Write-Host "`n[9/9] Activating all 8 Windhawk mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
Write-Host "      (Mac Island Dock, Genie Animation, LiquidGlass, Apple Net Speed...)" -ForegroundColor DarkGray

if (-not $WindhawkCli) {
    $WindhawkCli = Find-WindhawkCli
}

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

    # Import clean 8-mod preset
    & $WindhawkCli data import $WhDataLocal --yes --on-conflict overwrite --confirm-app-restart
    $importCode = $LASTEXITCODE

    if ($importCode -eq 0) {
        Write-Host "  [OK] All 8 mods and custom settings activated successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [*] Retrying with local compilation mode..." -ForegroundColor Yellow
        & $WindhawkCli data import $WhDataLocal --yes --offline --on-conflict overwrite --confirm-app-restart
        Write-Host "  [OK] Import completed!" -ForegroundColor Green
    }

    # Ensure Maximize Window Guard (Top Bar Fixed Top-Right & Bottom Dock Always Visible with Zero Overlap)
    & $WindhawkCli mod settings set mac-island-dock hiding.autoHide=0 2>$null
    $islandStoragePath = "HKLM:\Software\Windhawk\Engine\ModsWritable\mac-island-dock\LocalStorage"
    if (-not (Test-Path $islandStoragePath)) {
        New-Item -Path $islandStoragePath -Force | Out-Null
    }
    # Configure Fixed Top-Right macOS Status Bar (Right Side, Liquid Glass, No Notch)
    Set-ItemProperty -Path $islandStoragePath -Name "islandBar" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandNotches" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandPillNotches" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandZoneAsPill" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "placeX" -Value 1000 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "placeY" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandBarSide" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandBarAlign" -Value 3 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandBarCorners" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandBarFixedSides" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandGap" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandVerticalSides" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandAutoHide" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandHideWhen" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandHideClock" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandOverFullscreen" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandLiquidGlass" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandGlassBlur" -Value 70 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandGlassLight" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandClock" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "clockWeekday" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    # Media: Standalone music icon hidden, auto-shows Song Title & Playback Controls only when playing
    Set-ItemProperty -Path $islandStoragePath -Name "islandMedia" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandMediaAlways" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "mediaButtons" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "mediaTitle" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandPower" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandNetwork" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandVolume" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandWeather" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandBell" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandStatusNotices" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandCapsLock" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandUsbNotify" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    # Register permanent silent startup for Mac Island Top Bar
    $appDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
    if (-not (Test-Path $appDir)) { New-Item -ItemType Directory -Path $appDir -Force | Out-Null }
    $daemonPs1 = Join-Path $appDir "run_island_daemon.ps1"
    $localDaemon = if ($ScriptDir) { Join-Path $ScriptDir "run_island_daemon.ps1" } else { $null }
    if ($localDaemon -and (Test-Path $localDaemon)) {
        Copy-Item $localDaemon -Destination $daemonPs1 -Force -ErrorAction SilentlyContinue
    }
    $startupFolder = [Environment]::GetFolderPath('Startup')
    $vbsPath = Join-Path $startupFolder "RohitBhai_Mac_Island.vbs"
    $vbsContent = "Set WshShell = CreateObject(""WScript.Shell"")`r`nWshShell.Run ""powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """"$daemonPs1"""""", 0, False"
    [System.IO.File]::WriteAllText($vbsPath, $vbsContent, [System.Text.Encoding]::ASCII)
    $windhawkExe = Join-Path (Split-Path $WindhawkCli -Parent) "windhawk.exe"
    if (-not (Test-Path $windhawkExe)) {
        $windhawkExe = "C:\Program Files\Windhawk\windhawk.exe"
    }
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Windhawk' -Value "`"$windhawkExe`" -tray-only" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RohitBhai_Mac_Island' -Value "wscript.exe `"$vbsPath`"" -Force -ErrorAction SilentlyContinue

    if (Test-Path $windhawkExe) {
        & $windhawkExe -restart -tray-only 2>$null
    }
    Write-Host "  [OK] Maximized window guard active: Top Bar fixed at top-right & Bottom Dock stay ALWAYS visible with zero overlap!" -ForegroundColor Green
} else {
    Write-Host "  [-] Skipped Windhawk mods activation (Windhawk not available)." -ForegroundColor DarkGray
}

# Ensure Windows Taskbar Calibration: Always Visible (StuckRects3 Byte 8 = 02)
try {
    $stuckKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    if (Test-Path $stuckKey) {
        $stuckVal = (Get-ItemProperty -Path $stuckKey -Name "Settings" -ErrorAction SilentlyContinue).Settings
        if ($stuckVal -and $stuckVal.Length -ge 9) {
            $stuckVal[8] = 2
            Set-ItemProperty -Path $stuckKey -Name "Settings" -Value $stuckVal -Force
        }
    }
} catch {}

# Refresh Shell
Write-Host "`n[*] Refreshing Windows Desktop, Folders & Dock..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe
Start-Sleep -Seconds 2

# Cleanup
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "            CONGRATULATIONS! ROHIT BHAI MAC OS v4.4 IS NOW ACTIVE!                     " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * Official Apple macOS Folder Icons (Sonoma Aqua, Documents, Downloads, etc.) active" -ForegroundColor White
Write-Host "  * Apple Macintosh HD drive icon & Recycle Bin (empty/full) active" -ForegroundColor White
Write-Host "  * Authentic Apple macOS Sound Scheme (Trash, USB, Alert, Notification) active" -ForegroundColor White
Write-Host "  * Mac Island & Dock (32px, 8px gap, 22px radius, launch bounce) active" -ForegroundColor White
Write-Host "  * macOS Genie Minimize animation (450ms) active" -ForegroundColor White
Write-Host "  * Apple Taskbar Network Speed indicator active" -ForegroundColor White
Write-Host "  * Apple SF Pro Display typography installed" -ForegroundColor White
Write-Host "  * macOS Capitaine Dark Cursors (with rainbow spinning beach-ball) active" -ForegroundColor White
Write-Host "  * 4K Ultra-HD macOS Wallpaper & Deep Dark Mode applied" -ForegroundColor White
Write-Host ""
Write-Host "  Crafted with love by: Rohit Bhai" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/Rohit-Bhai-Youtube/rohit-bhai-mac-os" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
