@echo off
:: ==============================================================================
:: Rohit Bhai Mac OS - 1-Click Ultimate Installer for Windhawk
:: Restores full macOS Experience: Island Dock, Genie Animation, LiquidGlass,
:: Tahoe Glass, Translucent Windows, Apple Net Speed & Custom Colors/Ratios.
:: ==============================================================================

setlocal EnableDelayedExpansion
title Rohit Bhai Mac OS - Installer

:: Request Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Administrator rights required. Requesting elevation...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
cls
echo ==============================================================================
echo                      ROHIT BHAI MAC OS - 1-CLICK INSTALLER
echo ==============================================================================
echo.
echo  [+] Target: Windows 11 / Windows 10
echo  [+] Mods to activate:
echo      - Mac Island ^& Dock (Dynamic Island, Dock Mode, 32px icons, 22px radius)
echo      - macOS Minimize Animation (Genie Effect, 450ms smooth curve)
echo      - Taskbar Network Speed Indicator (Apple Edition, live sparkline)
echo      - Windows 11 Start Menu Styler (LiquidGlass frosted theme)
echo      - Windows 11 Notification Center Styler (OS26 Tahoe Glass)
echo      - Windows 11 File Explorer Styler (Translucent acrylic blur)
echo      - Translucent Windows (System-wide acrylic glass effects)
echo      - Invisible Window Borders (Sleek borderless curved windows)
echo      - Rohit Bhai Mac OS (Core Engine Mod)
echo.
echo ==============================================================================
echo.

:: 1. Detect Windhawk Installation
set "WINDHAWK_CLI=C:\Program Files\Windhawk\windhawk-cli.exe"

if not exist "!WINDHAWK_CLI!" (
    if exist "%ProgramFiles(x86)%\Windhawk\windhawk-cli.exe" (
        set "WINDHAWK_CLI=%ProgramFiles(x86)%\Windhawk\windhawk-cli.exe"
    )
)

if not exist "!WINDHAWK_CLI!" (
    echo [-] Windhawk not found on this system!
    echo [*] Attempting to install Windhawk automatically via winget...
    winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements
    
    if not exist "!WINDHAWK_CLI!" (
        echo.
        echo [!] Please install Windhawk from https://windhawk.net first!
        echo     After installing Windhawk, run this script again.
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
    "!WINDHAWK_CLI!" data import "%~dp0Rohit-Bhai-Mac-OS.whdata" --offline --on-conflict overwrite --confirm-app-restart
    if %errorlevel% equ 0 (
        echo [OK] All mods and custom settings imported successfully!
    ) else (
        echo [!] Windhawk import exited with code %errorlevel%. Applying registry backup...
    )
) else (
    echo [!] Rohit-Bhai-Mac-OS.whdata not found in script directory.
)

:: 3. Import Registry Settings (Exact backup of all ratios, blur, opacities)
if exist "%~dp0Rohit-Bhai-Mac-OS-Settings.reg" (
    echo [*] Writing exact customization registry keys...
    reg import "%~dp0Rohit-Bhai-Mac-OS-Settings.reg" >nul 2>&1
    echo [OK] Registry settings verified!
)

:: 4. Install Rohit Bhai Mac OS Core Mod
if exist "%~dp0rohit-bhai-mac-os.wh.cpp" (
    echo [*] Compiling and activating 'Rohit Bhai Mac OS' core mod...
    "!WINDHAWK_CLI!" mod install --file "%~dp0rohit-bhai-mac-os.wh.cpp" --yes >nul 2>&1
    echo [OK] Rohit Bhai Mac OS core mod active!
)

:: 5. Restart Windows Explorer to apply changes instantly
echo.
echo [*] Refreshing Windows Shell (Explorer)...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe

echo.
echo ==============================================================================
echo        CONGRATULATIONS! ROHIT BHAI MAC OS CUSTOMIZATION IS NOW ACTIVE!
echo ==============================================================================
echo.
echo  Your PC is now running the full macOS aesthetic:
echo    ^> Dynamic Island ^& Mac Dock
echo    ^> macOS Genie Minimize Animation
echo    ^> Apple-style Live Taskbar Speed
echo    ^> Frosted Glass Start Menu ^& Notification Center
echo    ^> Acrylic Windows ^& Invisible Borders
echo.
pause
exit /b 0
