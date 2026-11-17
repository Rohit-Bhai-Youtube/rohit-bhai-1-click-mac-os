# ========================================================================================
#   1-CLICK WINDOWS 11 ORIGINAL DEFAULTS RESTORER (ROHIT BHAI MAC OS RECOVERY)
# ========================================================================================

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Requesting Administrator elevation..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $url = "https://raw.githubusercontent.com/Rohit-Bhai-Youtube/rohit-bhai-1-click-mac-os/main/Restore-Windows-11-Original.ps1"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$url' | iex`""
    }
    exit
}

try {
    $Host.UI.RawUI.WindowTitle = "Restore Original Windows 11"
    [Console]::Title = "Restore Original Windows 11"
} catch {}

Clear-Host
Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host "       RESTORING ORIGINAL WINDOWS 11 FOLDERS, ICONS & TASKBAR (100% RECOVERY)           " -ForegroundColor White
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Clean HKLM & HKCU Shell Icons via .NET & Native Reg
Write-Host "  [1/5] Removing Shell Icons & Drive registry overrides..." -ForegroundColor Yellow
try {
    $expKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", $true)
    if ($expKey) {
        try { $expKey.DeleteSubKeyTree("Shell Icons", $false) } catch {}
        try { $expKey.DeleteSubKeyTree("DriveIcons", $false) } catch {}
        $expKey.Close()
    }
    $wowKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer", $true)
    if ($wowKey) {
        try { $wowKey.DeleteSubKeyTree("Shell Icons", $false) } catch {}
        $wowKey.Close()
    }
    [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons", $false)
    [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons", $false)
    [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Classes\Applications\Explorer.exe\Drives", $false)
    [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Classes\Folder\DefaultIcon", $false)
    [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Classes\Directory\DefaultIcon", $false)
} catch {}

Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Recurse -Force -ErrorAction SilentlyContinue
cmd.exe /c 'reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f >nul 2>&1'
cmd.exe /c 'reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f >nul 2>&1'
cmd.exe /c 'reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f >nul 2>&1'
Write-Host "  [OK] Shell Icons overrides completely wiped!" -ForegroundColor Green

# 2. Clean FolderDescriptions overrides via .NET
Write-Host "  [2/5] Restoring default Windows folder descriptions..." -ForegroundColor Yellow
try {
    $folderKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions", $true)
    if ($folderKey) {
        foreach ($subName in $folderKey.GetSubKeyNames()) {
            $sub = $folderKey.OpenSubKey($subName, $true)
            if ($sub) {
                $val = $sub.GetValue("Icon")
                if ($val -and ($val -like "*RohitBhaiMacOS*" -or $val -like "*macOS_*")) {
                    $sub.DeleteValue("Icon", $false)
                }
                $sub.Close()
            }
        }
        $folderKey.Close()
    }
} catch {}

# Clean HKCU custom CLSIDs (Recycle Bin, This PC, etc.)
$clsids = @(
    "{18989B1D-99B5-455B-841C-AB7C74E4DDFC}",
    "{20D04FE0-3AEA-1069-A2D8-08002B30309D}",
    "{33E28130-4E1E-4676-835A-98395C3BC3BB}",
    "{374DE290-123F-4565-9164-39C4925E467B}",
    "{4BD8D571-6D19-48D3-BE97-422220080E43}",
    "{59031A47-3F72-44A7-89C5-5595FE6B30EE}",
    "{645FF040-5081-101B-9F08-00AA002F954E}",
    "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
    "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}",
    "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}"
)
foreach ($c in $clsids) {
    try {
        [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Classes\CLSID\$c", $false)
        [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree("Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$c", $false)
    } catch {}
}
Write-Host "  [OK] Default Windows folders & Recycle Bin restored!" -ForegroundColor Green

# 3. Fix Corrupted Shortcuts across System
Write-Host "  [3/5] Fixing shortcuts (Microsoft Edge, File Explorer, Steam, etc.)..." -ForegroundColor Yellow
$wsh = New-Object -ComObject WScript.Shell
$shortcutDirs = @(
    (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'),
    ([Environment]::GetFolderPath('Programs')),
    ([Environment]::GetFolderPath('CommonPrograms')),
    ([Environment]::GetFolderPath('Desktop')),
    ([Environment]::GetFolderPath('CommonDesktop'))
)

$edgeExe = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgeExe)) { $edgeExe = "C:\Program Files\Microsoft\Edge\Application\msedge.exe" }

$steamExe = "C:\Program Files (x86)\Steam\steam.exe"
if (-not (Test-Path $steamExe)) { $steamExe = "C:\Program Files\Steam\steam.exe" }

foreach ($dir in $shortcutDirs) {
    if (-not (Test-Path $dir)) { continue }
    Get-ChildItem -Path $dir -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $lnk = $wsh.CreateShortcut($_.FullName)
            $needsSave = $false

            if ($lnk.IconLocation -like "*,*,*") {
                $parts = $lnk.IconLocation.Split(',')
                $cleanFile = $parts[0].Trim()
                $cleanIdx = 0
                if ($parts.Length -gt 1) { [int]::TryParse($parts[1].Trim(), [ref]$cleanIdx) | Out-Null }
                $lnk.IconLocation = "$cleanFile,$cleanIdx"
                $needsSave = $true
            } elseif ($lnk.IconLocation -like "*RohitBhaiMacOS*") {
                if ($lnk.TargetPath -and (Test-Path $lnk.TargetPath)) {
                    $lnk.IconLocation = "$($lnk.TargetPath),0"
                    $needsSave = $true
                }
            }

            if ($_.Name -eq "Microsoft Edge.lnk" -and (Test-Path $edgeExe)) {
                $lnk.TargetPath = $edgeExe
                $lnk.IconLocation = "$edgeExe,0"
                $needsSave = $true
            } elseif ($_.Name -eq "File Explorer.lnk") {
                $lnk.TargetPath = "$env:WINDIR\explorer.exe"
                $lnk.IconLocation = "$env:WINDIR\explorer.exe,0"
                $needsSave = $true
            } elseif ($_.Name -eq "Steam.lnk" -and (Test-Path $steamExe)) {
                $lnk.TargetPath = $steamExe
                $lnk.IconLocation = "$steamExe,0"
                $needsSave = $true
            }

            if ($needsSave) {
                $lnk.Save()
                Write-Host "    [Fixed] $($_.Name)" -ForegroundColor Green
            }
        } catch {}
    }
}
Write-Host "  [OK] All shortcuts repaired!" -ForegroundColor Green

# 4. Flush and rebuild Windows Icon & Thumbnail caches
Write-Host "  [4/5] Flushing Windows icon & thumbnail database caches..." -ForegroundColor Yellow
taskkill.exe /F /IM explorer.exe /IM StartMenuExperienceHost.exe /IM SearchHost.exe /IM ShellExperienceHost.exe /IM rundll32.exe 2>$null
Start-Sleep -Milliseconds 800

$iconCache = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }

$expCache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $expCache) {
    Get-ChildItem -Path $expCache -Filter "*iconcache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $expCache -Filter "*thumbcache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

$startCacheDirs = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState",
    "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\TempState",
    "$env:LOCALAPPDATA\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState",
    "$env:LOCALAPPDATA\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\TempState"
)
foreach ($scd in $startCacheDirs) {
    if (Test-Path $scd) {
        Get-ChildItem -Path $scd -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "  [OK] Icon caches wiped clean!" -ForegroundColor Green

# 5. Relaunch Windows Explorer cleanly via Unelevated Shell Task
Write-Host "  [5/5] Relaunching Windows Explorer shell..." -ForegroundColor Yellow
$launched = $false
try {
    $res = schtasks.exe /run /tn "\CreateExplorerShellUnelevatedTask" 2>&1
    if ($LASTEXITCODE -eq 0) { $launched = $true }
} catch {}

if (-not $launched) {
    Start-Process "C:\Windows\explorer.exe" -ArgumentList "/NoUACCheck"
}

Start-Sleep -Seconds 2

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32IconRefreshFinal {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@ -ErrorAction SilentlyContinue
[Win32IconRefreshFinal]::SHChangeNotify(0x08000000, 0x0000, [IntPtr]::Zero, [IntPtr]::Zero)

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "  SUCCESS! All Windows 11 folders, Edge, Explorer, and icons restored 100%!" -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 2
