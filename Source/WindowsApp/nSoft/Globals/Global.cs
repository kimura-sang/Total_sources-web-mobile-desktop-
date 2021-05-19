using IWshRuntimeLibrary;
using Microsoft.Reporting.WinForms;
using Microsoft.Win32;
using nSoft.ViewModels;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Management;
using System.Net.Mail;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Windows;
using Excel = Microsoft.Office.Interop.Excel;

namespace nSoft.Globals
{
    public static class Global
    {
        #region Variables
        public static NotifyIconViewModel NotifyIconViewModel = new NotifyIconViewModel();
        public static MainViewModel MainViewModel;

        public const string APP_NAME = "nSofts";
        //public const string FILE_NAME = "nSoft_Config.ini";
        public static string DIRECTORY_PATH = "D:\\";
        public static string CONFIG_FILE_NAME = "nSofts_Config.ini";
        public static long IntervalTicks = 30000000;
        public static string EMPTY_STRING = "---";
        public static string STRING_SEPERATOR = "_";

        public static string TAG_SPLITER = ":";
        public static string TAG_MACHINE_ID = "MachineID";
        public static string __MACHINE_ID = "";
        public static string TAG_DATABASE_SERVER_NAME = "ServerName";
        public static string __DB_SERVER_NAME = "";
        public static string TAG_SERVICE_RUNNING = "ServiceRunning";
        public static bool __SERVICE_RUNNING_STATUS = true;

        public static string BASE_DIRECTORY_PATH = "D:\\";
        #endregion

        #region Methods
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

        public static void ShowMessage(string MessageContent)
        {
            MessageBox.Show(MessageContent, "nSoft");
            MainViewModel.AddToLogs(MessageContent);
        }

        public static void AddDatabaseLogToMainViewModel(string prefix, string requestBy)
        {
            MainViewModel.AddToLogs(prefix + " query is requested by " + requestBy);
        }

        public static void AddResponseLogToMainViewModel(string requestBy)
        {
            MainViewModel.AddToLogs("Query response successfully to " + requestBy);
        }

        public static void GetConfigInformation()
        {
            string localMachineID = GetUUIDCommand();
            if (IsConfigFileExist())
            {
                LoadSettings();
                if (__MACHINE_ID == string.Empty || __MACHINE_ID != localMachineID)
                {
                    __MACHINE_ID = localMachineID;
                    SaveSettings();
                }
            }
            else
            {
                __MACHINE_ID = localMachineID;
                SaveSettings();

                MainViewModel.SetInitStatus();
            }
        }

        internal static string GetUUIDCommand()
        {
            string uuid = string.Empty;

            ManagementClass mc = new ManagementClass("Win32_ComputerSystemProduct");
            ManagementObjectCollection moc1 = mc.GetInstances();

            foreach (ManagementObject mo in moc1)
            {
                uuid = mo.Properties["UUID"].Value.ToString();
                break;
            }

            return uuid;
        }

        internal static bool IsConfigFileExist()
        {
            return System.IO.File.Exists(DIRECTORY_PATH + "\\" + CONFIG_FILE_NAME);
        }

        internal static void LoadSettings()
        {
            if (IsConfigFileExist())
            {
                try
                {
                    // Open the text file using a stream reader.
                    using (StreamReader sr = new StreamReader(DIRECTORY_PATH + "\\" + CONFIG_FILE_NAME))
                    {
                        // Read the stream to a string, and write the string to the console.
                        //string line = sr.ReadToEnd();

                        string currentLine;
                        while ((currentLine = sr.ReadLine()) != null)
                        {
                            string[] strArray = currentLine.Split(TAG_SPLITER.ToCharArray());
                            if (strArray.Length > 1)
                            {
                                if (strArray[0] == TAG_MACHINE_ID)
                                {
                                    __MACHINE_ID = strArray[1];
                                }
                                if (strArray[0] == TAG_DATABASE_SERVER_NAME)
                                {
                                    __DB_SERVER_NAME = strArray[1];
                                }
                                if (strArray[0] == TAG_SERVICE_RUNNING)
                                {
                                    __SERVICE_RUNNING_STATUS = bool.Parse(strArray[1]);
                                }
                            }
                        }
                    }

                    MainViewModel.SetInitStatus();
                }
                catch (IOException e)
                {
                    Console.WriteLine("The file could not be read:");
                    Console.WriteLine(e.Message);
                }
            }
        }

