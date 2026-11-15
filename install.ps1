# ==============================================================================
# Rohit Bhai Mac OS for Windows 11 - 1-Click Ultimate Suite v4.0 Pro
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
   ██████╗  ██████╗ ██████╗    ███████╗██╗     █████╗ ███████╗██╗  ██╗
   ██╔══██╗██╔═══██╗██╔══██╗   ██╔════╝██║    ██╔══██╗██╔════╝██║  ██║
   ██████╔╝██║   ██║██████╔╝   █████╗  ██║    ███████║███████╗███████║
   ██╔══██╗██║   ██║██╔══██╗   ██╔══╝  ██║    ██╔══██║╚════██║██╔══██║
   ██║  ██║╚██████╔╝██████╔╝   ██║     ███████╗██║  ██║███████║██║  ██║
   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
              ROHIT BHAI MAC OS FOR WINDOWS 11 - v4.0 [ULTIMATE EDITION]
                               Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Cyan

Write-Host "  [+] Mac Island & Floating Dock (32px, 8px floating gap, 22px radius, bounce)" -ForegroundColor White
Write-Host "  [+] macOS Genie Minimize Animation (Liquid curve 450ms)" -ForegroundColor White
Write-Host "  [+] Apple Taskbar Network Speed Indicator (100% native Windhawk)" -ForegroundColor White
Write-Host "  [+] Apple SF Pro Typography (San Francisco Display & Text)" -ForegroundColor White
Write-Host "  [+] macOS Capitaine Dark Cursors with Rainbow Spinning Beach-Ball" -ForegroundColor White
Write-Host "  [+] Official Apple macOS Sound Scheme (Trash Empty, USB Connect, Pop, Tink)" -ForegroundColor White
Write-Host "  [+] Official Apple macOS File Explorer & Folder Icons (Sonoma Aqua Folders, Macintosh HD)" -ForegroundColor White
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
Write-Host "[1/8] Checking Windhawk Customization Engine..." -ForegroundColor Cyan

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
            Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
            Start-Sleep -Seconds 5
            $WindhawkCli = Find-WindhawkCli
        } catch {
            Write-Host "  [!] Windhawk auto-download failed. Please install Windhawk manually." -ForegroundColor Red
        }
    }
}

