# ==============================================================================
# Rohit Bhai Mac OS - Complete Uninstaller & Windows Restore Suite
# Target: Windows 11 / Windows 10
# Reverts Windhawk mods, cursor schemes, sound schemes, folder icons, and fonts safely
# Crafted for Rohit Bhai | 100% Native Pure PowerShell
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

$RepoOwner = "Rohit-Bhai-Youtube"
$RepoName  = "rohit-bhai-mac-os"
$Branch    = "main"
$WebUninstallUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/uninstall.ps1"

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $elevateCmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$WebUninstallUrl' | iex"
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
              ROHIT BHAI MAC OS - 1-CLICK UNINSTALLER & RESTORER
                               Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Yellow

Write-Host "  [*] Reverting macOS customization and restoring original Windows defaults..." -ForegroundColor White
Write-Host ""

# -------------------------------------------------------------------------
# Step 1: Terminate Island Daemon & Remove Startup Persistence
# -------------------------------------------------------------------------
Write-Host "[1/7] Removing Background Daemons & Startup Entries..." -ForegroundColor Cyan
try {
    # Kill running island daemon powershell background jobs
    Get-CimInstance Win32_Process -Filter "Name like 'powershell%'" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*run_island_daemon.ps1*"
    } | ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

    # Remove Startup folder VBS
    $startupFolder = [Environment]::GetFolderPath('Startup')
    $vbsPath = Join-Path $startupFolder "RohitBhai_Mac_Island.vbs"
    if (Test-Path $vbsPath) {
        Remove-Item $vbsPath -Force -ErrorAction SilentlyContinue
    }

    # Remove Run registry keys
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RohitBhai_Mac_Island' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Windhawk' -ErrorAction SilentlyContinue

    Write-Host "  [OK] Startup daemons removed!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped startup cleanup." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 2: Reset Sound Scheme to Windows Default