        internal static void SaveSettings()
        {
            if (GetUserStartupPath() != Directory.GetCurrentDirectory())
            {
                try
                {
                    if (IsConfigFileExist())
                    {
                        System.IO.File.Delete(DIRECTORY_PATH + "\\" + CONFIG_FILE_NAME);
                    }

                    // Create a string array with the lines of text
                    string[] lines = {
                        TAG_MACHINE_ID + TAG_SPLITER + __MACHINE_ID,
                        TAG_DATABASE_SERVER_NAME + TAG_SPLITER + __DB_SERVER_NAME,
                        TAG_SERVICE_RUNNING + TAG_SPLITER + __SERVICE_RUNNING_STATUS
                    };

                    // Write the string array to a new file named "Config.ini".
                    using (StreamWriter outputFile = new StreamWriter(DIRECTORY_PATH + "\\" + CONFIG_FILE_NAME))
                    {
                        foreach (string line in lines)
                            outputFile.WriteLine(line);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
        }

        [DllImport("shell32.dll")]
        static extern bool SHGetSpecialFolderPath(IntPtr hwndOwner, [Out] StringBuilder lpszPath, int nFolder, bool fCreate);
        const int CSIDL_STARTUP = 7;
        internal static string GetUserStartupPath()
        {
            StringBuilder allUserProfile = new StringBuilder(260);
            SHGetSpecialFolderPath(IntPtr.Zero, allUserProfile, CSIDL_STARTUP, false);
            string commonStartupPath = allUserProfile.ToString();
            //The above API call returns: C:\Users\GIGABYTE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
            //Console.WriteLine(commonStartupPath);

            return commonStartupPath;
        }

        internal static void CreateShortcut()
        {
            //object shDesktop = (object)"Desktop";
            //WshShell shell = new WshShell();
            //string shortcutAddress = (string)shell.SpecialFolders.Item(ref shDesktop) + @"\Notepad.lnk";
            //IWshShortcut shortcut = (IWshShortcut)shell.CreateShortcut(shortcutAddress);
            //shortcut.Description = "New shortcut for a Notepad";
            //shortcut.Hotkey = "Ctrl+Shift+N";
            //shortcut.TargetPath = Environment.GetFolderPath(Environment.SpecialFolder.System) + @"\notepad.exe";
            //shortcut.Save();

            try
            {
                if (GetUserStartupPath() != Directory.GetCurrentDirectory())
                {
                    WshShell shell = new WshShell();
                    string shortcutAddress = Directory.GetCurrentDirectory() + "\\" + "nSoft.exe.lnk";
                    IWshShortcut shortcut = (IWshShortcut)shell.CreateShortcut(shortcutAddress);
                    shortcut.Description = "Shortcut of nSoft.exe";
                    shortcut.TargetPath = Directory.GetCurrentDirectory() + "\\" + "nSoft.exe";
                    shortcut.Save();
                }
            }
            catch (Exception e)
            {

            }
        }
        #endregion
    }

    public static class ManageExcel
    {
        public static Excel.Worksheet CreateExcelSheets(Excel.Workbook workBook, string fileAddress, string sendData)
        {
            Excel.Worksheet worksheet = (Excel.Worksheet)workBook.Sheets[1];
            worksheet.Name = "Report";

            // headline
            worksheet.Cells[1, 1] = "Report Type";
            worksheet.Cells[1, 3] = "app.nSofts";

            // body
            worksheet.Cells[2, 1] = sendData;

            worksheet.SaveAs(fileAddress, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Excel.XlSaveAsAccessMode.xlNoChange, Type.Missing, Type.Missing, Type.Missing);

            return worksheet;
        }
    }

    public static class FileManager
    {
        public static void CreateExcelFile(string fileAddress, string sendData)
        {
            if (System.IO.File.Exists(fileAddress))
            {
                System.IO.File.Delete(fileAddress);
            }

            object Nothing = System.Reflection.Missing.Value;
            var app = new Excel.Application();
            app.Visible = false;
            Excel.Workbook workBook = app.Workbooks.Add(Nothing);

            ManageExcel.CreateExcelSheets(workBook, fileAddress, sendData);

            workBook.Close(true, Type.Missing, Type.Missing);
            app.Quit();
        }

        public static void DeleteDir(string srcPath)
        {
            try
            {
                DirectoryInfo dir = new DirectoryInfo(srcPath);
                FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();
                foreach (FileSystemInfo i in fileinfo)
                {
                    if (i is DirectoryInfo)
                    {
                        DirectoryInfo subdir = new DirectoryInfo(i.FullName);
                        subdir.Delete(true);
                    }
                    else
                    {
                        System.IO.File.Delete(i.FullName);
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        public static void DeleteFile(string path1)
        {
            try
            {
                if (System.IO.File.Exists(path1))
                {
                    System.IO.File.Delete(path1);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }
    }

    public static class MailAPI
    {
        public static void SendEmail(string ownerEmail, int emailType, string searchKey)
        {
            DataSet ds1;
            //String connectionString = "Server=DESKTOP-7C5UDOE\\SQLEXPRESS;Database=POSLaundry;User=sa;Password=p@ssw0rd;MultipleActiveResultSets=True;";
            LocalReport report = new LocalReport();

            string procedureName = "";
            string strEmailType = "";
            string dateTime = Global.EMPTY_STRING;
            string userName = Global.EMPTY_STRING;

            string[] dataArray = searchKey.Split('_');

            if (emailType == DBConnection._Email_Staff_Profile)
            {
                strEmailType = "Staff_Profile";
                procedureName = "App_DailyTimeRecordByStaff";

                if (dataArray.Length > 1)
                {
                    dateTime = dataArray[1];
                    if (dateTime == Global.EMPTY_STRING && dataArray[0] != DBConnection._Report_Type_Yearly)
                        dateTime = DateTime.Now.ToString("yyyy-MM-dd");

                    userName = dataArray[0];
                }
            }

            if (emailType == DBConnection._Email_Report_Sales)
            {
                strEmailType = "Report_Sales";

                if (dataArray.Length > 1)
                {
                    if (dataArray[0] == DBConnection._Report_Type_Hourly)
                        procedureName = "App_SalesReport_Hourly";
                    else if (dataArray[0] == DBConnection._Report_Type_Daily)
                        procedureName = "App_SalesReport_Daily";
                    else if (dataArray[0] == DBConnection._Report_Type_Weekly)
                        procedureName = "App_SalesReport_Weekly";
                    else if (dataArray[0] == DBConnection._Report_Type_Monthly)
                        procedureName = "App_SalesReport_Monthly";
                    else if (dataArray[0] == DBConnection._Report_Type_Yearly)
                        procedureName = "App_SalesReport_Yearly";
                }

                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING && dataArray[0] != DBConnection._Report_Type_Yearly)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }
            if (emailType == DBConnection._Email_Report_Item_Sold)
            {
                strEmailType = "Report_Item_Sold";

                if (dataArray.Length > 1)
                {
                    if (dataArray[0] == DBConnection._Report_Type_Hourly)
                        procedureName = "App_ItemSoldHourly";
                    else if (dataArray[0] == DBConnection._Report_Type_Daily)
                        procedureName = "App_ItemSoldDaily";
                    else if (dataArray[0] == DBConnection._Report_Type_Weekly)
                        procedureName = "App_ItemSoldWeekly";
                    else if (dataArray[0] == DBConnection._Report_Type_Monthly)
                        procedureName = "App_ItemSoldMonthly";
                    else if (dataArray[0] == DBConnection._Report_Type_Yearly)
                        procedureName = "App_ItemSoldYearly";
                }

                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING && dataArray[0] != DBConnection._Report_Type_Yearly)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }
            if (emailType == DBConnection._Email_Report_Consolidate)
            {
                strEmailType = "Report_Shop_Comparison";

                if (dataArray.Length > 1)
                {
                    if (dataArray[0] == DBConnection._Report_Type_Hourly)
                        procedureName = "App_SalesReport_Hourly";
                    else if (dataArray[0] == DBConnection._Report_Type_Daily)
                        procedureName = "App_SalesReport_Daily";
                    else if (dataArray[0] == DBConnection._Report_Type_Weekly)
                        procedureName = "App_SalesReport_Weekly";
                    else if (dataArray[0] == DBConnection._Report_Type_Monthly)
                        procedureName = "App_SalesReport_Monthly";
                    else if (dataArray[0] == DBConnection._Report_Type_Yearly)
                        procedureName = "App_SalesReport_Yearly";
                }

                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING && dataArray[0] != DBConnection._Report_Type_Yearly)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }

            if (emailType == DBConnection._Email_Report_Customer_List)
            {
                strEmailType = "Report_Customer_List";
                procedureName = "App_CustomerList";
            }
            if (emailType == DBConnection._Email_Report_Product_Item_List)
            {
                strEmailType = "Report_Product_Item_List";
                procedureName = "App_ProductItemList";
            }
            if (emailType == DBConnection._Email_Report_Inventory)
            {
                strEmailType = "Report_Inventory";
                procedureName = "App_InventoryReport";
            }
            if (emailType == DBConnection._Email_Report_Top_Items)
            {
                strEmailType = "Report_Top_Items";
                procedureName = "App_TopSoldItem";
            }
            if (emailType == DBConnection._Email_Report_Least_Items)
            {
                strEmailType = "Report_Least_Items";
                procedureName = "App_LeastSoldItem";
            }
            if (emailType == DBConnection._Email_Report_Monthly_Report)
            {
                strEmailType = "Report_Monthly_Report";
                procedureName = "App_MonthlySalesReport";
                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }
            if (emailType == DBConnection._Email_Report_Item_Sold_Breakdown)
            {
                strEmailType = "Report_Item_Sold_Breakdown";
                procedureName = "App_ItemSoldBreakdown";
                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }
            if (emailType == DBConnection._Email_Report_Payins_Payout)
            {
                strEmailType = "Report_Payins_Payout";
                procedureName = "App_PayInsPayouts";
                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }
            if (emailType == DBConnection._Email_Report_Financial_Statement)
            {
                strEmailType = "Report_Financial_Statement";
                procedureName = "App_FinancialStatement";
                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }
            if (emailType == DBConnection._Email_Report_Petty_Cash)
            {
                strEmailType = "Report_Petty_Cash";
                procedureName = "App_PettyCash";
                dateTime = dataArray[1];
                if (dateTime == Global.EMPTY_STRING)
                    dateTime = DateTime.Now.ToString("yyyy-MM-dd");
            }

            ds1 = DBConnection.GetReportDataSet(procedureName, dateTime, userName);
            ReportDataSource ds = new ReportDataSource("DataSet1", ds1.Tables[0]);
            report.DataSources.Add(ds);
            report.ReportPath = AppDomain.CurrentDomain.BaseDirectory + @"\Reports\" + procedureName + ".rdl";
            //ReportParameter p1 = new ReportParameter("ConnectionString", DBConnection.builder.ConnectionString);
            if (dateTime != Global.EMPTY_STRING)
            {
                ReportParameter p1 = new ReportParameter("date", dateTime);
                report.SetParameters(p1);
            }
            if (userName != Global.EMPTY_STRING)
            {
                ReportParameter p1 = new ReportParameter("username", userName);
                report.SetParameters(p1);
            }
            Send(ownerEmail, strEmailType, report);


            //Console.WriteLine(strEmailType);
            //Console.WriteLine(searchKey);

            //FileManager.CreateExcelFile(Directory.GetCurrentDirectory() + "\\Report.xlsx", sendData);
            ////FileManager.CreateExcelFile(Directory.GetCurrentDirectory() + "\\Report.xlsx", strEmailType);
            ////MailAPI.SendReportMail(ownerEmail, Directory.GetCurrentDirectory() + "\\Report.xlsx");
            ////FileManager.DeleteFile(Directory.GetCurrentDirectory() + "\\Report.xlsx");
        }

        public static void Send(string ownerEmail, string baseFileName, LocalReport report)
        {
            string _sPathFilePDF = String.Empty;
            String v_mimetype;
            String v_encoding;
            String v_filename_extension;
            String[] v_streamids;
            String path;
            Microsoft.Reporting.WinForms.Warning[] warnings;
            byte[] byteViewer = report.Render("EXCEL", null, out v_mimetype, out v_encoding, out v_filename_extension, out v_streamids, out warnings);
            if (byteViewer == null || byteViewer.Length == 0) return;

            //string fileName = baseFileName + "_" + DateTime.Now.ToString("yyyyMMdd") + "_" + DateTime.Now.ToString("hhmmss") + ".xls";
            string fileName = baseFileName + "_" + DateTime.Now.ToString("yyyyMMdd") + ".xls";

            path = System.IO.Path.Combine(Global.BASE_DIRECTORY_PATH + fileName);
            System.IO.File.WriteAllBytes(path, byteViewer);

            //SendReportMail("carl.nsofts@gmail.com,app.nsofts@gmail.com,derek.nsofts@gmail.com", path);
            SendReportMail(ownerEmail, path);
            FileManager.DeleteFile(Global.BASE_DIRECTORY_PATH + fileName);
        }

        public static void SendReportMail(string ownerEmail, string fileAddress)
        {
            SmtpClient client = new SmtpClient();
            MailMessage message = null;

            try
            {
                MailAddress from = new MailAddress(Properties.Resources.MAIL_ADDRESS);
                // MailAddress to = new MailAddress();

                message = new MailMessage();
                message.From = from;
                message.To.Add(ownerEmail);

                message.Subject = Properties.Resources.MAIL_TITLE;
                message.SubjectEncoding = Encoding.UTF8;
                message.Body = Properties.Resources.MAIL_CONTENT;

                string mime = MimeMapping.GetMimeMapping(fileAddress);
                message.Attachments.Add(new Attachment(fileAddress, mime));

                client.Host = Properties.Resources.MAIL_SERVER;
                client.Port = 587;
                client.Credentials = new System.Net.NetworkCredential(Properties.Resources.MAIL_ADDRESS, Properties.Resources.MAIL_PWD);
                client.EnableSsl = true;
                client.Send(message);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

            if (message != null)
                message.Dispose();

            if (client != null)
                client.Dispose();
        }
    }
}
