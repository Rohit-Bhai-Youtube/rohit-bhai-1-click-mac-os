# ==============================================================================
# Rohit Bhai Mac OS - Uninstaller
# Target: Windows 11 / Windows 10
# Reverts Windhawk mods, cursor schemes, sound schemes, and folder icons safely
# Crafted for Rohit Bhai
# ==============================================================================

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Clear-Host
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host "                ROHIT BHAI MAC OS - UNINSTALLER                     " -ForegroundColor Yellow
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host ""

# 1. Reset Sound Scheme to Windows Default
Write-Host "[*] Resetting sound scheme to Windows Default..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Value ".Default" -Force -ErrorAction SilentlyContinue
if (Test-Path "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS") {
    Remove-Item "HKCU:\AppEvents\Schemes\Names\RohitBhaiMacOS" -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. Reset Cursors to Windows Default
Write-Host "[*] Resetting cursors to Windows Default..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "" -Value "Windows Default" -Force -ErrorAction SilentlyContinue

# 3. Reset File Explorer & Folder Icons to Windows Default
Write-Host "[*] Resetting File Explorer & Folder Icons to Windows Default..." -ForegroundColor Cyan

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

# Flush icon cache
$iconCache = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCache) { Remove-Item $iconCache -Force -ErrorAction SilentlyContinue }
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "*cache*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
& ie4uinit.exe -show 2>$null

# 4. Disable and remove Windhawk mods
$WindhawkCli = "C:\Program Files\Windhawk\windhawk-cli.exe"
if (-not (Test-Path $WindhawkCli)) {
    $alt = "$env:ProgramFiles(x86)\Windhawk\windhawk-cli.exe"
    if (Test-Path $alt) { $WindhawkCli = $alt }
}

if (Test-Path $WindhawkCli) {
    $mods = @(
        "mac-island-dock",
        "macos-minimize-animation",
        "local@net-speed-taskbar-apple",
        "windows-11-start-menu-styler",
        "windows-11-notification-center-styler",
        "windows-11-file-explorer-styler",
        "translucent-windows",
        "invisible-borders",
        "rohit-bhai-mac-os"
    )

    foreach ($m in $mods) {
        Write-Host "[*] Removing mod: $m..." -ForegroundColor Cyan
        & $WindhawkCli mod disable $m --yes 2>$null
        & $WindhawkCli mod remove $m --yes 2>$null
    }
}

Write-Host "[*] Refreshing Windows Explorer..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe

Write-Host ""
Write-Host "[OK] Rohit Bhai Mac OS uninstalled cleanly. Windows defaults restored!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
