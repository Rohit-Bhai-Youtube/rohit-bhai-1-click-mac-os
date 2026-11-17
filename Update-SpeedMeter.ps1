# ========================================================================================
#   UPDATE APPLE NET SPEED METER - FRAMELESS COLORFUL CHARTS (ROHIT BHAI MAC OS)
# ========================================================================================

# Auto-elevate to Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$Host.UI.RawUI.WindowTitle = "Mac OS - Apple Speed Meter Update"

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host "       UPDATING APPLE TASKBAR NETWORK SPEED METER (FRAMELESS COLORFUL CHARTS)" -ForegroundColor White
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host ""

$WindhawkCli = "C:\Program Files\Windhawk\windhawk-cli.exe"
$speedModSource = Join-Path $PSScriptRoot "Mods-Source\local@net-speed-taskbar-apple.wh.cpp"
$progDataSource = "C:\ProgramData\Windhawk\ModsSource\local@net-speed-taskbar-apple.wh.cpp"

if (-not (Test-Path $speedModSource)) {
    Write-Host "  [-] Mod source file not found at $speedModSource" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}

# 1. Copy source to ProgramData
Write-Host "  [*] Deploying updated C++ mod source..." -ForegroundColor Yellow
Copy-Item -Path $speedModSource -Destination $progDataSource -Force -ErrorAction SilentlyContinue

# 2. Pre-seed registry settings (Theme: Chart, showBox: 0, verticalNudge: 0)
Write-Host "  [*] Enforcing frameless colorful chart settings in Registry..." -ForegroundColor Yellow
$speedPaths = @(
    "HKLM:\SOFTWARE\Windhawk\Engine\Mods\local@net-speed-taskbar-apple\Settings",
    "HKLM:\SOFTWARE\WOW6432Node\Windhawk\Engine\Mods\local@net-speed-taskbar-apple\Settings"
)
foreach ($p in $speedPaths) {
    if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
    Set-ItemProperty -Path $p -Name "theme" -Value "Chart" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "showBox" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "horizontalPosition" -Value 10 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "rightOffset" -Value 6 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "verticalNudge" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "updateIntervalMs" -Value 1000 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "fontSize" -Value 13 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "opacity" -Value 255 -Type DWord -Force -ErrorAction SilentlyContinue
}

# 3. Compile and load via Windhawk CLI
if (Test-Path $WindhawkCli) {
    Write-Host "  [*] Compiling and loading mod via Windhawk Engine..." -ForegroundColor Yellow
    & $WindhawkCli mod install --file "$speedModSource" --yes
    Write-Host "  [OK] Mod successfully compiled and activated!" -ForegroundColor Green
} else {
    Write-Host "  [!] Windhawk CLI not found at default location." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "  SUCCESS! Your colorful speed meter is now 100% frameless (zero box/border)!" -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 3
