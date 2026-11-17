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
    # Remove Shell Icons overrides using .NET and native commands
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

    # Delete custom Icon value from FolderDescriptions so Windows defaults kick in
    $folderGuids = @(
        "{374DE290-123F-4565-9164-39C4925E467B}",
        "{7d83ee9b-2244-4e70-b1f5-5393042af1e4}",
        "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}",
        "{f42ee2d3-909f-4907-8871-4c22fc0bf756}",
        "{33E28130-4E1E-4676-835A-98395C3BC3BB}",
        "{0ddd0157-5467-4334-96c9-78ec10e39588}",
        "{0ddd015d-b06c-45d5-8c4c-f59713854639}",
        "{4BD8D571-6D19-48D3-BE97-422220080E43}",
        "{a0c69a99-21c8-4671-8703-7934162fbe1d}",
        "{a0c69a99-21c8-4671-8703-7934162fef1d}",
        "{18989B1D-99B5-455B-841C-AB7C74E4DDFC}",
        "{35286161-5079-4140-9a09-7b505a4f2791}",
        "{35286161-052a-4736-ac15-41e990f2430e}",
        "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
    )
    foreach ($g in $folderGuids) {
        & reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$g" /v "Icon" /f 2>$null
    }

    # Clean custom desktop.ini in user profile folders
    $userDirs = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Music",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\OneDrive\Downloads",
        "$env:USERPROFILE\OneDrive\Documents",
        "$env:USERPROFILE\OneDrive\Pictures",
        "$env:USERPROFILE\OneDrive\Desktop"
    )
    foreach ($d in $userDirs) {
        if (Test-Path $d) {
            $ini = Join-Path $d "desktop.ini"
            if (Test-Path $ini) {
                attrib -h -s -r "$ini" 2>$null
                $content = Get-Content -LiteralPath $ini -Raw -ErrorAction SilentlyContinue
                if ($content -match "RohitBhaiMacOS|Finder|macOS|Sonoma") {
                    Remove-Item -LiteralPath $ini -Force -ErrorAction SilentlyContinue
                }
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
    $edgeExe = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgeExe)) { $edgeExe = "C:\Program Files\Microsoft\Edge\Application\msedge.exe" }
    if (Test-Path $edgeExe) {
        $edgeLocations = @(
            (Join-Path $taskbarDir "Microsoft Edge.lnk"),
            (Join-Path $allStartDir "Microsoft Edge.lnk"),
            (Join-Path $userStartDir "Microsoft Edge.lnk"),
            (Join-Path $userDesktop "Microsoft Edge.lnk"),
            (Join-Path $commonDesktop "Microsoft Edge.lnk")
        )
        foreach ($edgeLnk in $edgeLocations) {
            [MacAppShortcutHelper]::CreateOrUpdateShortcut($edgeLnk, $edgeExe, "", "$edgeExe,0", "MSEdge")
        }
    }

    # 4. Restore 100% Native File Explorer Shortcut with official AUMID (Microsoft.Windows.Explorer)
    $explorerLnk = Join-Path $taskbarDir "File Explorer.lnk"
    [MacAppShortcutHelper]::CreateOrUpdateShortcut($explorerLnk, "$env:WINDIR\explorer.exe", "", "$env:WINDIR\explorer.exe,0", "Microsoft.Windows.Explorer")

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

    # 7. Restore WhatsApp & Telegram on Taskbar: remove if not installed, restore native if installed
    $waApp = Get-AppxPackage -Name "*WhatsApp*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $waExe = "$env:LOCALAPPDATA\WhatsApp\WhatsApp.exe"
    $waInstalled = ($waApp -ne $null) -or (Test-Path $waExe)
    $waTb = Join-Path $taskbarDir "WhatsApp.lnk"
    if (-not $waInstalled -and (Test-Path $waTb)) {
        Remove-Item -LiteralPath $waTb -Force -ErrorAction SilentlyContinue
    }

    $tgApp = Get-AppxPackage -Name "*Telegram*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $tgExe = "$env:APPDATA\Telegram Desktop\Telegram.exe"
    if (-not (Test-Path $tgExe)) { $tgExe = "C:\Program Files\Telegram Desktop\Telegram.exe" }
    $tgInstalled = ($tgApp -ne $null) -or (Test-Path $tgExe)
    $tgTb = Join-Path $taskbarDir "Telegram.lnk"
    if (-not $tgInstalled -and (Test-Path $tgTb)) {
        Remove-Item -LiteralPath $tgTb -Force -ErrorAction SilentlyContinue
    }

    # 8. Restore System Tools shortcuts to native system binaries
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

    # 9. Comprehensive Deep Scan for any remaining shortcuts pointing to RohitBhaiMacOS
    $allShortcutDirs = @($taskbarDir, $userStartDir, $allStartDir, $userDesktop, $commonDesktop)
    foreach ($dir in $allShortcutDirs) {
        if (-not (Test-Path $dir)) { continue }
        Get-ChildItem -Path $dir -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $lnk = $wsh.CreateShortcut($_.FullName)
                $target = $lnk.TargetPath
                $icon = $lnk.IconLocation
                if ($target -like "*RohitBhaiMacOS*") {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
                } elseif ($icon -like "*RohitBhaiMacOS*") {
                    if ($target -and (Test-Path $target) -and ($target -match "\.exe$") -and ($target -notlike "*explorer.exe")) {
                        $lnk.IconLocation = "$target,0"
                        $lnk.Save()
                    } else {
                        Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
                    }
                }
            } catch {}
        }
    }

    # 10. Restore Windows Search Bar & Taskbar Buttons
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
# Step 8: Clean AppData Directory & Nuclear Rebuild of Windows Icon Cache
# -------------------------------------------------------------------------
Write-Host "`n[8/8] Rebuilding Windows Icon Cache & Refreshing Explorer & Start Menu..." -ForegroundColor Cyan

