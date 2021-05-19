using Hardcodet.Wpf.TaskbarNotification;
using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using nSoft.Globals;
using System.IO;

namespace nSoft
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private TaskbarIcon notifyIcon;
        static Mutex m;

        [STAThread]
        protected override void OnStartup(StartupEventArgs e)
        {
            //Global.CONFIG_FILE_NAME = Directory.GetCurrentDirectory() + "\\" + Global.FILE_NAME;
            Global.CreateShortcut();
            
            bool first = false;
            m = new Mutex(true, Global.APP_NAME, out first);
            if (!first)
            {
                RegistryKey reg = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion", true);
                reg.SetValue("Show", 1);

                App.Current.Shutdown();
            }

            base.OnStartup(e);
            
            //create the notifyicon (it's a resource declared in NotifyIconResources.xaml
            notifyIcon = (TaskbarIcon)FindResource("NotifyIcon");
        }

        protected override void OnExit(ExitEventArgs e)
        {
            notifyIcon.Dispose(); //the icon would clean up automatically, but this is cleaner
            base.OnExit(e);
        }
    }
}