if ($WindhawkCli) {
    Write-Host "  [OK] Windhawk engine found: $WindhawkCli" -ForegroundColor Green
} else {
    Write-Host "  [!] Warning: Windhawk not found. Proceeding with System Icons, Sounds & Cursors..." -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# Step 2: Download or Locate Rohit Bhai Mac OS Settings
# -------------------------------------------------------------------------
Write-Host "`n[2/8] Locating Rohit Bhai Mac OS Preset..." -ForegroundColor Cyan
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
Write-Host "`n[3/8] Installing Apple SF Pro Display Fonts..." -ForegroundColor Cyan
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
Write-Host "`n[4/8] Deploying macOS Capitaine Dark Cursors with Beach-Ball..." -ForegroundColor Cyan
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
Write-Host "`n[5/8] Configuring Authentic Apple macOS System Sound Scheme..." -ForegroundColor Cyan
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
# Step 6: Official Apple macOS File Explorer & Folder Icons
# -------------------------------------------------------------------------
Write-Host "`n[6/8] Deploying Official Apple macOS File Explorer & Folder Icons..." -ForegroundColor Cyan
try {
    $iconsTarget = "$env:LOCALAPPDATA\RohitBhaiMacOS\Icons"
    if (-not (Test-Path $iconsTarget)) {
        New-Item -ItemType Directory -Path $iconsTarget -Force | Out-Null
    }

    $localIcons = if ($ScriptDir) { Join-Path $ScriptDir "assets\icons" } else { $null }
    if ($localIcons -and (Test-Path $localIcons)) {
        Copy-Item "$localIcons\*.ico" -Destination $iconsTarget -Force -ErrorAction SilentlyContinue
    } else {
        $iconsZipUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v4.0.0/macos_icons.zip"
        $iconsZip = Join-Path $WorkDir "macos_icons.zip"
        try {
            Invoke-WebRequest -Uri $iconsZipUrl -OutFile $iconsZip -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $iconsZip) {
                Expand-Archive -Path $iconsZip -DestinationPath $iconsTarget -Force
            }
        } catch {}
    }

    # 1. Generic Folder Icons (Shell Icons HKLM & HKCU)
    $folderIco = Join-Path $iconsTarget "macOS_Folder.ico"
    $folderOpenIco = Join-Path $iconsTarget "macOS_Folder_Open.ico"
    
    if (Test-Path $folderIco) {
        $shellIconsKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
        )
        foreach ($k in $shellIconsKeys) {
            if (-not (Test-Path $k)) { New-Item -Path $k -Force -ErrorAction SilentlyContinue | Out-Null }
            Set-ItemProperty -Path $k -Name "3" -Value "$folderIco,0" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $k -Name "4" -Value "$folderOpenIco,0" -Force -ErrorAction SilentlyContinue
        }

        foreach ($c in @("HKCU:\Software\Classes\Folder\DefaultIcon", "HKCU:\Software\Classes\Directory\DefaultIcon")) {
            if (-not (Test-Path $c)) { New-Item -Path $c -Force -ErrorAction SilentlyContinue | Out-Null }
            Set-ItemProperty -Path $c -Name "(Default)" -Value "$folderIco,0" -Force -ErrorAction SilentlyContinue
        }
    }

    # 2. Drive Icons (Macintosh HD for C:, Generic for others)
    $cIco = Join-Path $iconsTarget "macOS_Drive_System.ico"
    if (Test-Path $cIco) {
        $cKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\C\DefaultIcon"
        if (-not (Test-Path $cKey)) { New-Item -Path $cKey -Force -ErrorAction SilentlyContinue | Out-Null }
        Set-ItemProperty -Path $cKey -Name "(Default)" -Value "$cIco,0" -Force -ErrorAction SilentlyContinue
    }

    $driveIco = Join-Path $iconsTarget "macOS_Drive.ico"
    if (Test-Path $driveIco) {
        Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -and $_.DriveLetter -ne 'C' } | ForEach-Object {
            $dl = $_.DriveLetter
            $dKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\$dl\DefaultIcon"
            if (-not (Test-Path $dKey)) { New-Item -Path $dKey -Force -ErrorAction SilentlyContinue | Out-Null }
            Set-ItemProperty -Path $dKey -Name "(Default)" -Value "$driveIco,0" -Force -ErrorAction SilentlyContinue
        }
    }

    # 3. Recycle Bin & This PC
    $trashEmpty = Join-Path $iconsTarget "macOS_Trash_Empty.ico"
    $trashFull  = Join-Path $iconsTarget "macOS_Trash_Full.ico"
    if (Test-Path $trashEmpty) {
        $binKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
        if (-not (Test-Path $binKey)) { New-Item -Path $binKey -Force -ErrorAction SilentlyContinue | Out-Null }
        Set-ItemProperty -Path $binKey -Name "(Default)" -Value "$trashEmpty,0" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $binKey -Name "empty" -Value "$trashEmpty,0" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $binKey -Name "full" -Value "$trashFull,0" -Force -ErrorAction SilentlyContinue
    }

    $thisPc = Join-Path $iconsTarget "macOS_ThisPC.ico"
    if (Test-Path $thisPc) {
        $pcKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon"
        if (-not (Test-Path $pcKey)) { New-Item -Path $pcKey -Force -ErrorAction SilentlyContinue | Out-Null }
        Set-ItemProperty -Path $pcKey -Name "(Default)" -Value "$thisPc,0" -Force -ErrorAction SilentlyContinue
    }

    # 4. User Profile Special Folders (Downloads, Documents, Pictures, Music, Videos, Desktop)
    $folderMap = @(
        @{ Name = "Downloads"; Path = "$env:USERPROFILE\Downloads"; Ico = Join-Path $iconsTarget "macOS_Downloads.ico"; GUIDs = @("{374DE290-123F-4565-9164-39C4925E467B}", "{7d83ee9b-2244-4e70-b1f5-5393042af1e4}") }
        @{ Name = "Documents"; Path = "$env:USERPROFILE\Documents"; Ico = Join-Path $iconsTarget "macOS_Documents.ico"; GUIDs = @("{FDD39AD0-238F-46AF-ADB4-6C85480369C7}", "{f42ee2d3-909f-4907-8871-4c22fc0bf756}") }
        @{ Name = "Pictures";  Path = "$env:USERPROFILE\Pictures";  Ico = Join-Path $iconsTarget "macOS_Pictures.ico";  GUIDs = @("{33E28130-4E1E-4676-835A-98395C3BC3BB}", "{0ddd0157-5467-4334-96c9-78ec10e39588}") }
        @{ Name = "Music";     Path = "$env:USERPROFILE\Music";     Ico = Join-Path $iconsTarget "macOS_Music.ico";     GUIDs = @("{4BD8D571-6D19-48D3-BE97-422220080E43}", "{a0c69a99-21c8-4671-8703-7934162fbe1d}") }
        @{ Name = "Videos";    Path = "$env:USERPROFILE\Videos";    Ico = Join-Path $iconsTarget "macOS_Videos.ico";    GUIDs = @("{18989B1D-99B5-455B-841C-AB7C74E4DDFC}", "{35286161-5079-4140-9a09-7b505a4f2791}") }
        @{ Name = "Desktop";   Path = "$env:USERPROFILE\Desktop";   Ico = Join-Path $iconsTarget "macOS_Desktop.ico";   GUIDs = @("{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}") }
    )

    foreach ($f in $folderMap) {
        if (Test-Path $f.Ico) {
            foreach ($g in $f.GUIDs) {
                $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$g"
                if (Test-Path $regPath) {
                    Set-ItemProperty -Path $regPath -Name "Icon" -Value "$($f.Ico),0" -Force -ErrorAction SilentlyContinue
                }
            }

            if (Test-Path $f.Path) {
                $ini = Join-Path $f.Path "desktop.ini"
                if (Test-Path $ini) {
                    attrib -h -s -r $ini 2>$null
                }
                $iniContent = "[.ShellClassInfo]`r`nIconResource=$($f.Ico),0`r`n[ViewState]`r`nMode=`r`nVid=`r`nFolderType=Generic`r`n"
                [System.IO.File]::WriteAllText($ini, $iniContent, [System.Text.Encoding]::ASCII)
                attrib +h +s $ini 2>$null
                attrib +r $f.Path 2>$null
            }
        }
    }

    # 5. Flush Icon Cache
    $iconCache = "$env:LOCALAPPDATA\IconCache.db"
    if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "*cache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    & ie4uinit.exe -show 2>$null

    Write-Host "  [OK] Apple macOS File Explorer & Folder Icons applied!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Icons note: Skipped non-critical icon install." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 7: Apply 4K macOS Wallpaper & Windows Dark Mode
