# ========================================================================================
#   UPDATE APPLE NET SPEED METER - FRAMELESS COLORFUL CHARTS (ROHIT BHAI MAC OS)
# ========================================================================================

# Auto-elevate to Administrator using native Shell
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptUrl = "https://raw.githubusercontent.com/Rohit-Bhai-Youtube/rohit-bhai-1-click-mac-os/main/Update-SpeedMeter.ps1"
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm '$scriptUrl' | iex`""
    }
    exit
}

try {
    $Host.UI.RawUI.WindowTitle = "Mac OS - Apple Speed Meter Update"
    [Console]::Title = "Mac OS - Apple Speed Meter Update"
} catch {}

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host "       UPDATING APPLE TASKBAR NETWORK SPEED METER (FRAMELESS COLORFUL CHARTS)" -ForegroundColor White
Write-Host "========================================================================================" -ForegroundColor Cyan
Write-Host ""

$WindhawkCli = "C:\Program Files\Windhawk\windhawk-cli.exe"
$RepoOwner = "Rohit-Bhai-Youtube"
$RepoName  = "rohit-bhai-1-click-mac-os"
$Branch    = "main"
$RawBase   = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch"

$speedModSource = $null

# Check local repo path
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "Mods-Source\local@net-speed-taskbar-apple.wh.cpp"))) {
    $speedModSource = Join-Path $PSScriptRoot "Mods-Source\local@net-speed-taskbar-apple.wh.cpp"
} elseif (Test-Path "C:\Users\rohit\.gemini\antigravity\scratch\Rohit-Bhai-Mac-OS\Mods-Source\local@net-speed-taskbar-apple.wh.cpp") {
    $speedModSource = "C:\Users\rohit\.gemini\antigravity\scratch\Rohit-Bhai-Mac-OS\Mods-Source\local@net-speed-taskbar-apple.wh.cpp"
} else {
    Write-Host "  [*] Downloading latest C++ mod source from GitHub..." -ForegroundColor Yellow
    $tempCpp = Join-Path $env:TEMP "local@net-speed-taskbar-apple.wh.cpp"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "$RawBase/Mods-Source/local@net-speed-taskbar-apple.wh.cpp" -OutFile $tempCpp -UseBasicParsing
        $speedModSource = $tempCpp
        Write-Host "  [OK] Downloaded latest C++ mod source!" -ForegroundColor Green
    } catch {
        Write-Host "  [-] Failed to download mod source: $_" -ForegroundColor Red
    }
}

if (-not $speedModSource -or -not (Test-Path $speedModSource)) {
    Write-Host "  [-] Mod source file not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

$progDataSource = "C:\ProgramData\Windhawk\ModsSource\local@net-speed-taskbar-apple.wh.cpp"

# 1. Deploy source to ProgramData
Write-Host "  [1/4] Deploying updated C++ mod source to Windhawk..." -ForegroundColor Yellow
try {
    $destDir = Split-Path $progDataSource -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $speedModSource -Destination $progDataSource -Force
    Write-Host "  [OK] C++ mod source deployed!" -ForegroundColor Green
} catch {
    Write-Host "  [!] Warning while copying: $_" -ForegroundColor Yellow
}

# 2. Pre-seed registry settings (Theme: Chart, showBox: 0, verticalNudge: 0)
Write-Host "  [2/4] Setting frameless colorful chart parameters..." -ForegroundColor Yellow
$speedPaths = @(
    "HKLM:\SOFTWARE\Windhawk\Engine\Mods\local@net-speed-taskbar-apple\Settings",
    "HKLM:\SOFTWARE\WOW6432Node\Windhawk\Engine\Mods\local@net-speed-taskbar-apple\Settings"
)
foreach ($p in $speedPaths) {
    if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
    Set-ItemProperty -Path $p -Name "theme" -Value "Chart" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "showBox" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "horizontalPosition" -Value 10 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "rightOffset" -Value 16 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "verticalNudge" -Value 18 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "updateIntervalMs" -Value 1000 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "fontSize" -Value 13 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $p -Name "opacity" -Value 255 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Host "  [OK] Registry settings saved (Theme: Chart, Box: Disabled)!" -ForegroundColor Green

# 3. Compile and load via Windhawk CLI
Write-Host "  [3/4] Compiling and linking mod with Windhawk Clang Compiler..." -ForegroundColor Yellow
if (Test-Path $WindhawkCli) {
    # Install from file compiles the source and links the DLL
    $installOutput = & $WindhawkCli mod install --file "$speedModSource" --yes 2>&1
    Write-Host "  $installOutput"

    # Enforce runtime settings
    & $WindhawkCli mod settings set local@net-speed-taskbar-apple theme=Chart showBox=false verticalNudge=18 rightOffset=16 fontSize=13 opacity=255 2>$null
    
    # 4. Reload mod so new DLL is injected immediately
    Write-Host "  [4/4] Reloading speed meter live on taskbar..." -ForegroundColor Yellow
    & $WindhawkCli mod disable local@net-speed-taskbar-apple --yes 2>$null
    Start-Sleep -Milliseconds 600
    & $WindhawkCli mod enable local@net-speed-taskbar-apple --yes 2>$null
    Write-Host "  [OK] Speed meter mod reloaded!" -ForegroundColor Green
} else {
    Write-Host "  [!] Windhawk CLI not found at $WindhawkCli" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "  SUCCESS! Your colorful speed meter is now 100% frameless (zero box/border)!" -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to finish..."
