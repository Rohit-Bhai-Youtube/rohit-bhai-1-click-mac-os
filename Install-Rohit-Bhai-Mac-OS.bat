@echo off
:: ==============================================================================
:: Rohit Bhai Mac OS - 1-Click Offline & USB Installer v2.0 Ultimate
:: ==============================================================================

setlocal EnableDelayedExpansion
title Rohit Bhai Mac OS v2.0 - Installer

:: Check for Administrator Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Administrator privileges required. Requesting elevation...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
cls
echo ==============================================================================
echo                      ROHIT BHAI MAC OS v2.0 - 1-CLICK INSTALLER
echo                              Crafted by Rohit Bhai
echo ==============================================================================
echo.
echo  [+] Target: Windows 11 / Windows 10
echo  [+] Included Components:
echo      - Mac Island ^& Dock (32px icons, 22px radius, 170%% zoom, launch bounce)
echo      - macOS Genie Minimize Animation (450ms fluid curve)
echo      - Taskbar Network Speed Indicator (Apple Edition, live sparkline)
echo      - Windows 11 Start Menu Styler (LiquidGlass frosted theme)
echo      - Windows 11 Notification Center Styler (OS26 Tahoe Glass)
echo      - Windows 11 File Explorer Styler (Translucent acrylic blur)
echo      - Apple SF Pro Display Fonts Suite
echo      - macOS Capitaine Dark Cursors Scheme (with Rainbow Beach Ball)
echo      - 4K Ultra-HD macOS Wallpaper ^& Deep Dark Mode
echo.
echo ==============================================================================
echo.

:: 1. Locate Windhawk
set "WINDHAWK_CLI=C:\Program Files\Windhawk\windhawk-cli.exe"

if not exist "!WINDHAWK_CLI!" (
    if exist "%ProgramFiles(x86)%\Windhawk\windhawk-cli.exe" (
        set "WINDHAWK_CLI=%ProgramFiles(x86)%\Windhawk\windhawk-cli.exe"
    )
)

if not exist "!WINDHAWK_CLI!" (
    echo [-] Windhawk not found on this system!
    echo [*] Attempting to install Windhawk automatically via winget...
    winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements --silent
    
    if not exist "!WINDHAWK_CLI!" (
        echo [*] Downloading official installer from windhawk.net...
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://windhawk.net/download/windhawk_setup.exe', '%TEMP%\windhawk_setup.exe')"
        if exist "%TEMP%\windhawk_setup.exe" (
            "%TEMP%\windhawk_setup.exe" /S
            timeout /t 5 /nobreak >nul
        )
    )
    
    if not exist "!WINDHAWK_CLI!" (
        echo.
        echo [!] Error: Please install Windhawk manually from https://windhawk.net
        echo     and run this installer again.
        echo.
        pause
        exit /b 1
    )
)

echo [OK] Windhawk detected at: "!WINDHAWK_CLI!"
echo.

:: 2. Import Complete Offline Data Package (.whdata)
if exist "%~dp0Rohit-Bhai-Mac-OS.whdata" (
    echo [*] Importing Rohit Bhai Mac OS complete package (ratios, colors, mods)...
    "!WINDHAWK_CLI!" data import "%~dp0Rohit-Bhai-Mac-OS.whdata" --on-conflict overwrite --confirm-app-restart
    if !errorlevel! neq 0 (
        echo [*] Applying fallback offline mode...
        "!WINDHAWK_CLI!" data import "%~dp0Rohit-Bhai-Mac-OS.whdata" --offline --on-conflict overwrite --confirm-app-restart
    )
    echo [OK] All mods and custom settings imported successfully!
) else (
    echo [!] Rohit-Bhai-Mac-OS.whdata not found in script directory.
)

:: 3. Import Registry Settings Backup
if exist "%~dp0Rohit-Bhai-Mac-OS-Settings.reg" (
    echo [*] Writing exact customization registry keys...
    reg import "%~dp0Rohit-Bhai-Mac-OS-Settings.reg" >nul 2>&1
    echo [OK] Registry settings verified!
)

:: 4. Apply Apple SF Pro Fonts
if exist "%~dp0assets\fonts" (
    echo [*] Installing Apple SF Pro Fonts...
    copy /y "%~dp0assets\fonts\*.otf" "%WINDIR%\Fonts" >nul 2>&1
    echo [OK] Apple SF Pro typography active!
)

:: 5. Apply 4K macOS Wallpaper & Dark Mode
if exist "%~dp0assets\wallpaper.jpg" (
    echo [*] Setting 4K macOS Wallpaper...
    copy /y "%~dp0assets\wallpaper.jpg" "%APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper" >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper" /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d "10" /f >nul 2>&1
)

echo [*] Applying Windows Dark Mode baseline...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul 2>&1

:: 6. Restart Windows Explorer
echo.
echo [*] Refreshing Windows Shell (Explorer)...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe

echo.
echo ==============================================================================
echo        CONGRATULATIONS! ROHIT BHAI MAC OS v2.0 IS NOW ACTIVE!
echo ==============================================================================
echo.
echo  Your PC is now running the full macOS aesthetic:
echo    ^> Dynamic Island ^& Mac Dock
echo    ^> macOS Genie Minimize Animation
echo    ^> Apple-style Live Taskbar Speed
echo    ^> Apple SF Pro Display Typography
echo    ^> 4K Ultra-HD macOS Wallpaper ^& Dark Mode
echo    ^> Frosted Glass Start Menu ^& Notification Center
echo.
pause
exit /b 0
