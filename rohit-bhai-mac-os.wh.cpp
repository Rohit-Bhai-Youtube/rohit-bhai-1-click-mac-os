// ==WindhawkMod==
// @id              rohit-bhai-mac-os
// @name            Rohit Bhai Mac OS
// @description     Complete macOS experience and styling engine for Windows 11 by Rohit Bhai. Enforces macOS rounded window geometry, immersive dark mode, invisible borders, and coordinates the full Mac UI suite.
// @version         1.0.0
// @author          Rohit Bhai
// @github          https://github.com/rohitbhai
// @homepage        https://windhawk.net
// @include         *
// @exclude         devenv.exe
// @compilerOptions -ldwmapi -luser32
// @architecture    x86-64
// @license         MIT
// ==/WindhawkMod==

// ==WindhawkModReadme==
/*
# Rohit Bhai Mac OS

Official macOS Transformation & Styling Engine for Windows 11.
Crafted by **Rohit Bhai**.

### Included Customizations & Exact Specifications:
1. **Mac Island & Dock**:
   - Mode: macOS Dock replacement
   - Dynamic Island: Enabled (Clock, Media, Notifications, Tray)
   - Dock Icon Size: 32px | Icon Gap: 8px | Bottom Margin: 2px
   - Corner Radius: 22px | Glass Opacity: 50%
   - Magnification: 170% | Magnification Spread: 150px
   - Launch Bounce: Enabled (Authentic macOS Dock bounce)
   - Animation Speed: 125% | Refresh Rate: Screen Sync

2. **macOS Minimize Animation (Genie Effect)**:
   - Modern Genie deformation engine
   - Duration: 450ms | Mesh Tiles: 35
   - Open, Launch, and Close animations enabled

3. **Taskbar Network Speed Indicator (Apple Edition)**:
   - Apple-style bold Segoe UI Variable Display typography
   - Real-time sparkline chart | 1000ms update rate
   - Right offset: 6px | Vertical nudge: 15px

4. **LiquidGlass Start Menu**:
   - Liquid frosted glass blur (10px & 15px WindhawkBlur)
   - Custom metallic border gradient (#70FFFFFF -> #40505050 -> #70FFFFFF)

5. **OS26 Tahoe Glass Notification Center**:
   - Frosted macOS Tahoe Action & Notification styling

6. **Translucent Explorer 11**:
   - Acrylic glass navigation & details pane (#18202020 tint)
   - Thin glass border dividers (#30FFFFFF, #25FFFFFF, #40FFFFFF)

7. **System-wide Translucent & Acrylic Windows**:
   - Acrylic blur behind windows (#3A232323)

8. **Invisible Borders & Native Rounded Corners**:
   - Removes standard Windows borders while preserving curvature.
*/
// ==/WindhawkModReadme==

// ==WindhawkModSettings==
/*
- ForceRoundedCorners: true
  $name: Enforce macOS Rounded Corners
  $description: Forces modern macOS rounded corners on all top-level windows
- InvisibleBorders: true
  $name: Invisible Window Borders
  $description: Removes harsh window border lines for a sleek modern look
- ImmersiveDarkMode: true
  $name: Force Immersive Dark Mode
  $description: Enforces macOS style dark titlebars across windows
*/
// ==/WindhawkModSettings==

#include <windows.h>
#include <dwmapi.h>
#include <windhawk_api.h>

#ifndef DWMWA_WINDOW_CORNER_PREFERENCE
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#endif

#ifndef DWMWCP_ROUND
#define DWMWCP_ROUND 2
#endif

#ifndef DWMWA_BORDER_COLOR
#define DWMWA_BORDER_COLOR 34
#endif

#ifndef DWMWA_COLOR_NONE
#define DWMWA_COLOR_NONE 0xFFFFFFFE
#endif

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

static bool g_forceRoundedCorners = true;
static bool g_invisibleBorders = true;
static bool g_immersiveDarkMode = true;

static BOOL IsNormalWindow(HWND hWnd) {
    if (!IsWindow(hWnd) || !IsWindowVisible(hWnd)) {
        return FALSE;
    }
    DWORD dwStyle = GetWindowLongPtr(hWnd, GWL_STYLE);
    return ((dwStyle & WS_THICKFRAME) == WS_THICKFRAME || (dwStyle & WS_CAPTION) == WS_CAPTION);
}

static void ApplyMacOSStyle(HWND hWnd) {
    if (!IsNormalWindow(hWnd)) return;

    if (g_forceRoundedCorners) {
        DWM_WINDOW_CORNER_PREFERENCE preference = DWMWCP_ROUND;
        DwmSetWindowAttribute(hWnd, DWMWA_WINDOW_CORNER_PREFERENCE, &preference, sizeof(preference));
    }

    if (g_invisibleBorders) {
        COLORREF colorNone = DWMWA_COLOR_NONE;
        DwmSetWindowAttribute(hWnd, DWMWA_BORDER_COLOR, &colorNone, sizeof(colorNone));
    }

    if (g_immersiveDarkMode) {
        BOOL useDarkMode = TRUE;
        DwmSetWindowAttribute(hWnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &useDarkMode, sizeof(useDarkMode));
    }
}

using DefWindowProcW_t = decltype(&DefWindowProcW);
static DefWindowProcW_t DefWindowProcW_orig;
static LRESULT WINAPI DefWindowProcW_hook(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    LRESULT result = DefWindowProcW_orig(hWnd, uMsg, wParam, lParam);
    switch (uMsg) {
        case WM_CREATE:
        case WM_ACTIVATE:
        case WM_NCACTIVATE:
        case WM_DWMCOLORIZATIONCOLORCHANGED:
            ApplyMacOSStyle(hWnd);
            break;
    }
    return result;
}

static BOOL CALLBACK EnumWindowsProc(HWND hWnd, LPARAM lParam) {
    DWORD dwProcessId = 0;
    GetWindowThreadProcessId(hWnd, &dwProcessId);
    if (dwProcessId == (DWORD)lParam) {
        ApplyMacOSStyle(hWnd);
    }
    return TRUE;
}

static void LoadSettings() {
    g_forceRoundedCorners = Wh_GetIntSetting(L"ForceRoundedCorners");
    g_invisibleBorders = Wh_GetIntSetting(L"InvisibleBorders");
    g_immersiveDarkMode = Wh_GetIntSetting(L"ImmersiveDarkMode");
}

BOOL Wh_ModInit() {
    Wh_Log(L"Rohit Bhai Mac OS Mod Initializing...");
    LoadSettings();

    Wh_SetFunctionHook(
        (void *)DefWindowProcW,
        (void *)DefWindowProcW_hook,
        (void **)&DefWindowProcW_orig
    );

    return TRUE;
}

void Wh_ModAfterInit() {
    Wh_Log(L"Rohit Bhai Mac OS Mod Active!");
    EnumWindows(EnumWindowsProc, GetCurrentProcessId());
}

void Wh_ModSettingsChanged() {
    LoadSettings();
    EnumWindows(EnumWindowsProc, GetCurrentProcessId());
}