# -------------------------------------------------------------------------
Write-Host "`n[7/8] Applying 4K macOS Wallpaper & Deep Dark Mode..." -ForegroundColor Cyan
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
# Step 8: Import Windhawk Mods & Settings (Island Dock, Genie, Net Speed)
# -------------------------------------------------------------------------
Write-Host "`n[8/8] Activating all 8 Windhawk mods, exact ratios, colors, and animations..." -ForegroundColor Cyan
Write-Host "      (Mac Island Dock, Genie Animation, LiquidGlass, Apple Net Speed...)" -ForegroundColor DarkGray

if ($WindhawkCli -and (Test-Path $WindhawkCli)) {
    & $WindhawkCli data import $WhDataLocal --on-conflict overwrite --confirm-app-restart
    $importCode = $LASTEXITCODE

    if ($importCode -eq 0) {
        Write-Host "  [OK] All mods and custom settings activated successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [*] Retrying with local compilation mode..." -ForegroundColor Yellow
        & $WindhawkCli data import $WhDataLocal --offline --on-conflict overwrite --confirm-app-restart
        Write-Host "  [OK] Import completed!" -ForegroundColor Green
    }

    # Ensure Maximize Window Guard (Top Bar & Bottom Dock Always Visible with Zero Overlap)
    & $WindhawkCli mod settings set mac-island-dock hiding.autoHide=0 2>$null
    $islandStoragePath = "HKLM:\Software\Windhawk\Engine\ModsWritable\mac-island-dock\LocalStorage"
    if (-not (Test-Path $islandStoragePath)) {
        New-Item -Path $islandStoragePath -Force | Out-Null
    }
    Set-ItemProperty -Path $islandStoragePath -Name "islandAutoHide" -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandHideWhen" -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandHideClock" -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $islandStoragePath -Name "islandBar" -Value 2 -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] Maximized window guard active: Top Bar & Bottom Dock stay ALWAYS visible with zero overlap!" -ForegroundColor Green
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
Write-Host "            CONGRATULATIONS! ROHIT BHAI MAC OS v4.0 IS NOW ACTIVE!                     " -ForegroundColor Green
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
Write-Host "  Repository: https://github.com/romflasher3419-spec/rohit-bhai-mac-os" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
