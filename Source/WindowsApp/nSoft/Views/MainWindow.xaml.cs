using nSoft.Globals;
using System;
using System.IO;
using System.Windows;
using System.Windows.Threading;

namespace nSoft
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            //FileManager.CreateExcelFile(Directory.GetCurrentDirectory() + "\\Report.xlsx", "");
            //MailAPI.SendReportMail("xinfengbao_world@163.com", Directory.GetCurrentDirectory() + "\\Report.xlsx");
            //FileManager.DeleteFile(Directory.GetCurrentDirectory() + "\\Report.xlsx");

            InitializeComponent();
            //Global.ShowMessage("MainWindow called!");
            //ForegroundCheckTimer = new DispatcherTimer(DispatcherPriority.Normal);
            //ForegroundCheckTimer.Interval = new TimeSpan(TimeSpan.TicksPerSecond * 3);
            //ForegroundCheckTimer.Tick += new EventHandler(ForegroundCheckTimer_Tick);
            //ForegroundCheckTimer.Start();
            //ForegroundCheckTimer.Stop();
        }

        private DispatcherTimer ForegroundCheckTimer;
        private void ForegroundCheckTimer_Tick(object sender, EventArgs e)
        {
            Global.CheckAndSetForeground();

            if (DBConnection.__DBConnected && Global.__SERVICE_RUNNING_STATUS)
            {
                Communication.GetRequestedData();
            }
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            Hide();

            e.Cancel = true;
        }
    }
}