# -------------------------------------------------------------------------
Write-Host "`n[2/7] Restoring Windows Default Sound Scheme..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value ".Default" -Force -ErrorAction SilentlyContinue
    if (Test-Path "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS") {
        Remove-Item "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  [OK] Sound scheme restored to Windows Default!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped sound scheme reset." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 3: Reset Cursors to Windows Default
# -------------------------------------------------------------------------
Write-Host "`n[3/7] Restoring Windows Default Cursors..." -ForegroundColor Cyan
try {
    $schemePath = "HKCU:\Control Panel\Cursors"
    Set-ItemProperty -Path $schemePath -Name "(Default)" -Value "Windows Default" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $schemePath -Name "Scheme Source" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    $cursorKeys = @("Arrow","Help","AppStarting","Wait","Crosshair","IBeam","NWPen","No","SizeNS","SizeWE","SizeNWSE","SizeNESW","SizeAll","UpArrow","Hand")
    foreach ($cur in $cursorKeys) {
        Remove-ItemProperty -Path $schemePath -Name $cur -ErrorAction SilentlyContinue
    }

    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32CursorReset {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@ -ErrorAction SilentlyContinue
    [Win32CursorReset]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 3) | Out-Null
    Write-Host "  [OK] Cursors restored to Windows Default!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped cursor reset." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 4: Reset File Explorer & Folder Icons
# -------------------------------------------------------------------------
Write-Host "`n[4/7] Restoring Windows Default Folder & Drive Icons..." -ForegroundColor Cyan
try {
    # Remove Shell Icons overrides
    $shellIconsKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    )
    foreach ($k in $shellIconsKeys) {
        if (Test-Path $k) {
            Remove-Item -Path $k -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Remove HKCU Classes Folder overrides
    foreach ($c in @("HKCU:\Software\Classes\Folder\DefaultIcon", "HKCU:\Software\Classes\Directory\DefaultIcon")) {
        if (Test-Path $c) {
            Remove-Item -Path $c -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Remove DriveIcons overrides
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons") {
        Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Reset Recycle Bin & This PC in HKCU
    $binKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
    if (Test-Path $binKey) {
        Set-ItemProperty -Path $binKey -Name "(Default)" -Value "C:\WINDOWS\System32\imageres.dll,-54" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $binKey -Name "empty" -Value "C:\WINDOWS\System32\imageres.dll,-55" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $binKey -Name "full" -Value "C:\WINDOWS\System32\imageres.dll,-54" -Force -ErrorAction SilentlyContinue
    }

    $pcKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon"
    if (Test-Path $pcKey) {
        Set-ItemProperty -Path $pcKey -Name "(Default)" -Value "C:\WINDOWS\System32\imageres.dll,-109" -Force -ErrorAction SilentlyContinue
    }

    # Reset FolderDescriptions
    $folderDefaults = @{
        "{374DE290-123F-4565-9164-39C4925E467B}" = "C:\WINDOWS\system32\imageres.dll,-184" # Downloads
        "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}" = "C:\WINDOWS\system32\imageres.dll,-112" # Personal (Documents)
        "{f42ee2d3-909f-4907-8871-4c22fc0bf756}" = "C:\WINDOWS\system32\imageres.dll,-112" # Documents
        "{33E28130-4E1E-4676-835A-98395C3BC3BB}" = "C:\WINDOWS\system32\imageres.dll,-113" # Pictures
        "{4BD8D571-6D19-48D3-BE97-422220080E43}" = "C:\WINDOWS\system32\imageres.dll,-108" # Music
        "{18989B1D-99B5-455B-841C-AB7C74E4DDFC}" = "C:\WINDOWS\system32\imageres.dll,-189" # Video
        "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" = "C:\WINDOWS\system32\imageres.dll,-183" # Desktop
    }
    foreach ($g in $folderDefaults.Keys) {
        $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$g"
        if (Test-Path $p) {
            Set-ItemProperty -Path $p -Name "Icon" -Value $folderDefaults[$g] -Force -ErrorAction SilentlyContinue
        }
    }

    # Clean desktop.ini in user profile folders
    $userDirs = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Music",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\Desktop"
    )
    foreach ($d in $userDirs) {
        $ini = Join-Path $d "desktop.ini"
        if (Test-Path $ini) {
            $content = Get-Content -Path $ini -Raw -ErrorAction SilentlyContinue
            if ($content -match "RohitBhaiMacOS") {
                attrib -h -s -r $ini 2>$null
                Remove-Item $ini -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Flush icon and thumbnail cache
    $iconCache = "$env:LOCALAPPDATA\IconCache.db"
    if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }
    Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "*cache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    & ie4uinit.exe -show 2>$null

    Write-Host "  [OK] Default Windows folder and drive icons restored!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped folder icons reset." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 5: Clean SF Pro Font Registrations
# -------------------------------------------------------------------------
Write-Host "`n[5/7] Cleaning Installed Custom Fonts..." -ForegroundColor Cyan
try {
    $fontReg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (Test-Path $fontReg) {
        $props = Get-ItemProperty -Path $fontReg -ErrorAction SilentlyContinue
        foreach ($p in $props.PSObject.Properties) {
            if ($p.Value -and ($p.Value -like "*RohitBhaiMacOS*")) {
                Remove-ItemProperty -Path $fontReg -Name $p.Name -Force -ErrorAction SilentlyContinue
            }
        }
    }
    Write-Host "  [OK] Font registrations cleaned!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped font cleanup." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 6: Disable and Remove Windhawk Mods
# -------------------------------------------------------------------------
Write-Host "`n[6/7] Removing Windhawk Mods (Island Dock, Genie Animation, Net Speed)..." -ForegroundColor Cyan

function Find-WindhawkCli {
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

    try {
        $proc = Get-Process -Name "windhawk" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($proc -and $proc.Path) {
            $cli = Join-Path (Split-Path $proc.Path -Parent) "windhawk-cli.exe"
            if (Test-Path $cli) { return $cli }
        }
    } catch {}

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
                }
            }
        } catch {}
    }

    return $null
}

$WindhawkCli = Find-WindhawkCli

if ($WindhawkCli -and (Test-Path $WindhawkCli)) {
    $mods = @(
        "mac-island-dock",
        "macos-minimize-animation",
        "local@net-speed-taskbar-apple",
        "windows-11-start-menu-styler",
        "windows-11-notification-center-styler",
        "windows-11-file-explorer-styler",
        "translucent-windows",
        "invisible-borders",
        "caption-buttons-customizer",
        "local@caption-buttons-customizer",
        "rohit-bhai-mac-os"
    )

    foreach ($m in $mods) {
        & $WindhawkCli mod disable $m --yes 2>$null
        & $WindhawkCli mod remove $m --yes 2>$null
    }

    # Clean custom local storage
    Remove-Item -Path "HKLM:\Software\Windhawk\Engine\ModsWritable\mac-island-dock" -Recurse -Force -ErrorAction SilentlyContinue

    $whExe = Join-Path (Split-Path $WindhawkCli -Parent) "windhawk.exe"
    if (Test-Path $whExe) {
        & $whExe -restart -tray-only 2>$null
    }
    Write-Host "  [OK] Windhawk mods removed cleanly!" -ForegroundColor Green
} else {
    Write-Host "  [-] Windhawk CLI not found (skipping mod unregistration)." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 7: Clean Rohit Bhai Mac OS Directory & Refresh Explorer
# -------------------------------------------------------------------------
Write-Host "`n[7/7] Cleaning System Cache & Refreshing Windows Explorer..." -ForegroundColor Cyan

# Remove app data directory
$appDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
if (Test-Path $appDir) {
    Remove-Item -Path $appDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Restart Windows Explorer
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "         CONGRATULATIONS! ROHIT BHAI MAC OS HAS BEEN COMPLETELY UNINSTALLED!            " -ForegroundColor Green
Write-Host "                    Original Windows 11 defaults are fully restored!                    " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
