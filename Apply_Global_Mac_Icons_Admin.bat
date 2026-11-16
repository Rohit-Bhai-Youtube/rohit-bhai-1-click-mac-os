@echo off
:: Rohit Bhai Mac OS - Global Mac Icons & Navigation Pane Admin Patch
title Rohit Bhai Mac OS - Global Mac Icons Installer
echo ========================================================
echo   Applying Global macOS Icons for File Explorer & This PC
echo ========================================================

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Administrator permission required to change Windows system folder icons.
    echo [!] Please right-click this file and select "Run as administrator"!
    pause
    exit /b
)

set ICONS=C:\Users\rohit\AppData\Local\RohitBhaiMacOS\Icons

:: 1. Global Shell Icons (HKLM 64-bit and 32-bit)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "3" /t REG_SZ /d "%ICONS%\macOS_Folder.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "4" /t REG_SZ /d "%ICONS%\macOS_Folder_Open.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "8" /t REG_SZ /d "%ICONS%\macOS_Drive.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "9" /t REG_SZ /d "%ICONS%\macOS_Drive_System.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "31" /t REG_SZ /d "%ICONS%\macOS_Trash_Empty.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "32" /t REG_SZ /d "%ICONS%\macOS_Trash_Full.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "34" /t REG_SZ /d "%ICONS%\macOS_Desktop.ico" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "109" /t REG_SZ /d "%ICONS%\macOS_ThisPC.ico" /f

reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "3" /t REG_SZ /d "%ICONS%\macOS_Folder.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "4" /t REG_SZ /d "%ICONS%\macOS_Folder_Open.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "8" /t REG_SZ /d "%ICONS%\macOS_Drive.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "9" /t REG_SZ /d "%ICONS%\macOS_Drive_System.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "31" /t REG_SZ /d "%ICONS%\macOS_Trash_Empty.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "32" /t REG_SZ /d "%ICONS%\macOS_Trash_Full.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "34" /t REG_SZ /d "%ICONS%\macOS_Desktop.ico" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "109" /t REG_SZ /d "%ICONS%\macOS_ThisPC.ico" /f

:: 2. Navigation Pane CLSIDs
reg add "HKLM\SOFTWARE\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\DefaultIcon" /ve /t REG_SZ /d "%ICONS%\macOS_ThisPC.ico" /f
reg add "HKLM\SOFTWARE\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\DefaultIcon" /ve /t REG_SZ /d "%ICONS%\macOS_Folder.ico" /f
reg add "HKLM\SOFTWARE\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon" /ve /t REG_SZ /d "%ICONS%\macOS_Trash_Empty.ico" /f
reg add "HKLM\SOFTWARE\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon" /v "empty" /t REG_SZ /d "%ICONS%\macOS_Trash_Empty.ico" /f
reg add "HKLM\SOFTWARE\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon" /v "full" /t REG_SZ /d "%ICONS%\macOS_Trash_Full.ico" /f

:: 3. Clear Icon Caches and restart explorer
taskkill /F /IM explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
del /f /q "%LOCALAPPDATA%\IconCache.db" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache*.db" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache*.db" >nul 2>&1
start explorer.exe

echo.
echo ========================================================
echo [OK] All global yellow folders and This PC have been updated to macOS Aqua Blue!
echo ========================================================
pause
