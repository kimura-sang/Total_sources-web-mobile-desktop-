using Microsoft.Win32;
using nSoft.ViewModels;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace nSoft
{
    public static class Global
    {
        public const string APP_NAME = "nSoft";

        public static long IntervalTicks = 50000000;

        [System.Runtime.InteropServices.DllImport("User32.dll")]
        private static extern bool SetForegroundWindow(IntPtr handle);


        internal static void CheckAndSetForeground()
        {
            RegistryKey reg = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion", true);
            if (reg.GetValue("Show") != null && (int)reg.GetValue("Show") == 1)
            {
                reg.SetValue("Show", 0);

                Global.ShowMainWindow();
            }
        }

        internal static void ShowMainWindow()
        {
            //Application.Current.MainWindow = new MainWindow();
            Application.Current.MainWindow.Show();

            SetForeground();
        }

        internal static void SetForeground()
        {
            Process[] processRunning = Process.GetProcesses();
            foreach (Process pr in processRunning)
            {
                //Console.WriteLine(pr.ProcessName);
                if (pr.ProcessName.CompareTo(Global.APP_NAME) == 0)
                {
                    SetForegroundWindow(pr.MainWindowHandle);
                }
            }
        }
        public static NotifyIconViewModel NotifyIconViewModel { get; internal set; }

        //internal static void CheckRunning()
        //{
        //    StringBuilder allUserProfile = new StringBuilder(260);
        //    SHGetSpecialFolderPath(IntPtr.Zero, allUserProfile, CSIDL_STARTUP, false);
        //    string commonStartupPath = allUserProfile.ToString();
        //    //The above API call returns: C:\Users\GIGABYTE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
        //    Console.WriteLine(commonStartupPath);

        //    string sourceShortcutAddress = System.IO.Directory.GetCurrentDirectory() + @"\0routes.lnk";
        //    if (System.IO.File.Exists(sourceShortcutAddress))
        //    {
        //        string shortcutAddress = commonStartupPath + @"\0routes.lnk";
        //        if (Properties.Settings.Default.AutoRun)
        //        {
        //            System.IO.File.Copy(sourceShortcutAddress, shortcutAddress);
        //        }
        //        else
        //        {
        //            if (System.IO.File.Exists(shortcutAddress))
        //            {
        //                System.IO.File.Delete(shortcutAddress);
        //            }
        //        }
        //    }
        //}
    }
}
