# ==============================================================================
# Rohit Bhai 1 Click Mac OS - Complete 1-Click Uninstaller & Windows Restore Suite
# Target: Windows 11 / Windows 10
# Reverts 100% of Windhawk mods, cursor schemes, sound schemes, folder & drive icons,
# taskbar shortcuts, wallpaper, and restores original Windows defaults.
# Crafted for Rohit Bhai | 100% Native Pure PowerShell
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

$RepoOwner = "Rohit-Bhai-Youtube"
$RepoName  = "rohit-bhai-1-click-mac-os"
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
              ROHIT BHAI 1 CLICK MAC OS - 1-CLICK UNINSTALLER & RESTORER
                               Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Yellow

Write-Host "  [*] Restoring 100% original Windows 11 defaults across all system components..." -ForegroundColor White
Write-Host ""

# -------------------------------------------------------------------------
# Step 1: Terminate Island Daemon & Remove Startup Persistence
# -------------------------------------------------------------------------
Write-Host "[1/8] Removing Background Daemons & Startup Entries..." -ForegroundColor Cyan
try {
    # Terminate running island daemon powershell background jobs
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

    Write-Host "  [OK] Startup daemons and persistence removed!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped startup cleanup." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 2: Disable and Remove Windhawk Mods & Reset Engine
# -------------------------------------------------------------------------
Write-Host "`n[2/8] Removing Windhawk Mods (Island Dock, Genie Animation, Net Speed)..." -ForegroundColor Cyan

function Find-WindhawkCli {
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

if ($WindhawkCli -and (Test-Path $WindhawkCli)) {
    $mods = @(
        "mac-island-dock",
        "macos-minimize-animation",
        "net-speed-taskbar",
        "net-speed-taskbar-apple",
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
}

# Stop Windhawk service and processes before wiping registry keys
Stop-Process -Name "windhawk", "windhawk-cli" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "windhawk" -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 600

# Clean all Windhawk Engine custom mods & local storage across 64-bit and 32-bit registry
Remove-Item -Path "HKLM:\SOFTWARE\Windhawk\Engine\Mods\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Windhawk\Engine\ModsWritable\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Windhawk\Engine\Mods\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Windhawk\Engine\ModsWritable\*" -Recurse -Force -ErrorAction SilentlyContinue

if ($WindhawkExe -and (Test-Path $WindhawkExe)) {
    Start-Service -Name "windhawk" -ErrorAction SilentlyContinue
    & $WindhawkExe -restart -tray-only 2>$null
    Write-Host "  [OK] Windhawk mods removed & engine reset to clean default!" -ForegroundColor Green
} else {
    Write-Host "  [OK] Windhawk configuration cleaned!" -ForegroundColor Green
}

# -------------------------------------------------------------------------
# Step 3: Reset Drive Icons & Remove 'Macintosh HD' Label Overrides
# -------------------------------------------------------------------------
Write-Host "`n[3/8] Restoring Windows C: Drive & Default Storage Labels..." -ForegroundColor Cyan
try {
    # Remove all DriveIcons and Drive label overrides across HKLM, WOW6432Node, and HKCU
    $driveKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
        "HKCU:\Software\Classes\Applications\Explorer.exe\Drives",
        "HKCU:\Software\Classes\Applications\explorer.exe\Drives"
    )
    foreach ($dk in $driveKeys) {
        if (Test-Path $dk) {
            Remove-Item -Path $dk -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Reset C: drive filesystem volume label to standard 'Windows'
    try {
        Set-Volume -DriveLetter C -NewFileSystemLabel "Windows" -ErrorAction SilentlyContinue
    } catch {}
    cmd.exe /c "label C: Windows" 2>$null

    Write-Host "  [OK] Drive C: restored back to original 'Windows (C:)'! No more Macintosh HD!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped drive label cleanup." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 4: Reset File Explorer & Folder Icons
# -------------------------------------------------------------------------
Write-Host "`n[4/8] Restoring Windows Default Folder & System Icons..." -ForegroundColor Cyan
try {
    # Remove Shell Icons overrides using .NET and native commands across 64-bit and 32-bit registry
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
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Recurse -Force -ErrorAction SilentlyContinue
    & reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f /reg:64 2>$null
    & reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f /reg:32 2>$null
    & reg.exe delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f /reg:64 2>$null
    & reg.exe delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f /reg:32 2>$null
    & reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /f 2>$null

    # Remove custom CLSID overrides in HKCU Classes
    $customClsids = @(
        "HKCU\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}",
        "HKCU\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}",
        "HKCU\Software\Classes\CLSID\{59031A47-3F72-44A7-89C5-5595FE6B30EE}",
        "HKCU\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}",
        "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}",
        "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    )
    foreach ($cls in $customClsids) {
        & reg.exe delete "$cls" /f 2>$null
    }

    # Delete custom Icon value from all FolderDescriptions so Windows defaults kick in
    $fdPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions"
    if (Test-Path $fdPath) {
        Get-ChildItem -Path $fdPath -ErrorAction SilentlyContinue | ForEach-Object {
            $subPath = $_.PSPath
            if (Get-ItemProperty -Path $subPath -Name "Icon" -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $subPath -Name "Icon" -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Clean custom desktop.ini across ALL C: root directories, system directories, and user profile directories
    $allDirsToClean = @(
        "C:\adb",
        "C:\inetpub",
        "C:\PerfLogs",
        "C:\Program Files",
        "C:\Program Files (x86)",
        "C:\Users",
        $env:USERPROFILE,
        [Environment]::GetFolderPath('Desktop'),
        [Environment]::GetFolderPath('MyDocuments'),
        [Environment]::GetFolderPath('MyPictures'),
        [Environment]::GetFolderPath('MyMusic'),
        [Environment]::GetFolderPath('MyVideos'),
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\OneDrive"
    )
    if (Test-Path $env:USERPROFILE) {
        $subDirs = Get-ChildItem -Path $env:USERPROFILE -Directory -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        if ($subDirs) { $allDirsToClean += $subDirs }
    }
    if (Test-Path "$env:USERPROFILE\OneDrive") {
        $odDirs = Get-ChildItem -Path "$env:USERPROFILE\OneDrive" -Directory -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        if ($odDirs) { $allDirsToClean += $odDirs }
    }
    if (Test-Path "C:\") {
        $cDirs = Get-ChildItem -Path "C:\" -Directory -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        if ($cDirs) { $allDirsToClean += $cDirs }
    }
    $allDirsToClean = $allDirsToClean | Select-Object -Unique

    foreach ($d in $allDirsToClean) {
        if ($d -and (Test-Path -LiteralPath $d)) {
            $ini = Join-Path $d "desktop.ini"
            if (Test-Path -LiteralPath $ini) {
                try {
                    takeown.exe /f "$ini" /a 2>$null
                    icacls.exe "$ini" /grant Administrators:F /q 2>$null
                    attrib.exe -h -s -r "$ini" 2>$null

                    $content = Get-Content -LiteralPath $ini -Raw -ErrorAction SilentlyContinue
                    if ($content -match "RohitBhaiMacOS|Finder|macOS|Sonoma") {
                        if ($d -eq "C:\Users") {
                            $userIni = "[.ShellClassInfo]`r`nLocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21813`r`nIconResource=%SystemRoot%\system32\imageres.dll,-123`r`n"
                            [System.IO.File]::WriteAllText($ini, $userIni, [System.Text.Encoding]::ASCII)
                            attrib.exe +h +s "$ini" 2>$null
                            attrib.exe +r "$d" 2>$null
                        } elseif ($d -eq "C:\Program Files") {
                            $pfIni = "[.ShellClassInfo]`r`nLocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21781`r`n"
                            [System.IO.File]::WriteAllText($ini, $pfIni, [System.Text.Encoding]::ASCII)
                            attrib.exe +h +s "$ini" 2>$null
                            attrib.exe +r "$d" 2>$null
                        } elseif ($d -eq "C:\Program Files (x86)") {
                            $pf86Ini = "[.ShellClassInfo]`r`nLocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21817`r`n"
                            [System.IO.File]::WriteAllText($ini, $pf86Ini, [System.Text.Encoding]::ASCII)
                            attrib.exe +h +s "$ini" 2>$null
                            attrib.exe +r "$d" 2>$null
                        } else {
                            Remove-Item -LiteralPath $ini -Force -ErrorAction SilentlyContinue
                            attrib.exe -r "$d" 2>$null
                        }
                    } else {
                        attrib.exe +h +s "$ini" 2>$null
                    }
                } catch {}
            }
        }
    }

    Write-Host "  [OK] Default Windows folder & system icons restored!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped folder icons reset." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 5: Restore Taskbar & Start Menu Shortcuts (Edge, Explorer, Native Apps)
# -------------------------------------------------------------------------
Write-Host "`n[5/8] Restoring Native Taskbar & Start Menu Shortcuts..." -ForegroundColor Cyan
try {
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
        
        if (!string.IsNullOrEmpty(iconPath)) {
            string filePart = iconPath;
            int iconIndex = 0;
            if (iconPath.Contains(",")) {
                string[] parts = iconPath.Split(',');
                filePart = parts[0].Trim();
                int.TryParse(parts[1].Trim(), out iconIndex);
            }
            shellLink.SetIconLocation(filePart, iconIndex);
        } else if (!string.IsNullOrEmpty(targetPath)) {
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

    $taskbarDir    = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
    $userStartDir  = [Environment]::GetFolderPath('Programs')
    $allStartDir   = [Environment]::GetFolderPath('CommonPrograms')
    $userDesktop   = [Environment]::GetFolderPath('Desktop')
    $commonDesktop = [Environment]::GetFolderPath('CommonDesktop')
    $backupDir     = "$env:LOCALAPPDATA\RohitBhaiMacOS\ShortcutsBackup"

    # 0. Restore from ShortcutsBackup if available
    if (Test-Path $backupDir) {
        if (Test-Path "$backupDir\TaskBar") {
            Copy-Item -Path "$backupDir\TaskBar\*.lnk" -Destination $taskbarDir -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path "$backupDir\UserStart") {
            Copy-Item -Path "$backupDir\UserStart\*.lnk" -Destination $userStartDir -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path "$backupDir\CommonStart") {
            Copy-Item -Path "$backupDir\CommonStart\*.lnk" -Destination $allStartDir -Force -ErrorAction SilentlyContinue
        }
    }

    # 1. Clean duplicate *(2).lnk, *(3).lnk in taskbar
    if (Test-Path $taskbarDir) {
        Get-ChildItem -Path $taskbarDir -Filter "*(*).lnk" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    # 2. Delete artificial UWP launcher shortcuts created in user Start Menu & All Users Start Menu
    # On clean Windows 11, UWP apps are enumerated directly by AppX, not .lnk files in Programs!
    $uwpShortcutsToRemove = @(
        "Apple Music.lnk",
        "Calculator.lnk",
        "File Explorer.lnk",
        "Media Player.lnk",
        "Notepad.lnk",
        "Photos.lnk",
        "Settings.lnk",
        "Task Manager.lnk",
        "Windows Terminal.lnk",
        "WhatsApp.lnk",
        "Telegram.lnk",
        "Microsoft Store.lnk",
        "Finder.lnk",
        "Safari.lnk",
        "Activity Monitor.lnk"
    )
    foreach ($scName in $uwpShortcutsToRemove) {
        foreach ($base in @($userStartDir, $allStartDir)) {
            $p = Join-Path $base $scName
            if (Test-Path $p) {
                Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # 3. Restore 100% Native Microsoft Edge Shortcut with official AUMID (MSEdge)
    $edgeExes = @(
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
    )
    $edgeExe = $edgeExes | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($edgeExe) {
        # Restore Taskbar shortcut
        [MacAppShortcutHelper]::CreateOrUpdateShortcut((Join-Path $taskbarDir "Microsoft Edge.lnk"), $edgeExe, "", "$edgeExe,0", "MSEdge")
        # Restore Common Start Menu shortcut
        [MacAppShortcutHelper]::CreateOrUpdateShortcut((Join-Path $allStartDir "Microsoft Edge.lnk"), $edgeExe, "", "$edgeExe,0", "MSEdge")
        # Remove duplicate from User Start Menu if present
        $userEdge = Join-Path $userStartDir "Microsoft Edge.lnk"
        if (Test-Path $userEdge) { Remove-Item -LiteralPath $userEdge -Force -ErrorAction SilentlyContinue }
    }

    # 4. Restore 100% Native File Explorer Shortcut on Taskbar with official AUMID (Microsoft.Windows.Explorer)
    $explorerLnk = Join-Path $taskbarDir "File Explorer.lnk"
    [MacAppShortcutHelper]::CreateOrUpdateShortcut($explorerLnk, "$env:WINDIR\explorer.exe", "", "$env:WINDIR\explorer.exe,0", "Microsoft.Windows.Explorer")
    # Clean any File Explorer shortcut from Start Menu (not standard in Windows 11)
    foreach ($base in @($userStartDir, $allStartDir)) {
        $p = Join-Path $base "File Explorer.lnk"
        if (Test-Path $p) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }
    }

    # 5. Restore Microsoft Store Taskbar Shortcut with official AUMID
    $storeLnk = Join-Path $taskbarDir "Microsoft Store.lnk"
    if (Test-Path $storeLnk) {
        [MacAppShortcutHelper]::CreateOrUpdateShortcut($storeLnk, "$env:WINDIR\explorer.exe", "shell:AppsFolder\Microsoft.WindowsStore_8wekyb3d8bbwe!App", "", "Microsoft.WindowsStore_8wekyb3d8bbwe!App")
    }

    # 6. Restore Real Installed Desktop Apps (Discord, Steam)
    $discordExe = "$env:LOCALAPPDATA\Discord\Update.exe"
    if (-not (Test-Path $discordExe)) { $discordExe = "$env:LOCALAPPDATA\Discord\Discord.exe" }
    $discordInstalled = (Test-Path $discordExe)
    $discordLnks = @(
        (Join-Path $taskbarDir "Discord.lnk"),
        (Join-Path $userStartDir "Discord.lnk"),
        (Join-Path $userStartDir "Discord Inc\Discord.lnk"),
        (Join-Path $allStartDir "Discord.lnk")
    )
    foreach ($dl in $discordLnks) {
        if ($discordInstalled) {
            if (Test-Path $dl) {
                [MacAppShortcutHelper]::CreateOrUpdateShortcut($dl, $discordExe, "--processStart Discord.exe", "$discordExe,0", "com.squirrel.Discord.Discord")
            }
        } else {
            if (Test-Path $dl) { Remove-Item -LiteralPath $dl -Force -ErrorAction SilentlyContinue }
        }
    }

    $steamExe = "C:\Program Files (x86)\Steam\steam.exe"
    if (-not (Test-Path $steamExe)) { $steamExe = "C:\Program Files\Steam\steam.exe" }
    $steamInstalled = (Test-Path $steamExe)
    $steamLnks = @(
        (Join-Path $taskbarDir "Steam.lnk"),
        (Join-Path $userStartDir "Steam.lnk"),
        (Join-Path $allStartDir "Steam.lnk"),
        (Join-Path $allStartDir "Steam\Steam.lnk")
    )
    foreach ($sl in $steamLnks) {
        if ($steamInstalled) {
            if (Test-Path $sl) {
                [MacAppShortcutHelper]::CreateOrUpdateShortcut($sl, $steamExe, "", "$steamExe,0", "Valve.Steam")
            }
        } else {
            if (Test-Path $sl) { Remove-Item -LiteralPath $sl -Force -ErrorAction SilentlyContinue }
        }
    }

    # 7. Restore WhatsApp, Telegram & ChatGPT on Taskbar: restore native if installed, remove broken
    $wsh = New-Object -ComObject WScript.Shell
    $waApp = Get-AppxPackage -Name "*WhatsApp*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $waExe = "$env:LOCALAPPDATA\WhatsApp\WhatsApp.exe"
    $waInstalled = ($waApp -ne $null) -or (Test-Path $waExe)
    $waTb = Join-Path $taskbarDir "WhatsApp.lnk"
    if (-not $waInstalled -and (Test-Path $waTb)) {
        Remove-Item -LiteralPath $waTb -Force -ErrorAction SilentlyContinue
    } elseif ($waInstalled -and (Test-Path $waTb)) {
        try {
            $wLnk = $wsh.CreateShortcut($waTb)
            if (Test-Path $waExe) { $wLnk.IconLocation = "$waExe,0" } else { $wLnk.IconLocation = "" }
            $wLnk.Save()
        } catch {}
    }

    $tgApp = Get-AppxPackage -Name "*Telegram*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $tgExe = "$env:APPDATA\Telegram Desktop\Telegram.exe"
    if (-not (Test-Path $tgExe)) { $tgExe = "C:\Program Files\Telegram Desktop\Telegram.exe" }
    $tgInstalled = ($tgApp -ne $null) -or (Test-Path $tgExe)
    $tgTb = Join-Path $taskbarDir "Telegram.lnk"
    if (-not $tgInstalled -and (Test-Path $tgTb)) {
        Remove-Item -LiteralPath $tgTb -Force -ErrorAction SilentlyContinue
    } elseif ($tgInstalled -and (Test-Path $tgTb)) {
        try {
            $tLnk = $wsh.CreateShortcut($tgTb)
            if (Test-Path $tgExe) { $tLnk.IconLocation = "$tgExe,0" } else { $tLnk.IconLocation = "" }
            $tLnk.Save()
        } catch {}
    }

    $cgTb = Join-Path $taskbarDir "ChatGPT.lnk"
    if (Test-Path $cgTb) {
        try {
            $cLnk = $wsh.CreateShortcut($cgTb)
            $cLnk.IconLocation = ""
            $cLnk.Save()
        } catch {}
    }

    # 8. Remove Mac Dock-specific injected shortcuts from Taskbar (Settings, Music, Terminal, Photos, Calc, Notepad)
    $dockExtraLnks = @(
        "Settings.lnk",
        "Apple Music.lnk",
        "Windows Terminal.lnk",
        "Photos.lnk",
        "Calculator.lnk",
        "Notepad.lnk",
        "LAUNCHER.lnk"
    )
    foreach ($extraLnk in $dockExtraLnks) {
        $p = Join-Path $taskbarDir $extraLnk
        if (Test-Path $p) {
            Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
        }
        foreach ($base in @($userStartDir, $allStartDir)) {
            $sp = Join-Path $base $extraLnk
            if (Test-Path $sp) {
                Remove-Item -LiteralPath $sp -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # 9. Restore System Tools shortcuts to native system binaries
    $sysToolMap = @{
        "System Tools\Command Prompt.lnk"           = "$env:WINDIR\System32\cmd.exe,0"
        "Windows PowerShell\Windows PowerShell.lnk" = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe,0"
        "System Tools\Control Panel.lnk"            = "$env:WINDIR\System32\imageres.dll,-27"
        "System Tools\Task Manager.lnk"             = "$env:WINDIR\System32\Taskmgr.exe,0"
    }
    $wsh = New-Object -ComObject WScript.Shell
    foreach ($rel in $sysToolMap.Keys) {
        foreach ($base in @($userStartDir, $allStartDir)) {
            $p = Join-Path $base $rel
            if (Test-Path $p) {
                $sc = $wsh.CreateShortcut($p)
                $sc.IconLocation = $sysToolMap[$rel]
                $sc.Save()
            }
        }
    }

    # 9. Comprehensive Deep Scan for any remaining shortcuts pointing to RohitBhaiMacOS or broken icon paths
    $allShortcutDirs = @(
        $taskbarDir,
        $userStartDir,
        $allStartDir,
        $userDesktop,
        "$env:USERPROFILE\OneDrive\Desktop",
        $commonDesktop
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($dir in $allShortcutDirs) {
        Get-ChildItem -Path $dir -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $lnk = $wsh.CreateShortcut($_.FullName)
                $target = $lnk.TargetPath
                $icon = $lnk.IconLocation
                $iconFile = if ($icon) { $icon.Split(',')[0].Trim('"', ' ') } else { "" }
                $isMissingIcon = ($iconFile -and -not (Test-Path $iconFile))

                if ($target -like "*RohitBhaiMacOS*") {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
                } elseif ($icon -like "*RohitBhaiMacOS*" -or $isMissingIcon) {
                    if ($target -like "*explorer.exe*") {
                        $lnk.IconLocation = "$env:WINDIR\explorer.exe,0"
                        $lnk.Save()
                    } elseif ($target -like "*msedge.exe*") {
                        $lnk.IconLocation = "$target,0"
                        $lnk.Save()
                    } elseif ($target -and (Test-Path $target) -and ($target -match "\.exe$")) {
                        $lnk.IconLocation = "$target,0"
                        $lnk.Save()
                    } else {
                        $lnk.IconLocation = ""
                        $lnk.Save()
                    }
                }
            } catch {}
        }
    }

    # Clean custom desktop.ini from all Desktop and OneDrive Desktop folders
    foreach ($d in @($userDesktop, "$env:USERPROFILE\OneDrive\Desktop", $commonDesktop)) {
        if ($d -and (Test-Path $d)) {
            Get-ChildItem -Path $d -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
                $ini = Join-Path $_.FullName "desktop.ini"
                if (Test-Path -LiteralPath $ini) {
                    try {
                        attrib.exe -h -s -r "$ini" 2>$null
                        Remove-Item -LiteralPath $ini -Force -ErrorAction SilentlyContinue
                        attrib.exe -r "$($_.FullName)" 2>$null
                    } catch {}
                }
            }
        }
    }

    # 10. Purge Start Menu "Recently added" / MRU ghost shortcuts
    $recentDir = [Environment]::GetFolderPath('Recent')
    if (Test-Path $recentDir) {
        Get-ChildItem -Path $recentDir -Filter "*.lnk" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        $autoDest = Join-Path $recentDir "AutomaticDestinations"
        if (Test-Path $autoDest) {
            Get-ChildItem -Path $autoDest -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        }
        $customDest = Join-Path $recentDir "CustomDestinations"
        if (Test-Path $customDest) {
            Get-ChildItem -Path $customDest -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }

    # 11. Restart StartMenuExperienceHost and SearchHost to instantly flush ghosts
    Stop-Process -Name "StartMenuExperienceHost" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "SearchHost" -Force -ErrorAction SilentlyContinue

    # 12. Restore Windows Search Bar & Taskbar Buttons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    Write-Host "  [OK] Original Microsoft Edge, File Explorer, Start Menu, and app icons restored!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped taskbar shortcut restoration: $($_.Exception.Message)" -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 6: Reset Cursors & System Sounds to Windows Default
# -------------------------------------------------------------------------
Write-Host "`n[6/8] Restoring Default Windows Cursors & Sound Scheme..." -ForegroundColor Cyan
try {
    # 1. Reset sound scheme
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value ".Default" -Force -ErrorAction SilentlyContinue
    if (Test-Path "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS") {
        Remove-Item "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 2. Reset cursors
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

    # 3. Clean custom fonts
    $fontReg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (Test-Path $fontReg) {
        $props = Get-ItemProperty -Path $fontReg -ErrorAction SilentlyContinue
        foreach ($p in $props.PSObject.Properties) {
            if ($p.Value -and ($p.Value -like "*RohitBhaiMacOS*")) {
                Remove-ItemProperty -Path $fontReg -Name $p.Name -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Write-Host "  [OK] Cursors, Sounds, and Fonts restored to standard Windows defaults!" -ForegroundColor Green
} catch {
    Write-Host "  [-] Skipped cursor and sound reset." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 7: Restore Default Windows 11 Wallpaper
# -------------------------------------------------------------------------
Write-Host "`n[7/8] Restoring Default Windows Wallpaper..." -ForegroundColor Cyan
try {
    $defaultWallpapers = @(
        "C:\Windows\Web\4K\Wallpaper\Windows\img0_3840x2160.jpg",
        "C:\Windows\Web\Wallpaper\Windows\img0.jpg",
        "C:\Windows\Web\Wallpaper\Windows\img19.jpg",
        "$env:WINDIR\Web\Wallpaper\Windows\img0.jpg"
    )
    $restoredWall = $null
    foreach ($w in $defaultWallpapers) {
        if (Test-Path $w) {
            $restoredWall = $w
            break
        }
    }

    if ($restoredWall) {
        $transcoded = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"
        Copy-Item -Path $restoredWall -Destination $transcoded -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $restoredWall -Destination "$env:APPDATA\Microsoft\Windows\Themes\Transcoded_000" -Force -ErrorAction SilentlyContinue
        if (Test-Path "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaperCache") {
            Get-ChildItem -Path "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaperCache" -Filter "TranscodedWallpaper_*" -File -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not $_.Name.EndsWith(".meta")) {
                    Copy-Item -Path $restoredWall -Destination $_.FullName -Force -ErrorAction SilentlyContinue
                }
            }
        }

        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'Wallpaper' -Value $restoredWall -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'WallpaperStyle' -Value '10' -Force -ErrorAction SilentlyContinue
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32RestoreWall {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
}
"@ -ErrorAction SilentlyContinue
        [Win32RestoreWall]::SystemParametersInfo(0x0014, 0, $restoredWall, 3) | Out-Null
        rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
        Write-Host "  [OK] Default Windows 11 wallpaper restored!" -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] Skipped wallpaper restoration." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 8: Clean AppData Directory & Rebuild Windows Icon Cache
# -------------------------------------------------------------------------
Write-Host "`n[8/8] Rebuilding Windows Icon Cache & Refreshing Explorer & Start Menu..." -ForegroundColor Cyan

# 1. Stop Explorer and Start Menu hosts first to unlock all database handles
Write-Host "  [*] Stopping Windows Explorer & Start Menu to release cached icon files..." -ForegroundColor Yellow
taskkill.exe /f /im explorer.exe 2>$null
taskkill.exe /f /im StartMenuExperienceHost.exe 2>$null
taskkill.exe /f /im SearchHost.exe 2>$null
Start-Sleep -Milliseconds 800

# 2. Clean AppData and ProgramData directories
$appDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
if (Test-Path $appDir) {
    Remove-Item -Path $appDir -Recurse -Force -ErrorAction SilentlyContinue
}
$progDir = "C:\ProgramData\RohitBhaiMacOS"
if (Test-Path $progDir) {
    Remove-Item -Path $progDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Purge unlocked iconcache and thumbcache databases completely
$iconCache = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }

$expCache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $expCache) {
    Get-ChildItem -Path $expCache -Filter "*iconcache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $expCache -Filter "*thumbcache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

# 4. Clean Start Menu temporary caches
$startHostPkg = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\TempState"
if (Test-Path $startHostPkg) {
    Get-ChildItem -Path $startHostPkg -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 5. Flush legacy ie4uinit if present
try {
    $ie4 = Join-Path ([Environment]::GetFolderPath('System')) "ie4uinit.exe"
    if (Test-Path $ie4) { & $ie4 -show 2>$null }
} catch {}

# 6. Restart Windows Explorer live with fresh rebuild
Write-Host "  [*] Restarting Windows Explorer to rebuild fresh icon cache and restore Desktop..." -ForegroundColor Yellow
Start-Process "explorer.exe"
Start-Sleep -Seconds 1

# 7. Notify Windows Shell of association and icon changes with SHCNF_FLUSH
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32IconRefresh {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@ -ErrorAction SilentlyContinue
[Win32IconRefresh]::SHChangeNotify(0x08000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "     CONGRATULATIONS! ROHIT BHAI 1 CLICK MAC OS HAS BEEN COMPLETELY UNINSTALLED!        " -ForegroundColor Green
Write-Host "              All icons, Edge, Explorer, wallpaper, and labels restored!                " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
try {
    Write-Host "Press any key to close..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Start-Sleep -Seconds 3
}
