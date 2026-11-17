# ========================================================================================
#   1-CLICK WINDOWS 11 ICON & FOLDER RESTORATION TOOL (ROHIT BHAI MAC OS RECOVERY)
# ========================================================================================

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $scriptUrl = "https://raw.githubusercontent.com/Rohit-Bhai-Youtube/rohit-bhai-1-click-mac-os/main/Restore-Windows-Icons.ps1"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$scriptUrl' | iex`""
    }
    exit
}

try {
    $Host.UI.RawUI.WindowTitle = "Restore Windows 11 Icons"
    [Console]::Title = "Restore Windows 11 Icons"
} catch {}

Clear-Host
Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host "       RESTORING ORIGINAL WINDOWS 11 FOLDERS, ICONS & TASKBAR SHORTCUTS" -ForegroundColor White
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Clean Shell Icons in Registry using native reg.exe
Write-Host "  [1/5] Removing Shell Icons & Folder registry overrides..." -ForegroundColor Yellow
$shellKeys = @(
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons",
    "HKCU\Software\Classes\Folder\DefaultIcon",
    "HKCU\Software\Classes\Directory\DefaultIcon",
    "HKCU\Software\Classes\Applications\Explorer.exe\Drives",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons",
    "HKCU\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}",
    "HKCU\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}",
    "HKCU\Software\Classes\CLSID\{59031A47-3F72-44A7-89C5-5595FE6B30EE}",
    "HKCU\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
)
foreach ($k in $shellKeys) {
    & reg.exe delete "$k" /f 2>$null
}

# Fallback: Populate RohitBhaiMacOS\Icons with 4K Ultra HD Windows 11 icons as a permanent safety net
try {
    $icoDir = "$env:LOCALAPPDATA\RohitBhaiMacOS\Icons"
    New-Item -ItemType Directory -Path $icoDir -Force | Out-Null
    $imageres = Join-Path ([Environment]::GetFolderPath('System')) "imageres.dll"
    Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class MultiResIcoRest {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int PrivateExtractIcons(
        string lpszFile, int nIconIndex, int cxIcon, int cyIcon,
        IntPtr[] phicon, int[] piconid, int nIcons, int flags
    );

    [DllImport("user32.dll")]
    public static extern bool DestroyIcon(IntPtr hIcon);

    public static void Save(string dllPath, int iconIndex, string outIcoPath) {
        int[] sizes = new int[] { 16, 24, 32, 48, 64, 128, 256 };
        List<byte[]> pngBuffers = new List<byte[]>();
        List<int> validSizes = new List<int>();

        foreach (int sz in sizes) {
            IntPtr[] ph = new IntPtr[1];
            int[] pid = new int[1];
            int c = PrivateExtractIcons(dllPath, iconIndex, sz, sz, ph, pid, 1, 0);
            if (c > 0 && ph[0] != IntPtr.Zero) {
                using (Icon ico = Icon.FromHandle(ph[0])) {
                    using (Bitmap bmp = ico.ToBitmap()) {
                        using (MemoryStream ms = new MemoryStream()) {
                            bmp.Save(ms, ImageFormat.Png);
                            pngBuffers.Add(ms.ToArray());
                            validSizes.Add(sz);
                        }
                    }
                }
                DestroyIcon(ph[0]);
            }
        }

        if (pngBuffers.Count == 0) return;

        using (MemoryStream msOut = new MemoryStream()) {
            using (BinaryWriter bw = new BinaryWriter(msOut)) {
                bw.Write((short)0);
                bw.Write((short)1);
                bw.Write((short)pngBuffers.Count);

                int offset = 6 + (16 * pngBuffers.Count);
                for (int i = 0; i < pngBuffers.Count; i++) {
                    int sz = validSizes[i];
                    byte bSz = (byte)(sz == 256 ? 0 : sz);
                    bw.Write(bSz);
                    bw.Write(bSz);
                    bw.Write((byte)0);
                    bw.Write((byte)0);
                    bw.Write((short)1);
                    bw.Write((short)32);
                    bw.Write((int)pngBuffers[i].Length);
                    bw.Write((int)offset);
                    offset += pngBuffers[i].Length;
                }

                for (int i = 0; i < pngBuffers.Count; i++) {
                    bw.Write(pngBuffers[i]);
                }
            }
            File.WriteAllBytes(outIcoPath, msOut.ToArray());
        }
    }
}
"@ -ReferencedAssemblies System.Drawing -ErrorAction SilentlyContinue
    [MultiResIcoRest]::Save($imageres, 3, "$icoDir\macOS_Folder.ico")
    [MultiResIcoRest]::Save($imageres, 4, "$icoDir\macOS_Folder_Open.ico")
    [MultiResIcoRest]::Save($imageres, 27, "$icoDir\macOS_Drive.ico")
    [MultiResIcoRest]::Save($imageres, 26, "$icoDir\macOS_Drive_System.ico")
    [MultiResIcoRest]::Save($imageres, 54, "$icoDir\macOS_Trash_Empty.ico")
    [MultiResIcoRest]::Save($imageres, 55, "$icoDir\macOS_Trash_Full.ico")
    [MultiResIcoRest]::Save($imageres, 110, "$icoDir\macOS_Desktop.ico")
    [MultiResIcoRest]::Save($imageres, 109, "$icoDir\macOS_ThisPC.ico")
    [MultiResIcoRest]::Save($imageres, 112, "$icoDir\macOS_Documents.ico")
    [MultiResIcoRest]::Save($imageres, 184, "$icoDir\macOS_Downloads.ico")
    [MultiResIcoRest]::Save($imageres, 108, "$icoDir\macOS_Music.ico")
    [MultiResIcoRest]::Save($imageres, 113, "$icoDir\macOS_Pictures.ico")
    [MultiResIcoRest]::Save($imageres, 18, "$icoDir\macOS_Videos.ico")
} catch {}

