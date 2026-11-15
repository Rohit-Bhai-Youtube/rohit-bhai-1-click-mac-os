# ==============================================================================
# Rohit Bhai Mac OS - PowerShell Automated Installer for Windhawk
# ==============================================================================

# Self-elevate to Administrator if not already elevated
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[INFO] Elevating to Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "                    ROHIT BHAI MAC OS - 1-CLICK INSTALLER                     " -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$windhawkCli = "C:\Program Files\Windhawk\windhawk-cli.exe"
if (-not (Test-Path $windhawkCli)) {
    $alt = "$env:ProgramFiles(x86)\Windhawk\windhawk-cli.exe"
    if (Test-Path $alt) { $windhawkCli = $alt }
}

if (-not (Test-Path $windhawkCli)) {
    Write-Host "[-] Windhawk CLI not found. Attempting install via winget..." -ForegroundColor Yellow
    winget install RamenSoftware.Windhawk --accept-source-agreements --accept-package-agreements
    if (-not (Test-Path $windhawkCli)) {
        Write-Host "[!] Please install Windhawk from https://windhawk.net first." -ForegroundColor Red
        Pause
        exit 1
    }
}

Write-Host "[+] Windhawk located at: $windhawkCli" -ForegroundColor Green

# 1. Import complete offline data archive (.whdata)
$whdata = Join-Path $ScriptDir "Rohit-Bhai-Mac-OS.whdata"
if (Test-Path $whdata) {
    Write-Host "[*] Importing Rohit Bhai Mac OS offline data package..." -ForegroundColor Cyan
    & $windhawkCli data import $whdata --offline --on-conflict overwrite --confirm-app-restart
    Write-Host "[OK] Package imported successfully!" -ForegroundColor Green
}

# 2. Import registry settings
$regFile = Join-Path $ScriptDir "Rohit-Bhai-Mac-OS-Settings.reg"
if (Test-Path $regFile) {
    Write-Host "[*] Applying registry customizations (colors, ratios, margins)..." -ForegroundColor Cyan
    Start-Process reg -ArgumentList "import `"$regFile`"" -Wait -NoNewWindow
    Write-Host "[OK] Registry settings imported!" -ForegroundColor Green
}

# 3. Install core mod
$coreMod = Join-Path $ScriptDir "rohit-bhai-mac-os.wh.cpp"
if (Test-Path $coreMod) {
    Write-Host "[*] Compiling and activating 'Rohit Bhai Mac OS' core mod..." -ForegroundColor Cyan
    & $windhawkCli mod install --file $coreMod --yes
    Write-Host "[OK] Rohit Bhai Mac OS core mod active!" -ForegroundColor Green
}

# 4. Refresh Explorer
Write-Host "[*] Refreshing Windows Explorer..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process explorer.exe

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "       CONGRATULATIONS! ROHIT BHAI MAC OS CUSTOMIZATION IS ACTIVE!             " -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
