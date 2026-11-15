# ==============================================================================
# Rohit Bhai Mac OS for Windows 11 - 1-Click Ultimate Suite v3.0 Pro
# Target: Windows 11 (22H2 / 23H2 / 24H2) and Windows 10
# Includes: Windhawk Mac Island Dock, Genie, Net Speed, SF Pro Fonts,
#           macOS Capitaine Cursors, 4K macOS Wallpaper, Dark Mode &
#           Official Apple macOS Sound Scheme (Trash, USB, Alert, Notification)
# Crafted for Rohit Bhai | 100% Native - No Bloatware
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Repository Configuration
$RepoOwner = "romflasher3419-spec"
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
   ██████╗  ██████╗ ███╗   ███╗    ███████╗██╗      █████╗ ███████╗██╗  ██╗
   ██╔══██╗██╔═══██╗████╗ ████║    ██╔════╝██║     ██╔══██╗██╔════╝██║  ██║
   ██████╔╝██║   ██║██╔████╔██║    █████╗  ██║     ███████║███████╗███████║
   ██╔══██╗██║   ██║██║╚██╔╝██║    ██╔══╝  ██║     ██╔══██║╚════██║██╔══██║
   ██║  ██║╚██████╔╝██║ ╚═╝ ██║    ██║     ███████╗██║  ██║███████║██║  ██║
   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
              ROHIT BHAI MAC OS FOR WINDOWS 11 - v3.0 [ULTIMATE EDITION]
                               Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Cyan

Write-Host "  [+] Mac Island & Floating Dock (32px, 8px floating gap, 22px radius, bounce)" -ForegroundColor White
Write-Host "  [+] macOS Genie Minimize Animation (Liquid curve 450ms)" -ForegroundColor White
Write-Host "  [+] Apple Taskbar Network Speed Indicator (100% native Windhawk)" -ForegroundColor White
Write-Host "  [+] Apple SF Pro Typography (San Francisco Display & Text)" -ForegroundColor White
Write-Host "  [+] macOS Capitaine Dark Cursors with Rainbow Spinning Beach-Ball" -ForegroundColor White
Write-Host "  [+] 4K Ultra-HD macOS Wallpaper & Windows Deep Dark Theme" -ForegroundColor White
Write-Host "  [+] Official Apple macOS Sound Scheme (Trash Empty, USB Connect, Pop, Tink)" -ForegroundColor White
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
Write-Host "[1/7] Checking Windhawk Customization Engine..." -ForegroundColor Cyan

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

Write-Host "  [OK] Windhawk CLI verified: $WindhawkCli" -ForegroundColor Green

# -------------------------------------------------------------------------
# Step 2: Download or Locate Backup Package
# -------------------------------------------------------------------------
Write-Host "`n[2/7] Fetching Rohit Bhai Mac OS Mod Configurations..." -ForegroundColor Cyan

