@echo off
chcp 65001 >nul
title Rohit Bhai Mac OS v4.0 - Installer
color 0b

:: ==============================================================================
:: Rohit Bhai Mac OS v4.0 Ultimate - 1-Click Installer
:: Crafted by Rohit Bhai
:: ==============================================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Requesting Administrator Privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo [*] Launching Rohit Bhai Mac OS v4.0 Installation...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm 'https://raw.githubusercontent.com/romflasher3419-spec/rohit-bhai-mac-os/main/install.ps1' | iex"
)
