using nSoft.Globals;
using nSoft.Helpers;
using System;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Windows.Threading;

namespace nSoft.ViewModels
{
    public class MainViewModel : ViewModelBase
    {
        #region Variables
        private DispatcherTimer ForegroundCheckTimer;

        private string _TxtServerName;
        public string TxtServerName
        {
            get => _TxtServerName;
            set
            {
                _TxtServerName = value;
                RaisePropertyChanged(() => TxtServerName);
            }
        }

        private string _TxtMachineID;
        public string TxtMachineID
        {
            get => _TxtMachineID;
            set
            {
                _TxtMachineID = value;
                RaisePropertyChanged(() => TxtMachineID);
            }
        }

        private string _TxtStatus;
        public string TxtStatus
        {
            get => _TxtStatus;
            set
            {
                _TxtStatus = value;
                RaisePropertyChanged(() => TxtStatus);
            }
        }

        private string _TxtLog;
        public string TxtLog
        {
            get => _TxtLog;
            set
            {
                _TxtLog = value;
                RaisePropertyChanged(() => TxtLog);
            }
        }

        private bool _IsNotConnectedDatabase;
        public bool IsNotConnectedDatabase
        {
            get => _IsNotConnectedDatabase;
            set
            {
                _IsNotConnectedDatabase = value;
                RaisePropertyChanged(() => IsNotConnectedDatabase);
            }
        }

        private bool _IsNotConnectingDB;
        public bool IsNotConnectingDB
        {
            get => _IsNotConnectingDB;
            set
            {
                _IsNotConnectingDB = value;
                RaisePropertyChanged(() => IsNotConnectingDB);
            }
        }

        private bool _IsConnectingDB;
        public bool IsConnectingDB
        {
            get => _IsConnectingDB;
            set
            {
                _IsConnectingDB = value;
                RaisePropertyChanged(() => IsConnectingDB);
            }
        }

        private bool _IsStoppedService;
        public bool IsStoppedService
        {
            get => _IsStoppedService;
            set
            {
                _IsStoppedService = value;
                RaisePropertyChanged(() => IsStoppedService);
            }
        }

        private bool _IsRunningService;
        public bool IsRunningService
        {
            get => _IsRunningService;
            set
            {
                _IsRunningService = value;
                RaisePropertyChanged(() => IsRunningService);
            }
        }
        #endregion

        #region Commands
        public ICommand ConnectDatabaseCommand { get { return new DelegateCommand<object>(OnConnectBtnClick); } }
        public ICommand StartServiceCommand { get { return new DelegateCommand<object>(OnStartBtnClick); } }
        public ICommand StopServiceCommand { get { return new DelegateCommand<object>(OnStopBtnClick); } }
        #endregion

        #region Methods
        public MainViewModel()
        {
            Global.MainViewModel = this;

            InitValues();
            //Global.ShowMessage("MainViewModel called!");
            ForegroundCheckTimer = new DispatcherTimer(DispatcherPriority.Normal);
            //ForegroundCheckTimer.Interval = new TimeSpan(Global.IntervalTicks);
            ForegroundCheckTimer.Interval = new TimeSpan(TimeSpan.TicksPerSecond * 3);
            ForegroundCheckTimer.Tick += new EventHandler(ForegroundCheckTimer_Tick);
            ForegroundCheckTimer.Start();

            SetAutoStartup();
        }

        private void InitValues()
        {
            DBConnection.__DBConnected = false;
            IsNotConnectedDatabase = true;
            IsConnectingDB = false;
            IsNotConnectingDB = true;

            Global.GetConfigInformation();
        }

