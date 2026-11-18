Add-Type @'
using System;
using System.IO;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Microsoft.Win32;

public class IslandDaemon {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr OpenDesktop(string lpszDesktop, int dwFlags, bool fInherit, uint dwDesiredAccess);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetThreadDesktop(IntPtr hDesktop);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool CloseDesktop(IntPtr hDesktop);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")]
    public static extern bool EnumDesktopWindows(IntPtr hDesktop, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    public static void CleanArtifacts() {
        IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
        if (hDesk == IntPtr.Zero) return;
        SetThreadDesktop(hDesk);

        EnumDesktopWindows(hDesk, (hWnd, lParam) => {
            if (!IsWindowVisible(hWnd)) return true;
            var sbCls = new StringBuilder(256);
            GetClassName(hWnd, sbCls, 256);
            string cls = sbCls.ToString();

            // Hide bottom white dummy bar if present
            if (cls == "Chrome_WidgetWin_0") {
                RECT r;
                GetWindowRect(hWnd, out r);
                if (r.Top >= 900 && (r.Right - r.Left) == 160 && (r.Bottom - r.Top) == 28) {
                    ShowWindow(hWnd, 0); // SW_HIDE
                    MoveWindow(hWnd, -32000, -32000, 0, 0, false);
                }
            }
            return true;
        }, IntPtr.Zero);

        CloseDesktop(hDesk);
    }

    public static void EnforceTopRightBar() {
        try {
            string[] subKeys = new string[] {
                @"Software\Windhawk\Engine\ModsWritable\mac-island-dock\LocalStorage",
                @"Software\WOW6432Node\Windhawk\Engine\ModsWritable\mac-island-dock\LocalStorage"
            };
            string targetOrder = @"de12635;<8?0479:=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcfghijklm";

            foreach (string sk in subKeys) {
                using (RegistryKey key = Registry.LocalMachine.CreateSubKey(sk)) {
                    if (key != null) {
                        object barVal = key.GetValue("islandBar");
                        object alignVal = key.GetValue("islandBarAlign");
                        object pillVal = key.GetValue("islandZoneAsPill");
                        object placeXVal = key.GetValue("placeX");
                        object orderVal = key.GetValue("islandOrder");

                        if (barVal == null || Convert.ToInt32(barVal) != 1 ||
                            alignVal == null || Convert.ToInt32(alignVal) != 3 ||
                            pillVal == null || Convert.ToInt32(pillVal) != 0 ||
                            placeXVal == null || Convert.ToInt32(placeXVal) != 1000 ||
                            orderVal == null || orderVal.ToString() != targetOrder) {

                            key.SetValue("islandBar", 1, RegistryValueKind.DWord);
                            key.SetValue("islandBarSide", 0, RegistryValueKind.DWord);
                            key.SetValue("islandBarAlign", 3, RegistryValueKind.DWord);
                            key.SetValue("placeX", 1000, RegistryValueKind.DWord);
                            key.SetValue("placeY", 0, RegistryValueKind.DWord);
                            key.SetValue("islandOrder", targetOrder, RegistryValueKind.String);
                            key.SetValue("islandClock", 1, RegistryValueKind.DWord);
                            key.SetValue("clockWeekday", 1, RegistryValueKind.DWord);
                            key.SetValue("clockSeconds", 0, RegistryValueKind.DWord);
                            key.SetValue("clockYear", 0, RegistryValueKind.DWord);
                            key.SetValue("islandTheme", 4, RegistryValueKind.DWord);
                            key.SetValue("islandLiquidGlass", 1, RegistryValueKind.DWord);
                            key.SetValue("islandGlassBlur", 70, RegistryValueKind.DWord);
                            key.SetValue("islandGlassLight", 1, RegistryValueKind.DWord);
                            key.SetValue("islandIconSize", 85, RegistryValueKind.DWord);
                            key.SetValue("islandTextSize", 100, RegistryValueKind.DWord);
                            key.SetValue("islandPanelSize", 100, RegistryValueKind.DWord);
                            key.SetValue("islandPanelsFollow", 1, RegistryValueKind.DWord);
                            key.SetValue("islandIconPack", 1, RegistryValueKind.DWord);
                            key.SetValue("islandVolume", 1, RegistryValueKind.DWord);
                            key.SetValue("islandNetwork", 1, RegistryValueKind.DWord);
                            key.SetValue("islandPower", 1, RegistryValueKind.DWord);
                            key.SetValue("islandUsbDrives", 1, RegistryValueKind.DWord);
                            key.SetValue("islandUsbNotify", 1, RegistryValueKind.DWord);
                            key.SetValue("islandNoticeCharger", 1, RegistryValueKind.DWord);
                            key.SetValue("islandNoticeLowBattery", 1, RegistryValueKind.DWord);
                            key.SetValue("islandBell", 1, RegistryValueKind.DWord);
                            key.SetValue("islandStatusNotices", 1, RegistryValueKind.DWord);
                            key.SetValue("islandCapsLock", 1, RegistryValueKind.DWord);
                            key.SetValue("islandOverFullscreen", 1, RegistryValueKind.DWord);
                            key.SetValue("islandReserve", 1, RegistryValueKind.DWord);
                            key.SetValue("islandNotches", 0, RegistryValueKind.DWord);
                            key.SetValue("islandPillNotches", 0, RegistryValueKind.DWord);
                            key.SetValue("islandZoneAsPill", 0, RegistryValueKind.DWord);
                            key.SetValue("islandBarCorners", 0, RegistryValueKind.DWord);
                            key.SetValue("islandBarFixedSides", 0, RegistryValueKind.DWord);
                            key.SetValue("islandGap", 0, RegistryValueKind.DWord);
                            key.SetValue("islandVerticalSides", 1, RegistryValueKind.DWord);
                            key.SetValue("islandAutoHide", 0, RegistryValueKind.DWord);
                            key.SetValue("islandHideWhen", 0, RegistryValueKind.DWord);
                            key.SetValue("islandHideClock", 0, RegistryValueKind.DWord);
                            key.SetValue("trayListIsland", 12, RegistryValueKind.DWord);
                            key.SetValue("animationsIsland", 4002, RegistryValueKind.DWord);
                            key.SetValue("islandDownloadFill", 1, RegistryValueKind.DWord);
                            key.SetValue("islandOpacity", 80, RegistryValueKind.DWord);
                            key.SetValue("islandNotchCurve", 80, RegistryValueKind.DWord);
                            key.SetValue("islandPillHeight", 100, RegistryValueKind.DWord);
                            key.SetValue("islandSize", 100, RegistryValueKind.DWord);
                            key.SetValue("islandWeather", 0, RegistryValueKind.DWord);
                            key.SetValue("islandWeatherCards", 0, RegistryValueKind.DWord);
                            key.SetValue("islandApps", 0, RegistryValueKind.DWord);
                            key.SetValue("islandNetSpeed", 0, RegistryValueKind.DWord);
                            key.SetValue("islandVisualizer", 0, RegistryValueKind.DWord);
                        }
                    }
                }
            }

            // Ensure mac-island-dock Settings key enforces floating dock mode (taskbarMode = dock) and showIsland = 1
            string[] modSettingKeys = new string[] {
                @"Software\Windhawk\Engine\Mods\mac-island-dock\Settings",
                @"Software\WOW6432Node\Windhawk\Engine\Mods\mac-island-dock\Settings"
            };
            foreach (string msk in modSettingKeys) {
                using (RegistryKey mkey = Registry.LocalMachine.CreateSubKey(msk)) {
                    if (mkey != null) {
                        object tmVal = mkey.GetValue("taskbarMode");
                        object siVal = mkey.GetValue("showIsland");
                        if (tmVal == null || tmVal.ToString() != "dock") {
                            mkey.SetValue("taskbarMode", "dock", RegistryValueKind.String);
                        }
                        if (siVal == null || Convert.ToInt32(siVal) != 1) {
                            mkey.SetValue("showIsland", 1, RegistryValueKind.DWord);
                        }
                    }
                }
            }
        } catch {}
    }

    public static void Run() {
        bool createdNew;
        using (var mutex = new System.Threading.Mutex(true, "RohitBhai_MacIsland_Daemon_Mutex", out createdNew)) {
            if (!createdNew) {
                return; // Another instance is already running
            }
            Console.WriteLine("IslandDaemon: Active background monitor running (Top-Right Mac Island enforced).");
            while (true) {
                try {
                    EnforceTopRightBar();
                    CleanArtifacts();
                } catch {}
                Thread.Sleep(3000);
            }
        }
    }
}
'@

try {
    $pidDir = "$env:LOCALAPPDATA\RohitBhaiMacOS"
    if (-not (Test-Path $pidDir)) { New-Item -ItemType Directory -Path $pidDir -Force | Out-Null }
    [System.IO.File]::WriteAllText((Join-Path $pidDir "daemon.pid"), "$PID")
} catch {}

[IslandDaemon]::Run()