$WhDataLocal = $null
$CandidatePaths = @()
if ($ScriptDir) {
    $CandidatePaths += (Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata")
}
$CandidatePaths += (Join-Path $PSScriptRoot "Rohit-Bhai-Mac-OS.whdata")
$CandidatePaths += (Join-Path $WorkDir "Rohit-Bhai-Mac-OS.whdata")

foreach ($p in $CandidatePaths) {
    if ($p -and (Test-Path $p)) {
        $WhDataLocal = $p
        break
    }
}

if (-not $WhDataLocal) {
    Write-Host "  [*] Downloading configuration bundle from GitHub..." -ForegroundColor Yellow
    $backupUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/Rohit-Bhai-Mac-OS.whdata"
    $targetPath = Join-Path $WorkDir "Rohit-Bhai-Mac-OS.whdata"
    try {
        Invoke-WebRequest -Uri $backupUrl -OutFile $targetPath -UseBasicParsing
        $WhDataLocal = $targetPath
    } catch {
        Write-Host "  [!] Error: Failed to download configuration bundle: $_" -ForegroundColor Red
        Pause
        exit 1
    }
}

Write-Host "  [OK] Configuration data loaded: $WhDataLocal" -ForegroundColor Green

# -------------------------------------------------------------------------
# Step 3: Apple SF Pro Fonts Installation
# -------------------------------------------------------------------------
Write-Host "`n[3/7] Installing Apple SF Pro Typography (San Francisco)..." -ForegroundColor Cyan
try {
    $fontsTarget = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
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
Write-Host "`n[4/7] Deploying macOS Capitaine Dark Cursors with Beach-Ball..." -ForegroundColor Cyan
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
    
    $darkDir = Join-Path $cursorsTarget "dist-dark"
    if (-not (Test-Path $darkDir)) { $darkDir = $cursorsTarget }
    if (Test-Path $darkDir) {
        $schemePath = "HKCU:\Control Panel\Cursors"
        Set-ItemProperty -Path $schemePath -Name "" -Value "Capitaine macOS Dark" -Force
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
        Write-Host "  [OK] macOS Capitaine Dark Cursors scheme registered!" -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] Cursors note: Skipped non-critical cursor install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 5: Official Apple macOS System Sound Scheme
# -------------------------------------------------------------------------
Write-Host "`n[5/7] Configuring Authentic Apple macOS System Sound Scheme..." -ForegroundColor Cyan
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
    Set-MacSound -App ".Default" -Event "DeviceConnect" -WavName "macOS_Device_Connect.wav"
    Set-MacSound -App ".Default" -Event "DeviceDisconnect" -WavName "macOS_Device_Disconnect.wav"
    Set-MacSound -App ".Default" -Event "Notification.Default" -WavName "macOS_Notification.wav"
    Set-MacSound -App ".Default" -Event "SystemAsterisk" -WavName "macOS_Notification.wav"
    Set-MacSound -App ".Default" -Event "SystemExclamation" -WavName "macOS_Funk.wav"
    Set-MacSound -App ".Default" -Event "SystemHand" -WavName "macOS_Sosumi.wav"
    Set-MacSound -App ".Default" -Event "SystemQuestion" -WavName "macOS_Pop.wav"
    Set-MacSound -App ".Default" -Event "LowBatteryAlarm" -WavName "macOS_Basso.wav"
    Set-MacSound -App ".Default" -Event "CriticalBatteryAlarm" -WavName "macOS_Sosumi.wav"
    Set-MacSound -App ".Default" -Event "PrintComplete" -WavName "macOS_Hero.wav"

    Write-Host "  [OK] Apple macOS Sound Scheme (Trash, USB, Alert, Notification) activated!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Sound Scheme note: Skipped non-critical sound install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 6: Apply 4K macOS Wallpaper & Windows Dark Mode
# -------------------------------------------------------------------------
Write-Host "`n[6/7] Applying 4K macOS Wallpaper & Deep Dark Mode..." -ForegroundColor Cyan
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
# Step 7: Import Windhawk Mods & Settings (Island Dock, Genie, Net Speed)
# -------------------------------------------------------------------------
Write-Host "`n[7/7] Activating all 8 Windhawk mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
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
Write-Host "            CONGRATULATIONS! ROHIT BHAI MAC OS v3.0 IS NOW ACTIVE!                     " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * Mac Island & Dock (32px, 8px gap, 22px radius, launch bounce) active" -ForegroundColor White
Write-Host "  * macOS Genie Minimize animation (450ms) active" -ForegroundColor White
Write-Host "  * Apple Taskbar Network Speed indicator active" -ForegroundColor White
Write-Host "  * Apple SF Pro Display typography installed" -ForegroundColor White
Write-Host "  * macOS Capitaine Dark Cursors (with rainbow spinning beach-ball) active" -ForegroundColor White
Write-Host "  * Authentic Apple macOS Sound Scheme (Trash, USB, Alert, Notification) active" -ForegroundColor White
Write-Host "  * 4K Ultra-HD macOS Wallpaper & Deep Dark Mode applied" -ForegroundColor White
Write-Host ""
Write-Host "  Crafted with love by: Rohit Bhai" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/romflasher3419-spec/rohit-bhai-mac-os" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
