Add-Type @'
using System;
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

    public static void Run() {
        STARTUPINFO si = new STARTUPINFO();
        si.cb = Marshal.SizeOf(si);
        si.lpDesktop = @"WinSta0\Default";

        PROCESS_INFORMATION pi = new PROCESS_INFORMATION();
        string cmd = "\"C:\\Program Files\\Windhawk\\windhawk-mod.exe\" -tool-mod mac-island-dock";

        bool ok = CreateProcess(null, cmd, IntPtr.Zero, IntPtr.Zero, false, 0, IntPtr.Zero, null, ref si, out pi);
        if (!ok) {
            Console.WriteLine("CreateProcess failed: " + Marshal.GetLastWin32Error());
            return;
        }

        Console.WriteLine("IslandDaemon: Spawned PID " + pi.dwProcessId + " on WinSta0\\Default");
        WaitForSingleObject(pi.hProcess, 0xFFFFFFFF); // INFINITE
        Console.WriteLine("IslandDaemon: Process ended");
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    }
}
'@

[IslandDaemon]::Run()
