@echo off
:: ==============================================================================
:: Rohit Bhai Mac OS - Backup & Export Script
:: Re-exports current mods and settings into Rohit-Bhai-Mac-OS.whdata
:: ==============================================================================

setlocal EnableDelayedExpansion
title Rohit Bhai Mac OS - Export & Backup

cd /d "%~dp0"
cls
echo ==============================================================================
echo                      ROHIT BHAI MAC OS - EXPORT TOOL
echo ==============================================================================
echo.

set "WINDHAWK_CLI=C:\Program Files\Windhawk\windhawk-cli.exe"
if not exist "!WINDHAWK_CLI!" (
    if exist "%ProgramFiles(x86)%\Windhawk\windhawk-cli.exe" (
        set "WINDHAWK_CLI=%ProgramFiles(x86)%\Windhawk\windhawk-cli.exe"
    )
)

if not exist "!WINDHAWK_CLI!" (
    echo [-] Windhawk not found! Cannot export.
    pause
    exit /b 1
)

echo [*] Exporting complete Windhawk offline data archive (.whdata)...
"!WINDHAWK_CLI!" data export --out "%~dp0Rohit-Bhai-Mac-OS.whdata" --offline --force
if %errorlevel% equ 0 (
    echo [OK] Exported: Rohit-Bhai-Mac-OS.whdata
) else (
    echo [!] Export failed with error %errorlevel%
)

echo [*] Exporting registry settings...
reg export "HKLM\SOFTWARE\Windhawk\Engine\Mods" "%~dp0Rohit-Bhai-Mac-OS-Settings.reg" /y >nul 2>&1
echo [OK] Exported: Rohit-Bhai-Mac-OS-Settings.reg

echo.
echo ==============================================================================
echo                      BACKUP COMPLETED SUCCESSFULLY!
echo ==============================================================================
echo.
pause
