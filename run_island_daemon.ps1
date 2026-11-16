Add-Type @'
using System;
using System.IO;
using System.Text;
using System.Threading;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class IslandDaemon {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct STARTUPINFO {
        public int cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public int dwX;
        public int dwY;
        public int dwXSize;
        public int dwYSize;
        public int dwXCountChars;
        public int dwYCountChars;
        public int dwFillAttribute;
        public int dwFlags;
        public short wShowWindow;
        public short cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess;
        public IntPtr hThread;
        public int dwProcessId;
        public int dwThreadId;
    }

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CreateProcess(
        string lpApplicationName,
        string lpCommandLine,
        IntPtr lpProcessAttributes,
        IntPtr lpThreadAttributes,
        bool bInheritHandles,
        uint dwCreationFlags,
        IntPtr lpEnvironment,
        string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation);

    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);

    [DllImport("kernel32.dll")]
    public static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);

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

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint PrivateExtractIcons(
        string szFileName,
        int nIconIndex,
        int cxIcon,
        int cyIcon,
        out IntPtr phicon,
        out uint piconid,
        uint nIcons,
        uint flags);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    private const uint WM_SETICON = 0x0080;
    private static IntPtr ICON_SMALL = new IntPtr(0);
    private static IntPtr ICON_BIG = new IntPtr(1);

    private static Dictionary<string, IntPtr> iconCache = new Dictionary<string, IntPtr>(StringComparer.OrdinalIgnoreCase);
    private static HashSet<IntPtr> patchedWindows = new HashSet<IntPtr>();

    private static IntPtr GetCachedIcon(string path, int size) {
        if (!File.Exists(path)) return IntPtr.Zero;
        string key = path + "_" + size;
        if (iconCache.ContainsKey(key)) return iconCache[key];
        IntPtr hicon;
        uint id;
        uint count = PrivateExtractIcons(path, 0, size, size, out hicon, out id, 1, 0);
        if (count == 1 && hicon != IntPtr.Zero) {
            iconCache[key] = hicon;
            return hicon;
        }
        return IntPtr.Zero;
    }

    public static void CleanArtifactsAndInjectIcons(string iconsDir) {
        IntPtr hDesk = OpenDesktop("Default", 0, false, 0x01FF);
        if (hDesk == IntPtr.Zero) return;
        SetThreadDesktop(hDesk);

        IntPtr safariSm = GetCachedIcon(Path.Combine(iconsDir, "Safari.ico"), 32);
        IntPtr safariBg = GetCachedIcon(Path.Combine(iconsDir, "Safari.ico"), 256);
        IntPtr waSm = GetCachedIcon(Path.Combine(iconsDir, "WhatsApp.ico"), 32);
        IntPtr waBg = GetCachedIcon(Path.Combine(iconsDir, "WhatsApp.ico"), 256);
        IntPtr tgSm = GetCachedIcon(Path.Combine(iconsDir, "Telegram.ico"), 32);
        IntPtr tgBg = GetCachedIcon(Path.Combine(iconsDir, "Telegram.ico"), 256);
        IntPtr discordSm = GetCachedIcon(Path.Combine(iconsDir, "Discord.ico"), 32);
        IntPtr discordBg = GetCachedIcon(Path.Combine(iconsDir, "Discord.ico"), 256);
        IntPtr finderSm = GetCachedIcon(Path.Combine(iconsDir, "Finder.ico"), 32);
        IntPtr finderBg = GetCachedIcon(Path.Combine(iconsDir, "Finder.ico"), 256);
        IntPtr termSm = GetCachedIcon(Path.Combine(iconsDir, "Terminal.ico"), 32);
        IntPtr termBg = GetCachedIcon(Path.Combine(iconsDir, "Terminal.ico"), 256);
        IntPtr notesSm = GetCachedIcon(Path.Combine(iconsDir, "Notes.ico"), 32);
        IntPtr notesBg = GetCachedIcon(Path.Combine(iconsDir, "Notes.ico"), 256);

        bool anyInjected = false;
        IntPtr islandWnd = IntPtr.Zero;

        EnumDesktopWindows(hDesk, (hWnd, lParam) => {
            if (!IsWindowVisible(hWnd)) return true;
            var sbCls = new StringBuilder(256);
            GetClassName(hWnd, sbCls, 256);
            string cls = sbCls.ToString();

            // 1. Hide bottom white dummy bar
            if (cls == "Chrome_WidgetWin_0") {
                RECT r;
                GetWindowRect(hWnd, out r);
                if (r.Top >= 900 && (r.Right - r.Left) == 160 && (r.Bottom - r.Top) == 28) {
                    ShowWindow(hWnd, 0); // SW_HIDE
                    MoveWindow(hWnd, -32000, -32000, 0, 0, false);
                }
            }
            else if (cls == "WindhawkMacIslandDockIsland") {
                islandWnd = hWnd;
            }

            // 2. Dynamic live window icon injection
            if (!patchedWindows.Contains(hWnd)) {
                var sbTitle = new StringBuilder(256);
                GetWindowText(hWnd, sbTitle, 256);
                string title = sbTitle.ToString();

                // Edge -> Safari
                if (cls == "Chrome_WidgetWin_1" && (title.Contains("Edge") || title.Contains("YouTube") || title.Contains("Personal") || title.Contains("Work"))) {
                    if (safariSm != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_SMALL, safariSm);
                    if (safariBg != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_BIG, safariBg);
                    patchedWindows.Add(hWnd);
                    anyInjected = true;
                }
                // WhatsApp
                else if (cls.Contains("WhatsApp") || title.Contains("WhatsApp") || (cls == "WinUIDesktopWin32WindowClass" && title.Contains("call"))) {
                    if (waSm != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_SMALL, waSm);
                    if (waBg != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_BIG, waBg);
                    patchedWindows.Add(hWnd);
                    anyInjected = true;
                }
                // Telegram
                else if (cls.Contains("Telegram") || title.Contains("Telegram")) {
                    if (tgSm != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_SMALL, tgSm);
                    if (tgBg != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_BIG, tgBg);
                    patchedWindows.Add(hWnd);
                    anyInjected = true;
                }
                // Discord
                else if (title.Contains("Discord")) {
                    if (discordSm != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_SMALL, discordSm);
                    if (discordBg != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_BIG, discordBg);
                    patchedWindows.Add(hWnd);
                    anyInjected = true;
                }
                // Explorer -> Finder
                else if (cls == "CabinetWClass") {
                    if (finderSm != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_SMALL, finderSm);
                    if (finderBg != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_BIG, finderBg);
                    patchedWindows.Add(hWnd);
                    anyInjected = true;
                }
                // Notepad -> Notes
                else if (cls == "Notepad") {
                    if (notesSm != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_SMALL, notesSm);
                    if (notesBg != IntPtr.Zero) SendMessage(hWnd, WM_SETICON, ICON_BIG, notesBg);
                    patchedWindows.Add(hWnd);
                    anyInjected = true;
                }
            }
            return true;
        }, IntPtr.Zero);

        if (anyInjected && islandWnd != IntPtr.Zero) {
            SendMessage(islandWnd, 0x8064, IntPtr.Zero, IntPtr.Zero); // WM_APP_ICONS
        }

        CloseDesktop(hDesk);
    }

    public static void Run() {
        string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        string iconsDir = Path.Combine(localAppData, "RohitBhaiMacOS", "Icons", "Apps");

        Console.WriteLine("IslandDaemon: Active background monitor running.");
        while (true) {
            try { CleanArtifactsAndInjectIcons(iconsDir); } catch {}
            Thread.Sleep(3000);
        }
    }
}
'@

[IslandDaemon]::Run()