        public async void SetInitStatus()
        {
            TxtMachineID = Global.__MACHINE_ID;

            if (Global.__SERVICE_RUNNING_STATUS)
            {
                IsRunningService = true;
                IsStoppedService = false;

                ShowStatus(Properties.Resources.RUNNING);
                AddToLogs("Service started!");
            }
            else
            {
                IsRunningService = false;
                IsStoppedService = true;

                ShowStatus(Properties.Resources.STOPPED);
                AddToLogs("Service stopped!");
            }

            if (Global.__DB_SERVER_NAME != string.Empty)
            {
                TxtServerName = Global.__DB_SERVER_NAME;
                bool connectedDB = false;

                IsConnectingDB = true;
                IsNotConnectingDB = false;

                using (var task = Task.Run(() => DBConnection.TryingToConnect()))
                    connectedDB = await task;

                if (connectedDB)
                {
                    Global.__SERVICE_RUNNING_STATUS = true;
                    IsNotConnectedDatabase = false;

                    IsConnectingDB = false;
                    IsNotConnectingDB = true;

                    DBConnection.CreateNewProcedures();
                }
                else
                {
                    Global.__SERVICE_RUNNING_STATUS = false;
                    Global.ShowMessage("Database Connection Failed!");

                    IsConnectingDB = false;
                    IsNotConnectingDB = true;
                }

                Global.SaveSettings();
            }
        }

        private void ForegroundCheckTimer_Tick(object sender, EventArgs e)
        {
            Global.CheckAndSetForeground();

            if (DBConnection.__DBConnected && Global.__SERVICE_RUNNING_STATUS)
            {
                Communication.GetRequestedData();
            }
        }
        
        void SetAutoStartup()
        {
            try
            {
                string commonStartupPath = Global.GetUserStartupPath();

                string sourceShortcutAddress = System.IO.Directory.GetCurrentDirectory() + @"\nSoft.exe.lnk";
                if (System.IO.File.Exists(sourceShortcutAddress))
                {
                    string shortcutAddress = commonStartupPath + @"\nSoft.exe.lnk";
                    System.IO.File.Copy(sourceShortcutAddress, shortcutAddress, true);
                }
            }
            catch (Exception ex)
            {

            }
        }
        #endregion

        #region Procedure
        private async void OnConnectBtnClick(object obj)
        {
            if (TxtServerName == null || TxtServerName == string.Empty)
            {
                Global.ShowMessage("Please input SQL Server Name");
            }
            else
            {
                bool connectedDB = false;
                Global.__DB_SERVER_NAME = TxtServerName;

                IsConnectingDB = true;
                IsNotConnectingDB = false;

                using (var task = Task.Run(() => DBConnection.TryingToConnect()))
                    connectedDB = await task;

                if (connectedDB)
                {
                    Global.SaveSettings();
                    IsNotConnectedDatabase = false;

                    IsConnectingDB = false;
                    IsNotConnectingDB = true;
                }
                else
                {
                    Global.ShowMessage("Database connection failed!");

                    IsConnectingDB = false;
                    IsNotConnectingDB = true;
                }
            }
        }

        private void OnStartBtnClick(object obj)
        {
            if (DBConnection.__DBConnected)
            {
                IsRunningService = true;
                IsStoppedService = false;

                Communication.CleanDataLog();

                Global.__SERVICE_RUNNING_STATUS = true;
                Global.SaveSettings();

                ShowStatus(Properties.Resources.RUNNING);
                AddToLogs("Service started!");
            }
            else
            {
                Global.ShowMessage("Please connect database!");
                ShowStatus(Properties.Resources.DATABASE_NOT_CONNECTED);
            }
        }

        private void OnStopBtnClick(object obj)
        {
            IsRunningService = false;
            IsStoppedService = true;

            Global.__SERVICE_RUNNING_STATUS = false;
            Global.SaveSettings();

            ShowStatus(Properties.Resources.STOPPED);
            AddToLogs("Service stopped!");
        }



        public void ShowStatus(string status)
        {
            TxtStatus = status;
        }

        public void AddToLogs(string content)
        {
            TxtLog += DateTime.Now.ToString() + " " + content + System.Environment.NewLine;
        }
        #endregion
    }
}