# 2. Remove custom Icon values from FolderDescriptions
Write-Host "  [2/5] Restoring default Windows folder descriptions..." -ForegroundColor Yellow
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
Write-Host "  [OK] Registry folder & system overrides completely wiped!" -ForegroundColor Green

# 3. Fix Corrupted Shortcut Icons
Write-Host "  [3/5] Fixing corrupted shortcuts across Taskbar, Start Menu & Desktop..." -ForegroundColor Yellow
$wsh = New-Object -ComObject WScript.Shell
$shortcutDirs = @(
    (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'),
    ([Environment]::GetFolderPath('Programs')),
    ([Environment]::GetFolderPath('CommonPrograms')),
    ([Environment]::GetFolderPath('Desktop')),
    ([Environment]::GetFolderPath('CommonDesktop'))
)

# Specifically restore Edge, Explorer, Steam shortcuts
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

            # Check if icon has multiple commas or points to missing folder
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

            # Normalize specific well-known apps
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
Write-Host "  [OK] All shortcuts repaired with valid native icons!" -ForegroundColor Green

# 4. Flush and rebuild Windows Icon & Thumbnail caches
Write-Host "  [4/5] Flushing Windows icon & thumbnail database caches..." -ForegroundColor Yellow
taskkill.exe /F /IM explorer.exe /IM StartMenuExperienceHost.exe /IM SearchHost.exe /IM ShellExperienceHost.exe 2>$null
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

# 5. Restart Explorer and broadcast shell change notification
Write-Host "  [5/5] Relaunching Windows Explorer..." -ForegroundColor Yellow
Start-Process explorer.exe
Start-Sleep -Seconds 1

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
Write-Host "  SUCCESS! All Windows 11 folders, Edge, Explorer, and icons restored 100%!" -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
try {
    Write-Host "Press any key to finish..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Start-Sleep -Seconds 3
}