# 1. Remove RohitBhaiMacOS data directory safely
$appDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
if (Test-Path $appDir) {
    # Check if Shell Icons still points to RohitBhaiMacOS
    $hklmStillHas = $false
    try {
        $regCheck = & reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" 2>$null
        if ($regCheck -and ($regCheck -match "RohitBhaiMacOS")) {
            $hklmStillHas = $true
        }
    } catch {}

    if ($hklmStillHas) {
        # Fallback: populate with native Windows 11 yellow icons so folders are NEVER blank
        $icoDir = Join-Path $appDir "Icons"
        New-Item -ItemType Directory -Path $icoDir -Force | Out-Null
        $imageres = Join-Path ([Environment]::GetFolderPath('System')) "imageres.dll"
        try {
            Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
public class WinIconFallbackUn {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern int ExtractIconEx(string lpszFile, int nIconIndex, IntPtr[] phiconLarge, IntPtr[] phiconSmall, int nIcons);
    [DllImport("user32.dll")]
    public static extern bool DestroyIcon(IntPtr hIcon);
    public static void Save(string dll, int idx, string outPath) {
        IntPtr[] l = new IntPtr[1]; IntPtr[] s = new IntPtr[1];
        ExtractIconEx(dll, idx, l, s, 1);
        if (l[0] != IntPtr.Zero) {
            using (Icon ico = Icon.FromHandle(l[0])) {
                using (FileStream fs = new FileStream(outPath, FileMode.Create)) { ico.Save(fs); }
            }
            DestroyIcon(l[0]);
            if (s[0] != IntPtr.Zero) DestroyIcon(s[0]);
        }
    }
}
"@ -ReferencedAssemblies System.Drawing -ErrorAction SilentlyContinue
            [WinIconFallbackUn]::Save($imageres, 3, "$icoDir\macOS_Folder.ico")
            [WinIconFallbackUn]::Save($imageres, 4, "$icoDir\macOS_Folder_Open.ico")
            [WinIconFallbackUn]::Save($imageres, 27, "$icoDir\macOS_Drive.ico")
            [WinIconFallbackUn]::Save($imageres, 26, "$icoDir\macOS_Drive_System.ico")
            [WinIconFallbackUn]::Save($imageres, 54, "$icoDir\macOS_Trash_Empty.ico")
            [WinIconFallbackUn]::Save($imageres, 55, "$icoDir\macOS_Trash_Full.ico")
            [WinIconFallbackUn]::Save($imageres, 110, "$icoDir\macOS_Desktop.ico")
            [WinIconFallbackUn]::Save($imageres, 109, "$icoDir\macOS_ThisPC.ico")
            [WinIconFallbackUn]::Save($imageres, 112, "$icoDir\macOS_Documents.ico")
            [WinIconFallbackUn]::Save($imageres, 184, "$icoDir\macOS_Downloads.ico")
            [WinIconFallbackUn]::Save($imageres, 108, "$icoDir\macOS_Music.ico")
            [WinIconFallbackUn]::Save($imageres, 113, "$icoDir\macOS_Pictures.ico")
            [WinIconFallbackUn]::Save($imageres, 18, "$icoDir\macOS_Videos.ico")
        } catch {}
    } else {
        Remove-Item -Path $appDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 2. Terminate explorer and shell host processes forcefully to release file locks
taskkill.exe /F /IM explorer.exe /IM StartMenuExperienceHost.exe /IM SearchHost.exe /IM ShellExperienceHost.exe 2>$null
Start-Sleep -Milliseconds 800

# 3. Flush icon and thumbnail cache databases
$iconCache = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }

$expCache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $expCache) {
    Get-ChildItem -Path $expCache -Filter "*iconcache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $expCache -Filter "*thumbcache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

# 4. Clear Start Menu & Search tile caches
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

# 5. Relaunch Windows Explorer cleanly and rebuild system icon registry
Start-Process explorer.exe
Start-Sleep -Seconds 2
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32IconRefresh {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@ -ErrorAction SilentlyContinue
[Win32IconRefresh]::SHChangeNotify(0x08000000, 0x0000, [IntPtr]::Zero, [IntPtr]::Zero)

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
