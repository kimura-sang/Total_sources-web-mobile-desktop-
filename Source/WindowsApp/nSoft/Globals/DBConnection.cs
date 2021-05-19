using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace nSoft.Globals
{
    public static class DBConnection
    {
        #region Consts
        public const int _Dashboard_Get = 100;
        public const int _Dashboard_Get_Only_Inventory = 101;
        public const int _MyShop_Get_Amount = 110;
        public const int _Transactions_Get = 120;
        public const int _Transactions_Get_Prev = 121;
        public const int _Transactions_Get_Next = 122;
        public const int _Customers_Get_Top20 = 130;
        public const int _Customers_Get_Search_All = 134;
        public const int _Customers_Get_Search = 135;
        public const int _Customer_Detail_Selected = 131;
        public const int _Customer_Detail_Prev= 132;
        public const int _Customer_Detail_Next= 133;
        public const int _Staff_Get = 140;
        public const int _Staff_Detail_Selected = 141;
        public const int _Staff_Detail_Prev = 142;
        public const int _Staff_Detail_Next = 143;
        public const int _Offer_Get = 150;
        public const int _Offer_Get_Detail = 151;
        public const int _Offer_Save_Detail = 152;
        public const int _Offer_Replenish_Get_Category = 153;
        public const int _Offer_Replenish_Get_Category_Detail = 154;
        public const int _Offer_Replenish_Save = 155;
        public const int _Report_Sales = 160;
        public const int _Report_Item_Sold = 161;
        public const int _Report_Consolidate = 162;
        public const int _Notice_Get = 170;
        public const int _Notice_Viewed = 171;
        public const int _Notice_Hidden = 172;
        public const int _Notice_Acted = 173;

        public const int _Email_Staff_Profile = 241;
        public const int _Email_Report_Sales = 260;
        public const int _Email_Report_Item_Sold = 261;
        public const int _Email_Report_Consolidate = 262;
        public const int _Email_Report_Customer_List = 263;
        public const int _Email_Report_Product_Item_List = 264;
        public const int _Email_Report_Inventory = 265;
        public const int _Email_Report_Top_Items = 266;
        public const int _Email_Report_Least_Items = 267;
        public const int _Email_Report_Monthly_Report = 268;
        public const int _Email_Report_Item_Sold_Breakdown = 269;
        public const int _Email_Report_Payins_Payout = 2610;
        public const int _Email_Report_Financial_Statement = 2611;
        public const int _Email_Report_Petty_Cash = 2612;

        public const string _Report_Type_Hourly  = "Hourly";
        public const string _Report_Type_Daily   = "Daily";
        public const string _Report_Type_Weekly  = "Weekly";
        public const string _Report_Type_Monthly = "Monthly";
        public const string _Report_Type_Yearly  = "Yearly";
        #endregion

        #region Variables
        public static SqlConnection __SQL_CONNECTION = new SqlConnection();
        public static SqlConnectionStringBuilder builder;

        public static bool __DBConnected
        {
            get; set;
        }
        #endregion

        #region Methods
        public async static Task<bool> TryingToConnect()
        {
            bool response = false;
            try
            {
                builder = new SqlConnectionStringBuilder();
                builder.DataSource = Global.__DB_SERVER_NAME;
                builder.InitialCatalog = "POSLaundry";
                builder.IntegratedSecurity = true;
                using (__SQL_CONNECTION = new SqlConnection(builder.ConnectionString))
                {
                    await __SQL_CONNECTION.OpenAsync();
                    __SQL_CONNECTION.Close();

                    __DBConnected = true;
                }
            }
            catch (Exception ex)
            {
                __DBConnected = false;
            }

            response = __DBConnected;
            return response;
        }

        public static DataTable GetDataTable(DataTable Table, string Query)
        {
            try
            {
                __SQL_CONNECTION = new SqlConnection(builder.ConnectionString);
                __SQL_CONNECTION.Open();
                SqlCommand cmd = new SqlCommand(Query, __SQL_CONNECTION);
                SqlDataAdapter data = new SqlDataAdapter(cmd);
                data.Fill(Table);
                data.Dispose();
                __SQL_CONNECTION.Close();
            }
            catch (Exception ex)
            {
                Global.MainViewModel.ShowStatus("Cannot get data from Database!");
                Global.MainViewModel.AddToLogs("Cannot get data from Database!");
            }
            finally
            {
                __SQL_CONNECTION.Close();
            }

            return Table;
        }

        public static string GetDataFromTable(string sql)
        {
            DataTable data = new DataTable();
            GetDataTable(data, sql);
            string[,] result = new string[data.Rows.Count, data.Columns.Count];
            for (int i = 0; i < data.Rows.Count; i++)
            {
                for (int j = 0; j < data.Columns.Count; j++)
                {
                    result[i, j] = data.Rows[i][j].ToString();
                }
            }

            return JsonConvert.SerializeObject(result);
        }

        public async static Task<string> GetDataFromSQLNo(int sqlNo, string searchKey, string requestBy)
        {
            JObject result = new JObject();

            if (sqlNo == _Dashboard_Get)
            {
                Global.AddDatabaseLogToMainViewModel("Dashboard", requestBy);

                result.Add("category", GetDataFromTable(GetDashboardCategory()));
                result.Add("dashboard1", GetDataFromTable(GetDashboardQuery1()));
                result.Add("dashboard2", GetDataFromTable(GetDashboardQuery2()));
                result.Add("dashboard3", GetDataFromTable(GetDashboardQuery3_First()));
                result.Add("dashboard4", GetDataFromTable(GetDashboardQuery4()));
            }
            if (sqlNo == _Dashboard_Get_Only_Inventory)
            {
                Global.AddDatabaseLogToMainViewModel("Dashboard", requestBy);

                result.Add("dashboard3", GetDataFromTable(GetDashboardQuery3(searchKey)));
            }
            if (sqlNo == _MyShop_Get_Amount)
            {
                Global.AddDatabaseLogToMainViewModel("MyShop_Amount", requestBy);

                result.Add("amount", GetDataFromTable(GetMyShopAmount()));
            }
            if (sqlNo == _Transactions_Get)
            {
                Global.AddDatabaseLogToMainViewModel("Transaction", requestBy);

                string jsonData = GetDataFromTable(GetTransactionsLastShift());
                var data = JArray.Parse(jsonData);
                string no = "";
                if (data != null && data.First != null && data.First.First != null)
                    no = data.First.First.ToString();

                result.Add("transactionShift", jsonData);
                result.Add("transactionList", GetDataFromTable(GetTransactionsLastTransactionList(no)));
            }
            if (sqlNo == _Transactions_Get_Prev)
            {
                Global.AddDatabaseLogToMainViewModel("Transaction-Previous", requestBy);

                result.Add("transactionShift", GetDataFromTable(GetTransactionsPrevShift(searchKey)));
                result.Add("transactionList", GetDataFromTable(GetTransactionsPrevTransactionList(searchKey)));
            }
            if (sqlNo == _Transactions_Get_Next)
            {
                Global.AddDatabaseLogToMainViewModel("Transaction-Next", requestBy);

                result.Add("transactionShift", GetDataFromTable(GetTransactionsNextShift(searchKey)));
                result.Add("transactionList", GetDataFromTable(GetTransactionsNextTransactionList(searchKey)));
            }
            if (sqlNo == _Customers_Get_Top20)
            {
                Global.AddDatabaseLogToMainViewModel("Customer", requestBy);

                result.Add("premium", GetDataFromTable(GetCustomerPremium(_Customers_Get_Top20, "")));
                result.Add("regular", GetDataFromTable(GetCustomerRegular(_Customers_Get_Top20, "")));
            }
            if (sqlNo == _Customers_Get_Search_All)
            {
                Global.AddDatabaseLogToMainViewModel("Customer", requestBy);

                result.Add("premium", GetDataFromTable(GetCustomerPremium(_Customers_Get_Search_All, "")));
                result.Add("regular", GetDataFromTable(GetCustomerRegular(_Customers_Get_Search_All, "")));
            }
            if (sqlNo == _Customers_Get_Search)
            {
                Global.AddDatabaseLogToMainViewModel("Customer", requestBy);

                result.Add("premium", GetDataFromTable(GetCustomerPremium(_Customers_Get_Search, searchKey)));
                result.Add("regular", GetDataFromTable(GetCustomerRegular(_Customers_Get_Search, searchKey)));
            }
            if (sqlNo == _Customer_Detail_Selected)
            {
                Global.AddDatabaseLogToMainViewModel("Customer_Selected_Detail", requestBy);

                result.Add("detail", GetDataFromTable(GetCustomerDetailSelected(searchKey)));
                result.Add("transaction", GetDataFromTable(GetCustomerDetailSelectedTransaction(searchKey)));
            }
            if (sqlNo == _Customer_Detail_Prev)
            {
                Global.AddDatabaseLogToMainViewModel("Customer_Previous_Detail", requestBy);

                result.Add("detail", GetDataFromTable(GetCustomerDetailPrev(searchKey)));
                result.Add("transaction", GetDataFromTable(GetCustomerDetailPrevTransaction(searchKey)));
            }
            if (sqlNo == _Customer_Detail_Next)
            {
                Global.AddDatabaseLogToMainViewModel("Customer_Next_Detail", requestBy);

                result.Add("detail", GetDataFromTable(GetCustomerDetailNext(searchKey)));
                result.Add("transaction", GetDataFromTable(GetCustomerDetailNextTransaction(searchKey)));
            }
            if (sqlNo == _Staff_Get)
            {
                Global.AddDatabaseLogToMainViewModel("Staff_List", requestBy);

                result.Add("list", GetDataFromTable(GetStaffList()));
            }
            if (sqlNo == _Staff_Detail_Selected)
            {
                Global.AddDatabaseLogToMainViewModel("Staff_Selected_Detail", requestBy);

                result.Add("profile", GetDataFromTable(GetStaffDetailProfile(searchKey)));
            }
            if (sqlNo == _Staff_Detail_Prev)
            {
                Global.AddDatabaseLogToMainViewModel("Staff_Previous_Detail", requestBy);

                result.Add("profile", GetDataFromTable(GetStaffDetailProfilePrev(searchKey)));
            }
            if (sqlNo == _Staff_Detail_Next)
            {
                Global.AddDatabaseLogToMainViewModel("Next_Detail", requestBy);

                result.Add("profile", GetDataFromTable(GetStaffDetailProfileNext(searchKey)));
            }
            if (sqlNo == _Offer_Get)
            {
                Global.AddDatabaseLogToMainViewModel("Offer_List", requestBy);

                result.Add("category", GetDataFromTable(GetOfferCategory()));
                result.Add("available", GetDataFromTable(GetOfferAvailable()));
                result.Add("disable", GetDataFromTable(GetOfferDisable()));
            }
            if (sqlNo == _Offer_Get_Detail)
            {
                Global.AddDatabaseLogToMainViewModel("Offer_Get_Detail", requestBy);

                result.Add("detail", GetDataFromTable(GetOfferDetail(searchKey)));
                result.Add("content", GetDataFromTable(GetOfferDetailContent(searchKey)));
            }
            if (sqlNo == _Offer_Save_Detail)
            {
                Global.AddDatabaseLogToMainViewModel("Offer_Save_Detail", requestBy);

                result.Add("result", GetDataFromTable(SaveOfferDetail(searchKey)));
            }
            if (sqlNo == _Offer_Replenish_Get_Category)
            {
                Global.AddDatabaseLogToMainViewModel("Replenish_Category", requestBy);

                result.Add("options", GetDataFromTable(GetReplenishGetCategory()));
            }
            if (sqlNo == _Offer_Replenish_Get_Category_Detail)
            {
                Global.AddDatabaseLogToMainViewModel("Replenish_Category_Detail", requestBy);

                result.Add("options", GetDataFromTable(GetReplenishGetCategoryDetail(searchKey)));
            }
            if (sqlNo == _Offer_Replenish_Save)
            {
                Global.AddDatabaseLogToMainViewModel("Save_Replenish", requestBy);
                string res = SaveReplenish(searchKey);

                Dictionary<string, string> resultDic = new Dictionary<string, string>();
                resultDic.Add("result", res);

                result.Add("result", JsonConvert.SerializeObject(resultDic));
            }
            if (sqlNo == _Report_Sales)
            {
                Global.AddDatabaseLogToMainViewModel("Report_Sales", requestBy);

                result.Add("result", GetDataFromTable(GetReportSales(searchKey)));
            }
            if (sqlNo == _Report_Item_Sold)
            {
                Global.AddDatabaseLogToMainViewModel("Report_Item_Sold", requestBy);

                result.Add("result", GetDataFromTable(GetReportItemSold(searchKey)));
            }
            if (sqlNo == _Report_Consolidate)
            {
                Global.AddDatabaseLogToMainViewModel("Report_Consolidate", requestBy);

                result.Add("result", GetDataFromTable(GetReportConsolidate(searchKey)));
            }
            if (sqlNo == _Notice_Get)
            {
                Global.AddDatabaseLogToMainViewModel("Notice_Get", requestBy);

                result.Add("result", GetDataFromTable(GetNoticeList()));
            }
            if (sqlNo == _Notice_Viewed)
            {
                Global.AddDatabaseLogToMainViewModel("Notice_Viewed", requestBy);

                result.Add("result", GetDataFromTable(UpdateNoticeViewed(searchKey)));
            }
            if (sqlNo == _Notice_Hidden)
            {
                Global.AddDatabaseLogToMainViewModel("Notice_Hidden", requestBy);

                result.Add("result", GetDataFromTable(UpdateNoticeHidden(searchKey)));
            }
            if (sqlNo == _Notice_Acted)
            {
                Global.AddDatabaseLogToMainViewModel("Notice_Acted", requestBy);

                string[] dataArray = searchKey.Split('_');
                string noticeNo = dataArray[0];
                int action = -1;
                if (dataArray.Length > 1)
                    action = Convert.ToInt32(dataArray[1]);

                if (dataArray.Length > 1)
                {
                    result.Add("result", GetDataFromTable(UpdateNoticeActed(noticeNo, action)));
                } 
                else
                {
                    result.Add("result", GetDataFromTable(UpdateNoticeHidden(noticeNo)));
                }
            }

            /// Email sending
            if (sqlNo == _Email_Staff_Profile)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Staff_Profile", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }

            if (sqlNo == _Email_Report_Sales)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Sales", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Item_Sold)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Item_Sold", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Consolidate)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Consolidate", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }

            if (sqlNo == _Email_Report_Customer_List)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Customer_List", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Product_Item_List)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Product_Item_List", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Inventory)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Inventory", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Top_Items)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Top_Items", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Least_Items)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Least_Items", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Monthly_Report)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Monthly_Report", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Item_Sold_Breakdown)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Item_Sold_Breakdown", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Payins_Payout)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Payins_Payout", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Financial_Statement)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Financial_Statement", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }
            if (sqlNo == _Email_Report_Petty_Cash)
            {
                Global.AddDatabaseLogToMainViewModel("Email_Report_Petty_Cash", requestBy);
                await Task.Factory.StartNew(() => MailAPI.SendEmail(requestBy, sqlNo, searchKey));

                result.Add("result", "Send Success");
            }

            return JsonConvert.SerializeObject(result);
        }
        #endregion

        #region Procedures
        public static void CreateNewProcedures()
        {
            __SQL_CONNECTION = new SqlConnection(builder.ConnectionString);
            __SQL_CONNECTION.Open();

            // Create or Alter Get Numeric SQL
            string sqlGetNumeric = GetProcedureSQLGetNumeric(true);
            try
            {
                SqlCommand cmd = new SqlCommand(sqlGetNumeric, __SQL_CONNECTION);
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("There is already an object named"))
                {
                    sqlGetNumeric = GetProcedureSQLGetNumeric(false);
                    SqlCommand cmd = new SqlCommand(sqlGetNumeric, __SQL_CONNECTION);
                    cmd.ExecuteNonQuery();
                }
            }

            // Create or Alter Item Replenish SQL
            string sqlItemReplenish = GetProcedureSQLReplenish(true);
            try
            {
                SqlCommand cmd = new SqlCommand(sqlItemReplenish, __SQL_CONNECTION);
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("There is already an object named"))
                {
                    sqlItemReplenish = GetProcedureSQLReplenish(false);
                    SqlCommand cmd = new SqlCommand(sqlItemReplenish, __SQL_CONNECTION);
                    cmd.ExecuteNonQuery();
                }
            }

            // Create and Alter Item Replenish No Expired Detail SQL
            string sqlItemReplenishDetail = GetProcedureSQLReplenishNoExpiredDetail(true);
            try
            {
                SqlCommand cmd = new SqlCommand(sqlItemReplenishDetail, __SQL_CONNECTION);
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("There is already an object named"))
                {
                    sqlItemReplenishDetail = GetProcedureSQLReplenishNoExpiredDetail(false);
                    SqlCommand cmd = new SqlCommand(sqlItemReplenishDetail, __SQL_CONNECTION);
                    cmd.ExecuteNonQuery();
                }
            }

            // Create and Alter Item Replenish With Expired Detail SQL
            string sqlItemReplenishDetail1 = GetProcedureSQLReplenishWithExpiredDetail(true);
            try
            {
                SqlCommand cmd = new SqlCommand(sqlItemReplenishDetail1, __SQL_CONNECTION);
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("There is already an object named"))
                {
                    sqlItemReplenishDetail1 = GetProcedureSQLReplenishWithExpiredDetail(false);
                    SqlCommand cmd = new SqlCommand(sqlItemReplenishDetail1, __SQL_CONNECTION);
                    cmd.ExecuteNonQuery();
                }
            }
            finally
            {
                __SQL_CONNECTION.Close();
            }

            CreateNewDataSetProcedures();
        }

        public static string InsertItemReplenish(string ownerName, SqlTransaction transaction)
        {
            SqlCommand command = new SqlCommand("[POSMCItemReplenish_Insert]", __SQL_CONNECTION);

            command.Transaction = transaction;

            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@ReplenishBy", ownerName));
            command.Parameters.Add("@NewRepNo", SqlDbType.VarChar, 10).Direction = ParameterDirection.Output;

            int result = command.ExecuteNonQuery();

            string newRepNo = (string)command.Parameters["@NewRepNo"].Value;

            return newRepNo;
        }

        public static void InsertItemReplenishDetail(string replenishNo, string itemCode, int quantity, string unit, 
                                                        string expiredDate, SqlTransaction transaction)
        {
            string sqlString = "";
            if (expiredDate == null)
                sqlString = "[POSMCItemReplenishNoExpiredDetails_Insert]";
            else
                sqlString = "[POSMCItemReplenishWithExpiredDetails_Insert]";

            SqlCommand command = new SqlCommand(sqlString, __SQL_CONNECTION);

            command.Transaction = transaction;

            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@ReplenishNo", replenishNo));
            command.Parameters.Add(new SqlParameter("@ItemCode", itemCode));
            command.Parameters.Add(new SqlParameter("@Quantity", quantity));
            command.Parameters.Add(new SqlParameter("@Unit", unit));
            if (expiredDate != null)
                command.Parameters.Add(new SqlParameter("@Expiry", Convert.ToDateTime(expiredDate)));

            int result = command.ExecuteNonQuery();
        }

        public static string SaveReplenish(string saveData)
        {
            string result = "Success";

            __SQL_CONNECTION = new SqlConnection(builder.ConnectionString);
            SqlTransaction transaction = null;

            try
            {
                __SQL_CONNECTION.Open();
                transaction = __SQL_CONNECTION.BeginTransaction();

                JObject jObject = JObject.Parse(saveData);
                string ownerName = jObject["ownerName"].ToObject<string>();
                var data = JArray.Parse(jObject["replenish"].ToString());

                string newReplenishNo = InsertItemReplenish(ownerName, transaction);
                foreach (var datum in data)
                {
                    var parsedData = datum.ToObject<Dictionary<string, object>>();

                    string itemCode = "";
                    int quantity = 0;
                    string unit = "";
                    string expiredDate = null;

                    foreach (var param in parsedData)
                    {
                        if (param.Key == "item_code")
                            itemCode = param.Value.ToString();
                        if (param.Key == "quantity")
                            quantity = Int32.Parse(param.Value.ToString());
                        if (param.Key == "unit")
                            unit = param.Value.ToString();
                        if (param.Key == "expired_date")
                        {
                            if (param.Value != null)
                                expiredDate = param.Value.ToString();
                        }
                    }

                    InsertItemReplenishDetail(newReplenishNo, itemCode, quantity, unit, expiredDate, transaction);
                }

                transaction.Commit();
            }
            catch (Exception ex)
            {
                Global.AddDatabaseLogToMainViewModel("SaveReplenish_DB_Handling", ex.Message);
                result = "Failed";
            }
            finally
            {
                __SQL_CONNECTION.Close();
            }

            return result;
        }
        #endregion

        #region SQL Queries
        /// <summary>
        /// Dashboard
        /// </summary>
        public static string GetDashboardCategory()
        {
            return "SELECT [Category] FROM [dbo].[POSMCItemCategory]";
        }

        public static string GetDashboardQuery1()
        {
            return " DECLARE @PayIn money, @PayOut money, @OperationNo int;" +
                " SET @OperationNo = (SELECT MAX([No]) FROM [dbo].[POSMCOperation]) " +
                " SET @PayIn = (SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayIns] WHERE [OperationNo] = @OperationNo)" +
                " SET @PayOut = (SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayOuts] WHERE [OperationNo] = @OperationNo)" +
                " " +
                "SELECT [O].[Shift] ,[OpenedDate] ,[OpenedBy]" +
                " ,(ISNULL([CashAmount], 0) + ISNULL([OpeningAmount], 0) + ISNULL(@PayIn, 0)) - ISNULL(@PayOut, 0) [DrawerAmount]" +
                " ,[O].[No]" +
                " FROM [dbo].[POSMCOperation]" +
                " [O]" +
                " LEFT JOIN(SELECT [OperationNo] , SUM([CashAmount])[CashAmount]" +
                " FROM [dbo].[POSMCTransactionReceipt]" +
                " GROUP BY [OperationNo]) [TR] ON[TR].[OperationNo] = [O].[No]" +
                " WHERE [O].[No] = @OperationNo";
        }

        public static string GetDashboardQuery2()
        {
            return "SELECT [MachineNo] ,[Machine] ,[Status], [Type], [Duration], [StartDate]" +
                " FROM [dbo].[Machine]" +
                " WHERE [NotAvailable] <> 1 " +
                " ORDER BY [MachineNo],[Machine]";
        }

        public static string GetDashboardQuery3_First()
        {
            return "SELECT [I].[Item],[I].[Unit],ISNULL((ISNULL([Stocks],0) + [Replenish]) - ([Wasted]+[Usage]),0) [Available]" +
                "	   ,[Usage],ISNULL([I].[CriticalLevel],0) [CriticalLevel]" +
                "        FROM" +
                "       (SELECT [I].[Code], [I].[Item], ISNULL(SUM([JODS].[DQuantity]),0) [Usage],[JODS].[ConsolidationNo],[I].[Unit]" +
                "				 ,[I].[ExcludeInventory],[I].[CriticalLevel],[I].[Category]" +
                "        FROM [dbo].[POSMCItem] [I]" +
                "        LEFT JOIN" +
                "       (SELECT [O].[ConsolidationNo], [SP].[JODetailNo], [JOD].[DeletedBy], [J].[CancelBy], [SP].[ItemCode], [SP].[Item]" +
                "                    , SUM([SP].[Quantity]) [DQuantity]" +
                "        FROM((([dbo].[POSMCJobOrderDetailProducts] [SP]" +
                "                     LEFT JOIN " +
                "                       (SELECT [No],[JONo],[DeletedBy]" +
                "                               FROM [dbo].[POSMCJobOrderDetails]) [JOD]" +
                "                                   ON[JOD].[No] = [SP].[JODetailNo])" +
                "                     LEFT JOIN(SELECT [No], [CancelBy], [OperationNo]" +
                "                                 FROM [dbo].[POSMCJobOrder]) [J]" +
                "                               ON[J].[No] = [JOD].[JONo])" +
                "						    LEFT JOIN(SELECT [No], [ConsolidationNo]" +
                "                                   FROM [dbo].[POSMCOperation]) [O]" +
                "                                   ON[O].[No] = [J].[OperationNo])" +
                "                         GROUP BY [O].[ConsolidationNo],[SP].[JODetailNo],[JOD].[DeletedBy],[J].[CancelBy],[SP].[ItemCode],[SP].[Item]) [JODS]" +
                "        ON[JODS].[ItemCode] = [I].[Code]" +
                "        WHERE [JODS].[CancelBy] IS NULL AND[JODS].[DeletedBy] IS NULL AND[JODS].[ConsolidationNo] IS NULL" +
                "    AND[Category] = (SELECT TOP 1 [Category] FROM [dbo].[POSMCItemCategory])" +
                "		 GROUP BY [I].[Category],[I].[Code],[I].[Item],[JODS].[ConsolidationNo],[I].[Unit],[I].[ExcludeInventory],[I].[CriticalLevel]) [I]" +
                "        LEFT JOIN(SELECT [IS].[Code], ISNULL([IS].[Quantity],0) [Stocks],ISNULL([RD].[IRQuantity],0) [Replenish],ISNULL([PD].[IPQuantity],0) [Wasted]" +
                "        FROM(SELECT [I].[Code], [IS].[Quantity], [IS].[UpdatedDate] FROM [dbo].[POSMCItem] [I] LEFT JOIN [dbo].[POSMCItemStocks] [IS] ON[IS].[ItemCode] = [I].[Code]) [IS]" +
                "        LEFT JOIN(SELECT [IR].[ItemCode], ISNULL(SUM([IR].[RQuantity]),0) [IRQuantity]" +
                "        FROM [dbo].[POSMCItemReplenish] [R]" +
                "        LEFT JOIN(SELECT [ReplenishNo], [ItemCode], SUM([Quantity])[RQuantity]" +
                "               FROM [dbo].[POSMCItemReplenishDetails]" +
                "                  GROUP BY [ReplenishNo], [ItemCode]) [IR]" +
                "        ON[IR].[ReplenishNo] = [R].[No]" +
                "        WHERE [R].[CancelBy] IS NULL AND[R].[ConsolidationNo] IS NULL" +
                "          GROUP BY [IR].[ItemCode]) [RD]" +
                "        ON[RD].[ItemCode] = [IS].[Code]" +
                "        LEFT JOIN(SELECT [IP].[ItemCode], ISNULL(SUM([IP].[RQuantity]),0) [IPQuantity]" +
                "        FROM [dbo].[POSMCItemPullOut] [P]" +
                "        LEFT JOIN(SELECT [PullOutNo], [ItemCode], SUM([Quantity])[RQuantity]" +
                "                FROM [dbo].[POSMCItemPullOutDetails]" +
                "                  GROUP BY [PullOutNo], [ItemCode]) [IP]" +
                "        ON[IP].[PullOutNo] = [p].[No]" +
                "        WHERE [P].[CancelBy] IS NULL AND[P].[ConsolidationNo] IS NULL" +
                "          GROUP BY [IP].[ItemCode]) [PD]" +
                "        ON[PD].[ItemCode] = [IS].[Code]" +
                "       GROUP BY [IS].[Code],CONVERT(date, [IS].[UpdatedDate]), [Is].[Quantity], [RD].[IRQuantity],[PD].[IPQuantity]) [OP]" +
                "        ON[I].[Code] = [OP].[Code]" +
                "        WHERE [I].[ExcludeInventory] <> 1 OR[I].[ExcludeInventory] IS NULL";
        }

        public static string GetDashboardQuery3(string category)
        {
            return "SELECT [I].[Item],[I].[Unit],ISNULL((ISNULL([Stocks],0) + [Replenish]) - ([Wasted]+[Usage]),0) [Available],[Usage],ISNULL([I].[CriticalLevel],0) [CriticalLevel]" +
                "        FROM(SELECT [I].[Code], [I].[Item], ISNULL(SUM([JODS].[DQuantity]),0) [Usage],[JODS].[ConsolidationNo],[I].[Unit],[I].[ExcludeInventory],[I].[CriticalLevel],[I].[Category]" +
                "               FROM [dbo].[POSMCItem] [I]" +
                "        LEFT JOIN(SELECT [O].[ConsolidationNo], [SP].[JODetailNo], [JOD].[DeletedBy], [J].[CancelBy], [SP].[ItemCode], [SP].[Item], SUM([SP].[Quantity]) [DQuantity]" +
                "        FROM((([dbo].[POSMCJobOrderDetailProducts] [SP]" +
                "                LEFT JOIN (SELECT [No],[JONo],[DeletedBy]" +
                "                    FROM [dbo].[POSMCJobOrderDetails]) [JOD] ON[JOD].[No] = [SP].[JODetailNo])" +
                "                  LEFT JOIN(SELECT [No], [CancelBy], [OperationNo]" +
                "                    FROM [dbo].[POSMCJobOrder]) [J] ON[J].[No] = [JOD].[JONo])" +
                "       LEFT JOIN(SELECT [No], [ConsolidationNo]" +
                "                FROM [dbo].[POSMCOperation]) [O] ON[O].[No] = [J].[OperationNo])" +
                "           GROUP BY [O].[ConsolidationNo],[SP].[JODetailNo],[JOD].[DeletedBy],[J].[CancelBy],[SP].[ItemCode],[SP].[Item]) [JODS]" +
                "        ON[JODS].[ItemCode] = [I].[Code]" +
                "        WHERE [JODS].[CancelBy] IS NULL AND[JODS].[DeletedBy] IS NULL AND[JODS].[ConsolidationNo] IS NULL" +
                "    AND[Category] = '"+ category+"'" +
                "         GROUP BY [I].[Category],[I].[Code],[I].[Item],[JODS].[ConsolidationNo],[I].[Unit],[I].[ExcludeInventory],[I].[CriticalLevel]) [I]" +
                "        LEFT JOIN(SELECT [IS].[Code], ISNULL([IS].[Quantity],0) [Stocks],ISNULL([RD].[IRQuantity],0) [Replenish],ISNULL([PD].[IPQuantity],0) [Wasted]" +
                "        FROM(SELECT [I].[Code], [IS].[Quantity], [IS].[UpdatedDate] FROM [dbo].[POSMCItem] [I] LEFT JOIN [dbo].[POSMCItemStocks] [IS] ON[IS].[ItemCode] = [I].[Code]) [IS]" +
                "        LEFT JOIN(SELECT [IR].[ItemCode], ISNULL(SUM([IR].[RQuantity]),0) [IRQuantity]" +
                "        FROM [dbo].[POSMCItemReplenish] [R]" +
                "        LEFT JOIN(SELECT [ReplenishNo], [ItemCode], SUM([Quantity])[RQuantity]" +
                "               FROM [dbo].[POSMCItemReplenishDetails]" +
                "                  GROUP BY [ReplenishNo], [ItemCode]) [IR] ON[IR].[ReplenishNo] = [R].[No]" +
                "        WHERE [R].[CancelBy] IS NULL AND[R].[ConsolidationNo] IS NULL" +
                "          GROUP BY [IR].[ItemCode]) [RD] ON[RD].[ItemCode] = [IS].[Code]" +
                "        LEFT JOIN(SELECT [IP].[ItemCode], ISNULL(SUM([IP].[RQuantity]),0) [IPQuantity]" +
                "        FROM [dbo].[POSMCItemPullOut] [P]" +
                "        LEFT JOIN(SELECT [PullOutNo], [ItemCode], SUM([Quantity])[RQuantity]" +
                "                FROM [dbo].[POSMCItemPullOutDetails]" +
                "                  GROUP BY [PullOutNo], [ItemCode]) [IP]" +
                "        ON[IP].[PullOutNo] = [p].[No]" +
                "        WHERE [P].[CancelBy] IS NULL AND[P].[ConsolidationNo] IS NULL" +
                "          GROUP BY [IP].[ItemCode]) [PD] ON[PD].[ItemCode] = [IS].[Code]" +
                "        GROUP BY [IS].[Code],CONVERT(date, [IS].[UpdatedDate]), [Is].[Quantity], [RD].[IRQuantity],[PD].[IPQuantity]) [OP] ON[I].[Code] = [OP].[Code]" +
                "        WHERE [I].[ExcludeInventory] <> 1 OR[I].[ExcludeInventory] IS NULL";
        }

        public static string GetDashboardQuery4()
        {
            return "SELECT [U].[UserName],[Role],[Shift],[Date],[TimeIn],[TimeOut],[Disabled]" +
                "        FROM [dbo].[POSMCUser] [U]" +
                "        LEFT JOIN" +
                "       (SELECT isnull([TIN].[UserName], [TOUT].[UserName]) [UserName],isnull([TIN].[Shift], [TOUT].[Shift]) [Shift]" +
                "               ,isnull([TIN].[Date], [TOUT].[Date]) [Date],[TimeIn],[TimeOut]" +
                "       FROM" +
                "       (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeIn]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-IN' and[UserName] <> 'ADMIN'" +
                "       AND cast([AttendanceDate] as date ) = cast((SELECT MAX([OpenedDate]) FROM [dbo].[POSMCOperation]) as date)" +
                "       GROUP BY [UserName], [Type], [Shift], cast([AttendanceDate] as date )) [TIN]" +
                "        FULL OUTER JOIN" +
                "        (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeOut]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-OUT' and[UserName] <> 'ADMIN'" +
                "       AND cast([AttendanceDate] as date ) = cast((SELECT MAX([OpenedDate]) FROM [dbo].[POSMCOperation]) as date)" +
                "       GROUP BY [UserName], [Type], [Shift], cast([AttendanceDate] as date )) [TOUT]" +
                "        ON[TIN].[UserName] = [TOUT].[UserName]" +
                "        AND[TIN].[Shift] = [TOUT].[Shift]" +
                "        AND[TIN].[Date] = [TOUT].[Date]) [TIME]" +
                "        ON[U].UserName = [TIME].UserName" +
                "   WHERE [Disabled] is null and[Role] <> 'ADMIN'" +
                "   ORDER BY [TimeOut] desc,[TimeIn] desc,[Date],[Shift]";
        }

        /// <summary>
        /// My shop
        /// </summary>
        public static string GetMyShopAmount()
        {
            return "DECLARE @PAYIN money" +
                "    DECLARE @PAYOUT money" +
                "    DECLARE @OperationNo int" +
                "    SET @OperationNo = ISNULL((SELECT MAX([No]) FROM [dbo].[POSMCOperation] WHERE [ClosedBy] IS NULL), 0)" +
                "	SET @PAYIN = ISNULL((SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayIns] WHERE [OperationNo] = @OperationNo), 0)" +
                "	SET @PAYOUT = ISNULL((SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayOuts] WHERE [OperationNo] = @OperationNo), 0)" +
                "	IF(@OperationNo <> 0)" +
                "    BEGIN" +
                "   SELECT SUM(([TR].[CashPayment] +[O].[OpeningAmount] + @PAYIN) - @PAYOUT)[CurrentDrawer]" +
                "    FROM [dbo].[POSMCOperation] as [O]" +
                "    LEFT JOIN(SELECT [OperationNo], (SELECT ISNULL(SUM([TotalAmount]),0)" +
                "	FROM [dbo].[POSMCTransactionReceipt]" +
                "   WHERE [CancelBy] IS NULL AND[OperationNo] = @OperationNo) [Sales],ISNULL(SUM([CashAmount]),0) [CashPayment],ISNULL(SUM([ServiceChargeAmount]),0) [ServiceCharge]" +
                "        FROM [dbo].[POSMCTransactionReceipt] [T]" +
                "        WHERE [CancelBy] IS NULL" +
                "    GROUP BY [OperationNo] ,[CancelBy]) [TR]" +
                "        ON[TR].[OperationNo] = [O].[No]" +
                "        WHERE [O].[No] = @OperationNo" +
                "       GROUP BY [O].[OpeningAmount],[TR].[CashPayment]" +
                "        END" +
                "   ELSE" +
                "  BEGIN" +
                "   SELECT SUM(([CashPayment]+[OpeningAmount]+[PayIn])-[PayOut]) [CurrentDrawer]" +
                "        FROM [dbo].[POSMCOperation]" +
                "        WHERE [No] = (SELECT MAX([No]) FROM [dbo].[POSMCOperation])" +
                "  END";
        }

        /// <summary>
        /// Transactions
        /// </summary>
        public static string GetTransactionsLastShift()
        {
            return "DECLARE @No int" +
                "  SET @No = (SELECT MAX([No]) FROM [dbo].[POSMCOperation])" +
                "        IF(@No = (SELECT MAX([No]) FROM [dbo].[POSMCOperation] WHERE [ClosedBy] IS NULL))" +
                "	    SELECT [No], [Shift], [OpenedDate], [OpenedBy], [ClosedDate], [ClosedBy], " +
                "           ((ISNULL((SELECT SUM([CashAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND[OperationNo] = @No),0) + ISNULL((SELECT SUM([OpeningAmount]) FROM [dbo].[POSMCOperation] WHERE [No] = @No),0) + ISNULL((SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayIns] WHERE [OperationNo] = @No),0)) - ISNULL((SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayOuts] WHERE [OperationNo] = @No),0)) [CashReceived]" +
                "		  ,ISNULL((SELECT SUM([TotalAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND [OperationNo] = @No),0) + ISNULL((SELECT SUM([ServiceChargeAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND [OperationNo] = @No),0) + ISNULL((SELECT SUM([OtherChargeAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND [OperationNo] = @No),0) [GrossSales]	 " +
                "		  ,[CashCount], [BankDeposit]" +
                "        FROM [dbo].[POSMCOperation]" +
                "        WHERE [No] = @No" +
                "       ELSE" +
                "    SELECT [No], [Shift], [OpenedDate], [OpenedBy], [ClosedDate], [ClosedBy], [CashReceived], ([Sales] + [ServiceCharge] + [OtherCharges]) [GrossSales], " +
                "   [CashCount], [BankDeposit]" +
                "        FROM [dbo].[POSMCOperation]" +
                "        WHERE [No] = @No";
        }

        public static string GetTransactionsLastTransactionList(string no)
        {
            return "SELECT [JONo],[AmountDue],[ClientName],[Status],[CancelBy]" +
                "       FROM(SELECT [J].[No][JONo], ISNULL(SUM([JOD].[AmountDue]), 0)[AmountDue],[J].[ClientName]" +
                "				   ,'UNCOLLECTED' [Status],[J].[CancelBy],[J].[OperationNo]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(SELECT [JONo], SUM([Price])[AmountDue]" +
                "               FROM [dbo].[POSMCJobOrderDetails]" +
                "                      WHERE [DeletedBy] IS NULL" +
                "           GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE(NOT[J].[No] IN (SELECT [ReferenceID] FROM [dbo].[POSMCTransactionReceipt]))" +
                "		   GROUP BY [J].[ClientName],[J].[No],[J].[CancelBy],[J].[OperationNo]" +
                "        UNION" +
                "   SELECT [ReferenceID] [JONo],[AmountDue],[ReceivedFrom] [ClientName], 'PAID' [Status],[CancelBy],[OperationNo]" +
                "        FROM [dbo].[POSMCTransactionReceipt]) [JO]" +
                "        WHERE [JO].[OperationNo] = '"+no+"'" +
                "ORDER BY [JONo]	";
        }

        public static string GetTransactionsPrevShift(string transactionNo)
        {
            return "SELECT [No],[Shift],[OpenedDate],[OpenedBy],[ClosedDate],[ClosedBy],[CashReceived],([Sales] + [ServiceCharge] + [OtherCharges]) [GrossSales]" +
                "		  ,[CashCount],[BankDeposit]" +
                "        FROM [dbo].[POSMCOperation]" +
                "        WHERE [No] = (SELECT MAX([No]) FROM [dbo].[POSMCOperation] WHERE [No] < '"+ transactionNo + "')";
        }

        public static string GetTransactionsPrevTransactionList(string transactionNo)
        {
            return "SELECT [JONo],[AmountDue],[ClientName],[Status],[CancelBy]" +
                "       FROM(SELECT [J].[No][JONo], ISNULL(SUM([JOD].[AmountDue]), 0)[AmountDue],[J].[ClientName],'UNCOLLECTED' [Status],[J].[CancelBy],[J].[OperationNo]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(SELECT [JONo], SUM([Price])[AmountDue]" +
                "               FROM [dbo].[POSMCJobOrderDetails]" +
                "                      WHERE [DeletedBy] IS NULL" +
                "           GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE(NOT[J].[No] IN (SELECT [ReferenceID] FROM [dbo].[POSMCTransactionReceipt]))" +
                "		   GROUP BY [J].[ClientName],[J].[No],[J].[CancelBy],[J].[OperationNo]" +
                "        UNION " +
                "   SELECT [ReferenceID] [JONo],[AmountDue],[ReceivedFrom] [ClientName], 'PAID' [Status],[CancelBy],[OperationNo]" +
                "        FROM [dbo].[POSMCTransactionReceipt]) [JO]" +
                "        WHERE [JO].[OperationNo] = (SELECT MAX([No]) FROM [dbo].[POSMCOperation] WHERE [No] < '"+ transactionNo + "')" +
                "	ORDER BY [JONo]	";
        }

        public static string GetTransactionsNextShift(string transactionNo)
        {
            return  "IF('"+transactionNo+"' = (SELECT MAX([No]) FROM [dbo].[POSMCOperation] WHERE [ClosedBy] IS NULL))" +
                "        SELECT [No],[Shift],[OpenedDate],[OpenedBy],[ClosedDate],[ClosedBy]" +
                "		  ,((ISNULL((SELECT SUM([CashAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND[OperationNo] = '"+transactionNo+"'),0) + ISNULL((SELECT SUM([OpeningAmount]) FROM [dbo].[POSMCOperation] WHERE [No] = '"+transactionNo+"'),0) + ISNULL((SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayIns] WHERE [OperationNo] = '"+transactionNo+"'),0)) - ISNULL((SELECT SUM([Amount]) FROM [dbo].[POSMCOperationPayOuts] WHERE [OperationNo] = '"+transactionNo+"'),0)) [CashReceived]" +
                "		  ,ISNULL((SELECT SUM([TotalAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND [OperationNo] = '"+transactionNo+"'),0) + ISNULL((SELECT SUM([ServiceChargeAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND [OperationNo] = '"+transactionNo+"'),0) + ISNULL((SELECT SUM([OtherChargeAmount]) FROM [dbo].[POSMCTransactionReceipt] WHERE [CancelBy] IS NULL AND [OperationNo] = '"+transactionNo+"'),0) [GrossSales]	 " +
                "		  ,[CashCount],[BankDeposit]" +
                "        FROM [dbo].[POSMCOperation]" +
                "        WHERE [No] = '"+transactionNo+"'" +
                "       ELSE" +
                "    SELECT [No],[Shift],[OpenedDate],[OpenedBy],[ClosedDate],[ClosedBy],[CashReceived],([Sales] + [ServiceCharge] + [OtherCharges]) [GrossSales],[CashCount],[BankDeposit]" +
                "        FROM [dbo].[POSMCOperation]" +
                "        WHERE [No] = (SELECT MIN([No]) FROM [dbo].[POSMCOperation] WHERE [No] > '"+transactionNo+"')";
        }

        public static string GetTransactionsNextTransactionList(string transactionNo)
        {
            return  "SELECT [JONo],[AmountDue],[ClientName],[Status],[CancelBy]" +
                "       FROM(SELECT [J].[No][JONo], ISNULL(SUM([JOD].[AmountDue]), 0)[AmountDue],[J].[ClientName],'UNCOLLECTED' [Status],[J].[CancelBy],[J].[OperationNo]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(SELECT [JONo], SUM([Price])[AmountDue]" +
                "               FROM [dbo].[POSMCJobOrderDetails]" +
                "                      WHERE [DeletedBy] IS NULL" +
                "           GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE(NOT[J].[No] IN (SELECT [ReferenceID] FROM [dbo].[POSMCTransactionReceipt]))" +
                "		   GROUP BY [J].[ClientName],[J].[No],[J].[CancelBy],[J].[OperationNo]" +
                "        UNION" +
                "       SELECT [ReferenceID] [JONo],[AmountDue],[ReceivedFrom] [ClientName], 'PAID' [Status],[CancelBy],[OperationNo]" +
                "        FROM [dbo].[POSMCTransactionReceipt]) [JO]" +
                "        WHERE [JO].[OperationNo] = (SELECT MIN([No]) FROM [dbo].[POSMCOperation] WHERE [No] > '"+transactionNo+"')" +
                "	ORDER BY [JONo]	";
        }

        /// <summary>
        /// Customers
        /// </summary>
        public static string GetCustomerPremium(int searchType, string searchKey)
        {
            string topKey = "";
            if (searchType == _Customers_Get_Top20)
                topKey = "TOP 20";

            string searchSubSQL = "";
            if (searchType == _Customers_Get_Search && searchKey != "" && searchKey != Global.EMPTY_STRING)
                searchSubSQL = "AND [LastName] LIKE '"+ searchKey + "' + '%'" +
                    "        OR" +
                    "        isnull([PremiumMember], 0) = 1" +
                    "        AND [FirstName] LIKE '" + searchKey + "' +'%'";


            return "SELECT "+topKey+" [C].[ClientID],[LastName],[FirstName],[MiddleName],DATEDIFF(day, [O].[OrderDate], getdate()) [Days],ISNULL([JO].[Amount], 0) [Amount]" +
                "        FROM(" +
                "    SELECT [ClientID], [LastName], [FirstName], [MiddleName], [PremiumMember]" +
                "        FROM [dbo].[POSMCClient]) [C]" +
                "        LEFT JOIN(SELECT SUM([JOD].[Amount]) [Amount],[J].[ClientID]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(SELECT [JONo], SUM([Price])[Amount]" +
                "           FROM [dbo].[POSMCJobOrderDetails]" +
                "            WHERE [DeletedBy] is null" +
                "       GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE [J].[CancelBy] is null" +
                "		AND(NOT[J].[No] IN (SELECT [ReferenceID]" +
                "        FROM [dbo].[POSMCTransactionReceipt]))" +
                "       GROUP BY [J].[ClientID],[J].[CancelBy]) [JO] ON[JO].[ClientID] = [C].[ClientID]" +
                "        LEFT JOIN(SELECT MAX([OrderDate])[OrderDate], [C].[ClientID]" +
                "            FROM [dbo].[POSMCClient] [C]" +
                "        LEFT JOIN [dbo].[POSMCJobOrder] [J]" +
                "                ON [J].[ClientID] = [C].[ClientID]" +
                "       GROUP BY [C].[ClientID]) [O] ON[O].[ClientID] = [C].[ClientID]" +
                "        WHERE isnull([PremiumMember], 0) = 1" + searchSubSQL +
                "       GROUP BY [C].[ClientID],[LastName],[FirstName],[MiddleName],[JO].[Amount],[O].[OrderDate]" +
                "        ORDER BY [O].[OrderDate]";
        }

        public static string GetCustomerRegular(int searchType, string searchKey)
        {
            string topKey = "";
            if (searchType == _Customers_Get_Top20)
                topKey = "TOP 20";

            string searchSubSQL = "";
            if (searchType == _Customers_Get_Search && searchKey != "" && searchKey != Global.EMPTY_STRING)
                searchSubSQL = "AND [LastName] LIKE '" + searchKey + "' + '%'" +
                    "        OR" +
                    "        isnull([PremiumMember], 0) = 0" +
                    "        AND [FirstName] LIKE '" + searchKey + "' +'%'";

            return "SELECT " + topKey + " [C].[ClientID],[LastName],[FirstName],[MiddleName],DATEDIFF(day, [O].[OrderDate], getdate()) [Days],ISNULL([JO].[Amount], 0) [Amount]" +
                "        FROM(" +
                "    SELECT [ClientID], [LastName], [FirstName], [MiddleName], [PremiumMember]" +
                "        FROM [dbo].[POSMCClient]) [C]" +
                "        LEFT JOIN(SELECT SUM([JOD].[Amount]) [Amount],[J].[ClientID]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(" +
                "           SELECT [JONo], SUM([Price])[Amount]" +
                "           FROM [dbo].[POSMCJobOrderDetails]" +
                "            WHERE [DeletedBy] is null" +
                "       GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE [J].[CancelBy] is null" +
                "		AND(NOT[J].[No] IN (SELECT [ReferenceID]" +
                "           FROM [dbo].[POSMCTransactionReceipt]))" +
                "       GROUP BY [J].[ClientID],[J].[CancelBy]) [JO] ON[JO].[ClientID] = [C].[ClientID]" +
                "        LEFT JOIN(SELECT MAX([OrderDate])[OrderDate], [C].[ClientID]" +
                "            FROM [dbo].[POSMCClient] [C]" +
                "        LEFT JOIN [dbo].[POSMCJobOrder] [J]" +
                "                ON [J].[ClientID] = [C].[ClientID]" +
                "      GROUP BY [C].[ClientID]) [O] ON[O].[ClientID] = [C].[ClientID]" +
                "        WHERE isnull([PremiumMember], 0) = 0" + searchSubSQL +
                "      GROUP BY [C].[ClientID],[LastName],[FirstName],[MiddleName],[JO].[Amount],[O].[OrderDate]" +
                "        ORDER BY [O].[OrderDate]";
        }

        public static string GetCustomerDetailSelected(string clientID)
        {
            return "    SELECT [C].[ClientID],[LastName],[FirstName],[MiddleName],[Address],[Mobile],[Email],[JOD].[Amount] [Balance]" +
                "        FROM [dbo].[POSMCClient] [C]" +
                "        LEFT JOIN(SELECT SUM([JOD].[Amount]) [Amount],[J].[ClientID]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(" +
                "            SELECT [JONo], SUM([Price])[Amount]" +
                "              FROM [dbo].[POSMCJobOrderDetails]" +
                "                   WHERE [DeletedBy] is null" +
                "          GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE [J].[CancelBy] is null" +
                "		     AND(NOT[J].[No] IN (SELECT [ReferenceID] FROM [dbo].[POSMCTransactionReceipt]))" +
                "		GROUP BY [ClientID]) [JOD] ON[JOD].[ClientID] = [C].[ClientID]" +
                "        WHERE [C].[ClientID] = " + clientID;
        }

        public static string GetCustomerDetailSelectedTransaction(string clientID)
        {
            return "SELECT [JO].[OrderDate],[JO].[No] [JONo],[JOD].[Price],[JO].[CancelBy]" +
                "        FROM(" +
                "   SELECT [ClientID]" +
                "     FROM [dbo].[POSMCClient]" +
                "            WHERE [ClientID] = " + clientID + ") [C]" +
                "        LEFT JOIN(" +
                "    SELECT [No], [OrderDate], [ClientID], [CancelBy]" +
                "               FROM [dbo].[POSMCJobOrder]) [JO] ON[JO].[ClientID] = [C].[ClientID]" +
                "        LEFT JOIN(" +
                "           SELECT [JONo], SUM([Price])[Price]" +
                "       FROM [dbo].[POSMCJobOrderDetails]" +
                "              WHERE [DeletedBy] IS NULL" +
                "       GROUP BY [JONo]) [JOD] ON[JOD].[JONo] = [JO].[No]" +
                "        WHERE [JO].[No] IS NOT NULL" +
                "       ORDER BY [OrderDate] ASC";
        }

        public static string GetCustomerDetailPrev(string currentClientID)
        {
            return "    SELECT [C].[ClientID],[LastName],[FirstName],[MiddleName],[Address],[Mobile],[Email],[JOD].[Amount] [Balance]" +
                "        FROM [dbo].[POSMCClient] [C]" +
                "        LEFT JOIN(SELECT SUM([JOD].[Amount]) [Amount],[J].[ClientID]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(" +
                "            SELECT [JONo], SUM([Price])[Amount]" +
                "              FROM [dbo].[POSMCJobOrderDetails]" +
                "                   WHERE [DeletedBy] is null" +
                "          GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE [J].[CancelBy] is null" +
                "		     AND(NOT[J].[No] IN (SELECT [ReferenceID] FROM [dbo].[POSMCTransactionReceipt]))" +
                "		GROUP BY [ClientID]) [JOD] ON[JOD].[ClientID] = [C].[ClientID]" +
                "        WHERE [C].[ClientID] = (SELECT MAX([ClientID]) FROM [dbo].[POSMCClient] WHERE [ClientID] < " + currentClientID +")";
        }

        public static string GetCustomerDetailPrevTransaction(string currentClientID)
        {
            return "SELECT [JO].[OrderDate],[JO].[No] [JONo],[JOD].[Price],[JO].[CancelBy]" +
                "        FROM(" +
                "   SELECT [ClientID]" +
                "     FROM [dbo].[POSMCClient]" +
                "             WHERE [ClientID] = (SELECT MAX([ClientID]) FROM [dbo].[POSMCClient] WHERE [ClientID] < "+ currentClientID + ")) [C]" +
                "        LEFT JOIN(" +
                "             SELECT [No], [OrderDate], [ClientID], [CancelBy]" +
                "               FROM [dbo].[POSMCJobOrder]) [JO] ON[JO].[ClientID] = [C].[ClientID]" +
                "        LEFT JOIN(SELECT [JONo], SUM([Price]) [Price]" +
                "       FROM [dbo].[POSMCJobOrderDetails]" +
                "              WHERE [DeletedBy] IS NULL" +
                "       GROUP BY [JONo]) [JOD] ON[JOD].[JONo] = [JO].[No]" +
                "        WHERE [JO].[No] IS NOT NULL" +
                "       ORDER BY [OrderDate] ASC";
        }

        public static string GetCustomerDetailNext(string currentClientID)
        {
            return "    SELECT [C].[ClientID],[LastName],[FirstName],[MiddleName],[Address],[Mobile],[Email],[JOD].[Amount] [Balance]" +
                "        FROM [dbo].[POSMCClient] [C]" +
                "        LEFT JOIN(SELECT SUM([JOD].[Amount]) [Amount],[J].[ClientID]" +
                "        FROM [dbo].[POSMCJobOrder] [J]" +
                "        LEFT JOIN(" +
                "            SELECT [JONo], SUM([Price])[Amount]" +
                "              FROM [dbo].[POSMCJobOrderDetails]" +
                "                   WHERE [DeletedBy] is null" +
                "          GROUP BY [JONo]) [JOD]" +
                "        ON[JOD].[JONo] = [J].[No]" +
                "        WHERE [J].[CancelBy] is null" +
                "		     AND(NOT[J].[No] IN (SELECT [ReferenceID] FROM [dbo].[POSMCTransactionReceipt]))" +
                "		GROUP BY [ClientID]) [JOD] ON[JOD].[ClientID] = [C].[ClientID]" +
                "        WHERE [C].[ClientID] = (SELECT MIN([ClientID]) FROM [dbo].[POSMCClient] WHERE [ClientID] > "+ currentClientID + ")";
        }

        public static string GetCustomerDetailNextTransaction(string currentClientID)
        {
            return "SELECT [JO].[OrderDate],[JO].[No] [JONo],[JOD].[Price],[JO].[CancelBy]" +
                "        FROM(" +
                "   SELECT [ClientID]" +
                "     FROM [dbo].[POSMCClient]" +
                "             WHERE [ClientID] = (SELECT MIN([ClientID]) FROM [dbo].[POSMCClient] WHERE [ClientID] > " + currentClientID + ")) [C]" +
                "        LEFT JOIN(" +
                "             SELECT [No], [OrderDate], [ClientID], [CancelBy]" +
                "               FROM [dbo].[POSMCJobOrder]) [JO] ON[JO].[ClientID] = [C].[ClientID]" +
                "        LEFT JOIN(SELECT [JONo], SUM([Price])[Price]" +
                "       FROM [dbo].[POSMCJobOrderDetails]" +
                "              WHERE [DeletedBy] IS NULL" +
                "       GROUP BY [JONo]) [JOD] ON[JOD].[JONo] = [JO].[No]" +
                "        WHERE [JO].[No] IS NOT NULL" +
                "       ORDER BY [OrderDate] ASC";
        }

        /// <summary>
        /// Staffs
        /// </summary>
        public static string GetStaffList()
        {
            return "SELECT [U].[UserName],[Role],[Shift],[Date],[TimeIn],[TimeOut]" +
                "        FROM [dbo].[POSMCUser] [U]" +
                "        LEFT JOIN" +
                "       (SELECT isnull([TIN].[UserName], [TOUT].[UserName]) [UserName],isnull([TIN].[Shift], [TOUT].[Shift]) [Shift]" +
                "               ,isnull([TIN].[Date], [TOUT].[Date]) [Date],[TimeIn],[TimeOut]" +
                "        FROM" +
                "           (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeIn]" +
                "           FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "           WHERE [Type] = 'TIME-IN' and[UserName] <> 'ADMIN'" +
                "           AND cast([AttendanceDate] as date ) = cast((SELECT MAX([OpenedDate]) FROM [dbo].[POSMCOperation]) as date)" +
                "           GROUP BY [UserName], [Type], [Shift], cast([AttendanceDate] as date )) [TIN]" +
                "           FULL OUTER JOIN" +
                "           (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeOut]" +
                "           FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "           WHERE [Type] = 'TIME-OUT' and[UserName] <> 'ADMIN'" +
                "           AND cast([AttendanceDate] as date ) = cast((SELECT MAX([OpenedDate]) FROM [dbo].[POSMCOperation]) as date)" +
                "           GROUP BY [UserName], [Type], [Shift], cast([AttendanceDate] as date )) [TOUT]" +
                "        ON[TIN].[UserName] = [TOUT].[UserName]" +
                "        AND[TIN].[Shift] = [TOUT].[Shift]" +
                "        AND[TIN].[Date] = [TOUT].[Date]) [TIME]" +
                "        ON[U].UserName = [TIME].UserName" +
                "       WHERE [Disabled] is null and[Role] <> 'ADMIN'" +
                "   ORDER BY [TimeOut] desc,[Date],[Shift]";
        }

        public static string GetStaffDetailProfile(string data)
        {
            string[] dataArray = data.Split('_');
            string sql = "";

            if (dataArray[1] == Global.EMPTY_STRING)
                dataArray[1] = DateTime.Now.ToString("yyyy-MM-dd");

            return "SELECT [U].[UserName],[U].[Role],[LastName],[FirstName],[Email],[Shift],[Date],[TimeIn],[TimeOut]" +
                "        FROM [dbo].[POSMCUser] [U]" +
                "        LEFT JOIN" +
                "       (SELECT isnull([TIN].[UserName], [TOUT].[UserName]) [UserName],isnull([TIN].[Shift], [TOUT].[Shift]) [Shift]" +
                "               ,isnull([TIN].[Date], [TOUT].[Date]) [Date],[TimeIn],[TimeOut]" +
                "        FROM" +
                "       (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeIn]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-IN' and[UserName] <> 'ADMIN'" +
                "       GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TIN]" +
                "        FULL OUTER JOIN" +
                "        (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeOut]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-OUT' and[UserName] <> 'ADMIN'" +
                "       GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TOUT]" +
                "        ON[TIN].[UserName] = [TOUT].[UserName]" +
                "        AND[TIN].[Shift] = [TOUT].[Shift]" +
                "        AND[TIN].[Date] = [TOUT].[Date]) [TIME]" +
                "        ON[U].UserName = [TIME].UserName" +
                "       LEFT JOIN dbo.[User]" +
                "       ON [User].UserName = [U].UserName" +
                "       LEFT JOIN dbo.Employee[E]" +
                "       ON [User].EmployeeID = [E].ID" +
                "       WHERE [U].[UserName] = '" + dataArray[0] + "' and[Date] between dateadd(day,-15, cast('" + dataArray[1] + "' as date)) and cast('" + dataArray[1] + "' as date)" +
                "   ORDER BY [Date],[Shift]";
        }

        public static string GetStaffDetailProfilePrev(string data)
        {
            string[] dataArray = data.Split('_');
            string sql = "";

            if (dataArray[1] == Global.EMPTY_STRING)
                dataArray[1] = DateTime.Now.ToString("yyyy-MM-dd");

            return "SELECT [U].[UserName],[U].[Role],[LastName],[FirstName],[Email],[Shift],[Date],[TimeIn],[TimeOut]" +
                "        FROM [dbo].[POSMCUser] [U]" +
                "        LEFT JOIN" +
                "       (SELECT isnull([TIN].[UserName], [TOUT].[UserName]) [UserName],isnull([TIN].[Shift], [TOUT].[Shift]) [Shift]" +
                "               ,isnull([TIN].[Date], [TOUT].[Date]) [Date],[TimeIn],[TimeOut]" +
                "        FROM" +
                "       (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeIn]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-IN' and[UserName] <> 'ADMIN'" +
                "       GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TIN]" +
                "        FULL OUTER JOIN" +
                "        (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeOut]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-OUT' and[UserName] <> 'ADMIN'" +
                "       GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TOUT]" +
                "        ON[TIN].[UserName] = [TOUT].[UserName]" +
                "        AND[TIN].[Shift] = [TOUT].[Shift]" +
                "        AND[TIN].[Date] = [TOUT].[Date]) [TIME]" +
                "        ON[U].UserName = [TIME].UserName" +
                "       LEFT JOIN dbo.[User]" +
                "       ON [User].UserName = [U].UserName" +
                "       LEFT JOIN dbo.Employee[E]" +
                "       ON [User].EmployeeID = [E].ID" +
                "       WHERE [U].[UserName] = '" + dataArray[0] + "' and[Date] between dateadd(day,-15, cast('" + dataArray[1] + "' as date)) and cast('" + dataArray[1] + "' as date)" +
                "   ORDER BY [Date],[Shift]";
        }

        public static string GetStaffDetailProfileNext(string data)
        {
            string[] dataArray = data.Split('_');
            string sql = "";

            if (dataArray[1] == Global.EMPTY_STRING)
                dataArray[1] = DateTime.Now.ToString("yyyy-MM-dd");

            return "SELECT [U].[UserName],[U].[Role],[LastName],[FirstName],[Email],[Shift],[Date],[TimeIn],[TimeOut]" +
                "        FROM [dbo].[POSMCUser] [U]" +
                "        LEFT JOIN" +
                "       (SELECT isnull([TIN].[UserName], [TOUT].[UserName]) [UserName],isnull([TIN].[Shift], [TOUT].[Shift]) [Shift]" +
                "               ,isnull([TIN].[Date], [TOUT].[Date]) [Date],[TimeIn],[TimeOut]" +
                "        FROM" +
                "       (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeIn]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-IN' and[UserName] <> 'ADMIN'" +
                "       GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TIN]" +
                "        FULL OUTER JOIN" +
                "        (SELECT [UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeOut]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-OUT' and[UserName] <> 'ADMIN'" +
                "       GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TOUT]" +
                "        ON[TIN].[UserName] = [TOUT].[UserName]" +
                "        AND[TIN].[Shift] = [TOUT].[Shift]" +
                "        AND[TIN].[Date] = [TOUT].[Date]) [TIME]" +
                "        ON[U].UserName = [TIME].UserName" +
                "       LEFT JOIN dbo.[User]" +
                "       ON [User].UserName = [U].UserName" +
                "       LEFT JOIN dbo.Employee[E]" +
                "       ON [User].EmployeeID = [E].ID" +
                "       WHERE [U].[UserName] = '" + dataArray[0] + "' and[Date] between dateadd(day,-15, cast('" + dataArray[1] + "' as date)) and cast('" + dataArray[1] + "' as date)" +
                "   ORDER BY [Date],[Shift]";
        }

        /// <summary>
        /// Offers
        /// </summary>
        public static string GetOfferCategory()
        {
            return "SELECT [Category] FROM [dbo].[POSMCOfferedCategory]";
        }

        public static string GetOfferAvailable()
        {
            return "    SELECT [O].[Code],[Category],IIF(COUNT([OP].[No]) <> 0 AND COUNT([OS].[No]) <> 0, 'Package', IIF(COUNT([OP].[No]) <> 0 AND COUNT([OS].[No]) = 0, 'Item', IIF(COUNT([OP].[No]) = 0 AND COUNT([OS].[No]) <> 0, 'Service', 'Others'))) [Type]" +
                "		  ,[Name],[Price],ISNULL([Costing], 0) [Costing],[VATType]" +
                "        FROM [dbo].[POSMCOffered] [O]" +
                "        LEFT JOIN [dbo].[POSMCOfferedProducts] [OP]" +
                "        ON[O].[Code] = [OP].[OfferedCode]" +
                "        LEFT JOIN [dbo].[POSMCOfferedSessions] [OS]" +
                "        ON[O].[Code] = [OS].[OfferedCode]" +
                "        WHERE [NotAvailable] = 0 OR [NotAvailable] IS NULL" +
                "   GROUP BY [O].[Code],[Category],[Name],[Price],[VATType],ISNULL([Costing], 0)";
        }

        public static string GetOfferDisable()
        {
            return "    SELECT [O].[Code],[Category],IIF(COUNT([OP].[No]) <> 0 AND COUNT([OS].[No]) <> 0, 'Package', IIF(COUNT([OP].[No]) <> 0 AND COUNT([OS].[No]) = 0, 'Item', IIF(COUNT([OP].[No]) = 0 AND COUNT([OS].[No]) <> 0, 'Service', 'Others'))) [Type]" +
                "		  ,[Name],[Price],ISNULL([Costing], 0) [Costing],[VATType]" +
                "        FROM [dbo].[POSMCOffered] [O]" +
                "        LEFT JOIN [dbo].[POSMCOfferedProducts] [OP]" +
                "        ON[O].[Code] = [OP].[OfferedCode]" +
                "        LEFT JOIN [dbo].[POSMCOfferedSessions] [OS]" +
                "        ON[O].[Code] = [OS].[OfferedCode]" +
                "        WHERE [NotAvailable] = 1" +
                "   GROUP BY [O].[Code],[Category],[Name],[Price],[VATType],ISNULL([Costing], 0)";
        }

        public static string GetOfferDetail(string code)
        {
            return "SELECT [Code],[Category],[Name],[Price],[VATType],[Preparation]" +
                "   FROM [dbo].[POSMCOffered]" +
                "   WHERE [Code] = '" + code + "'";
        }

        public static string GetOfferDetailContent(string code)
        {
            return "SELECT [No]" +
                "   ,cast([Count] as varchar) + ' ' + [Description] [Description]" +
                "   ,[Duration] [Count]" +
                "   ,'Min' [Unit]" +
                "        FROM [POSLaundry].[dbo].[POSMCOfferedSessions]" +
                "        WHERE OfferedCode = '"+code+"'" +
                "   UNION" +
                "   SELECT [No]  " +
                "   ,[Item]" +
                "   ,[Quantity]" +
                "   ,[Unit]" +
                "   FROM [POSLaundry].[dbo].[POSMCOfferedProducts]" +
                "   WHERE OfferedCode = '" + code + "'";
        }

        public static string SaveOfferDetail(string data)
        {
            string[] dataArray = data.Split('_');
            return "UPDATE [dbo].[POSMCOffered]" +
                "   SET[Price] = '" + dataArray[0] + "'" +
                " WHERE [Code] = '" + dataArray[1] + "'";
        }

        public static string GetReplenishGetCategory()
        {
            return "SELECT [Category] FROM [dbo].[POSMCItemCategory]";
        }

        public static string GetReplenishGetCategoryDetail(string itemCode)
        {
            return "SELECT [Item],[Unit],[Code] FROM [dbo].[POSMCItem] WHERE([Disabled] = 0 OR[Disabled] IS NULL) AND[Category] = '" + itemCode + "'";
        }

        public static string GetProcedureSQLGetNumeric(bool isCreate)
        {
            string sql = "";

            if (isCreate)
                sql = "CREATE FUNCTION [dbo].[GetNumeric] ";
            else
                sql = "ALTER FUNCTION [dbo].[GetNumeric] ";

            sql += "	(@strAlphaNumeric VARCHAR(15)) " +
                "    RETURNS VARCHAR(15) " +
                "AS " +
                "BEGIN " +
                "DECLARE @intAlpha INT " +
                "SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric) " +
                "    BEGIN " +
                "    WHILE @intAlpha > 0 " +
                "        BEGIN " +
                "        SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '') " +
                "        SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric) " +
                "        END " +
                "   END " +
                "    RETURN ISNULL(@strAlphaNumeric,0) " +
                "END";

            return sql;
        }

        public static string GetProcedureSQLReplenish(bool isCreate)
        {
            string sql = "";

            if (isCreate)
                sql = "CREATE PROCEDURE [dbo].[POSMCItemReplenish_Insert] ";
            else
                sql = "ALTER PROCEDURE [dbo].[POSMCItemReplenish_Insert] ";

            sql += "		         @ReplenishBy varchar(50),@NewRepNo varchar(10) OUTPUT" +
                "   AS" +
                "   BEGIN" +
                "    SET NOCOUNT ON;" +
                "            DECLARE @PreFix VARCHAR(2) = 'RN';" +
                "            DECLARE @MaxNo int;" +
                "            DECLARE @GetNumeric int" +
                "    SELECT @GetNumeric = [dbo].[GetNumeric]([No]) FROM [dbo].[POSMCItemReplenish]" +
                "    SELECT @MaxNo = ISNULL(MAX(@GetNumeric), 0) + 1 FROM [dbo].[POSMCItemReplenish]" +
                "    SELECT @NewRepNo = @PreFix + RIGHT('0000000' + CAST(@MaxNo AS VARCHAR(8)), 8)" +
                "    INSERT INTO[dbo].[POSMCItemReplenish]" +
                "        ([No],[Type],[Reference],[ReplenishDate],[ReplenishBy],[EntryDate])" +
                "   VALUES" +
                "       (@NewRepNo,'RECEIVED','DIRECT-APP', GETDATE(), @ReplenishBy, GETDATE())" +
                "   END";

            return sql;
        }

        public static string GetProcedureSQLReplenishNoExpiredDetail(bool isCreate)
        {
            string sql = "";

            if (isCreate)
                sql = "CREATE PROCEDURE [dbo].[POSMCItemReplenishNoExpiredDetails_Insert] ";
            else
                sql = "ALTER PROCEDURE [dbo].[POSMCItemReplenishNoExpiredDetails_Insert] ";

            sql += "    @ReplenishNo varchar(10),@ItemCode varchar(15),@Quantity float, @Unit varchar(12)" +
                "   AS" +
                "   BEGIN" +
                "   SET NOCOUNT ON;" +
                "   INSERT INTO[dbo].[POSMCItemReplenishDetails]" +
                "       ([No],[ReplenishNo],[ItemCode],[Quantity],[Unit],[NoExpiry])" +
                "   VALUES" +
                "       ((SELECT ISNULL(MAX([No]), 0)+1 FROM [dbo].[POSMCItemReplenishDetails])" +
                "			   ,@ReplenishNo,@ItemCode,@Quantity,@Unit,1)" +
                "   END";

            return sql;
        }

        public static string GetProcedureSQLReplenishWithExpiredDetail(bool isCreate)
        {
            string sql = "";

            if (isCreate)
                sql = "CREATE PROCEDURE [dbo].[POSMCItemReplenishWithExpiredDetails_Insert] ";
            else
                sql = "ALTER PROCEDURE [dbo].[POSMCItemReplenishWithExpiredDetails_Insert] ";

            sql += "    @ReplenishNo varchar(10),@ItemCode varchar(15),@Quantity float, @Unit varchar(12), @Expiry smalldatetime" +
                "   AS" +
                "   BEGIN" +
                "   SET NOCOUNT ON;" +
                "   INSERT INTO[dbo].[POSMCItemReplenishDetails]" +
                "       ([No],[ReplenishNo],[ItemCode],[Quantity],[Unit],[NoExpiry],[Expiry])" +
                "   VALUES" +
                "       ((SELECT ISNULL(MAX([No]), 0)+1 FROM [dbo].[POSMCItemReplenishDetails])" +
                "			   ,@ReplenishNo,@ItemCode,@Quantity,@Unit,0,@Expiry)" +
                "   END";

            return sql;
        }

        /// <summary>
        /// Reports
        /// </summary>
        /* Report Sales */
        public static string GetReportSales(string data)
        {
            string[] dataArray = data.Split('_');
            string sql = "";

            if (dataArray[1] == Global.EMPTY_STRING) 
                dataArray[1] = DateTime.Now.ToString("yyyy-MM-dd");

            switch (dataArray[0])
            {
                case _Report_Type_Hourly:
                    sql = GetReportSalesHourly(dataArray[1]);
                    break;
                case _Report_Type_Daily:
                    sql = GetReportSalesDaily(dataArray[1]);
                    break;
                case _Report_Type_Weekly:
                    sql = GetReportSalesWeekly(dataArray[1]);
                    break;
                case _Report_Type_Monthly:
                    sql = GetReportSalesMonthly(dataArray[1]);
                    break;
                case _Report_Type_Yearly:
                    sql = GetReportSalesYearly();
                    break;
            }

            return sql;
        }

        public static string GetReportSalesHourly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "   SELECT" +
                "      CAST([TRDate] AS DATE) [TRDate]" +
                "	  ,DATENAME(dw, [TRDate]) [Day]" +
                "	  ,DATEPART(hh, [TRDate]) [Time]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,-6, '" + lateDate + "') AND '" + lateDate + "'" +
                "  GROUP BY" +
                "  CAST([TRDate] AS DATE)" +
                "  ,DATENAME(dw, [TRDate])" +
                "  ,DATEPART(hh, [TRDate])" +
                "  ORDER BY DATEPART(hh,[TRDate]), TRDate";

            return sql;
        }

        public static string GetReportSalesDaily(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate]" +
                " ,DATENAME(month, [TRDate]) [Month]" +
                " ,DATEPART(day, [TRDate]) [dayNo]" +
                "	   ,DATENAME(week, [TRDate]) [Week]" +
                "	  ,DATENAME(dw, [TRDate]) [day]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,1, DATEADD(month, -3, '" + lateDate + "')) AND '" + lateDate + "'" +
                "  GROUP BY" +
                "  CAST([TRDate] AS DATE)" +
                "  ,DATENAME(month, [TRDate])" +
                "  ,DATEPART(day, [TRDate])" +
                " ,DATENAME(dw, [TRDate])" +
                " ,DATENAME(week, [TRDate])" +
                "  ORDER BY TRDate";

            return sql;
        }

        public static string GetReportSalesWeekly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "     DATENAME(week,[TRDate])[Week], SUM([Amount]) [Amount]" +
                "        FROM" +
                "      [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] ON[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,1, DATEADD(month, -4, '" + lateDate + "')) AND '" + lateDate + "'" +
                "	GROUP BY" +
                "      DATENAME(week, [TRDate])" +
                " ORDER BY DATENAME(WEEK, [TRDate])";

            return sql;
        }

        public static string GetReportSalesMonthly(string lateDate)
        {
            string sql = "SET NOCOUNT ON;" +
                "    SELECT" +
                "      DATEPART(YEAR,[TRDate])[Year]" +
                "	  ,DATENAME(month,[TRDate])[Month]" +
                "	  ,DATEPART(month,[TRDate])[MonthNo]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,1, DATEADD(year, -1, '" + lateDate + "')) AND '" + lateDate + "'" +
                "  GROUP BY " +
                "      DATEPART(YEAR, [TRDate])" +
                "	  	  ,DATENAME(month, [TRDate])" +
                "	  ,DATEPART(month, [TRDate])" +
                "  ORDER BY DATEPART(month, [TRDate]) ";

            return sql;
        }

        public static string GetReportSalesYearly()
        {
            return "	SET NOCOUNT ON; " +
                "   SELECT" +
                "      DATEPART(YEAR,[TRDate])[Year]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "  GROUP BY " +
                "      DATEPART(YEAR, [TRDate])" +
                "  ORDER BY DATEPART(YEAR, [TRDate]) ";
        }

        /* Report Item Sold */
        public static string GetReportItemSold(string data)
        {
            string[] dataArray = data.Split('_');
            string sql = "";

            if (dataArray[1] == Global.EMPTY_STRING)
                dataArray[1] = DateTime.Now.ToString("yyyy-MM-dd");

            switch (dataArray[0])
            {
                case _Report_Type_Hourly:
                    sql = GetReportItemSoldHourly(dataArray[1]);
                    break;
                case _Report_Type_Daily:
                    sql = GetReportItemSoldDaily(dataArray[1]);
                    break;
                case _Report_Type_Weekly:
                    sql = GetReportItemSoldWeekly(dataArray[1]);
                    break;
                case _Report_Type_Monthly:
                    sql = GetReportItemSoldMonthly(dataArray[1]);
                    break;
                case _Report_Type_Yearly:
                    sql = GetReportItemSoldYearly();
                    break;
            }

            return sql;
        }

        public static string GetReportItemSoldHourly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      CAST([TRDate] AS DATE) [TRDate]" +
                "	  ,DATENAME(dw, [TRDate]) [Day]" +
                "	  ,DATEPART(hh, [TRDate]) [Time]" +
                "	  ,[Preparation]" +
                "	  ,sum([Qty]) [Qty]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCOffered] [PO]" +
                "        on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) = ('"+ lateDate+"' ) " +
                "  GROUP BY" +
                "  CAST([TRDate] AS DATE)" +
                "  ,DATENAME(dw, [TRDate])" +
                "  ,DATEPART(hh, [TRDate]) ,[Preparation]" +
                "        ORDER BY TRDate,[Preparation]";

            return sql;
        }

        public static string GetReportItemSoldDaily(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      CAST([TRDate] AS DATE) [TRDate]" +
                "	  ,DATENAME(dd, [TRDate]) [DayNo]" +
                "	  ,DATENAME(dw, [TRDate]) [Day]" +
                "	  ,[Preparation]" +
                "	  ,sum([Qty]) [Qty]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCOffered] [PO]" +
                "        on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) >= DATEADD(day, -6,'"+ lateDate+"' )" + " AND CAST([TRDate] AS DATE) <= '" + lateDate + "'" +
                "  GROUP BY" +
                "  CAST([TRDate] AS DATE)" +
                "  ,DATENAME(dd, [TRDate])" +
                "  ,DATENAME(dw, [TRDate])" +
                " ,[Preparation]" +
                "        ORDER BY TRDate,[Preparation]";

            return sql;
        }

        public static string GetReportItemSoldWeekly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      DATEPART(week,[TRDate])[WeekNo]" +
                "	  ,DATENAME(MONTH,[TRDate])[month]" +
                "	  ,[Preparation]" +
                "	  ,sum([Qty]) [Qty]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCOffered] [PO]" +
                "        on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) >=  DATEADD(week, -5,'"+lateDate+"')" + " AND CAST([TRDate] AS DATE) <= '" + lateDate + "'" + 
                "  GROUP BY" +
                "  DATEPART(week, [TRDate])" +
                "  ,DATENAME(month, [TRDate])" +
                " ,[Preparation]" +
                " ORDER BY [WeekNo],[Preparation]";

            return sql;
        }

        public static string GetReportItemSoldMonthly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      DATENAME(MONTH,[TRDate])[month]" +
                "	  ,[Preparation]" +
                "	  ,sum([Qty]) [Qty]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCOffered] [PO]" +
                "        on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) >=  DATEADD(month, -3,'"+ lateDate + "' )" + " AND CAST([TRDate] AS DATE) <= '" + lateDate + "'" +
                "  GROUP BY" +
                "  DATENAME(month, [TRDate])" +
                " ,[Preparation]" +
                "        ORDER BY [month],[Preparation]";

            return sql;
        }

        public static string GetReportItemSoldYearly()
        {
            return "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      DATENAME(year,[TRDate])[Year]" +
                "	  ,[Preparation]" +
                "	  ,sum([Qty]) [Qty]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCOffered] [PO]" +
                "        on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        GROUP BY" +
                "  DATENAME(year, [TRDate])" +
                " ,[Preparation]" +
                "        ORDER BY [Year],[Preparation]";
        }

        /* Report Consolidate */
        public static string GetReportConsolidate(string data)
        {
            string[] dataArray = data.Split('_');
            string sql = "";

            if (dataArray[1] == Global.EMPTY_STRING)
                dataArray[1] = DateTime.Now.ToString("yyyy-MM-dd");

            switch (dataArray[0])
            {
                case _Report_Type_Hourly:
                    sql = GetReportConsolidateHourly(dataArray[1]);
                    break;
                case _Report_Type_Daily:
                    sql = GetReportConsolidateDaily(dataArray[1]);
                    break;
                case _Report_Type_Weekly:
                    sql = GetReportConsolidateWeekly(dataArray[1]);
                    break;
                case _Report_Type_Monthly:
                    sql = GetReportConsolidateMonthly(dataArray[1]);
                    break;
                case _Report_Type_Yearly:
                    sql = GetReportConsolidateYearly(dataArray[1]);
                    break;
            }

            return sql;
        }

        public static string GetReportConsolidateHourly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      CAST([TRDate] AS DATE) [TRDate]" +
                "	  ,DATENAME(dw, [TRDate]) [Day]" +
                "	  ,DATEPART(hh, [TRDate]) [Time]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) = '" + lateDate + "'" +
                "   GROUP BY" +
                "   CAST([TRDate] AS DATE)" +
                "  ,DATENAME(dw, [TRDate])" +
                "  ,DATEPART(hh, [TRDate])" +
                "  ORDER BY TRDate";

            return sql;
        }

        public static string GetReportConsolidateDaily(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      CAST([TRDate] AS DATE) [TRDate]" +
                "	  ,DATENAME(month, [TRDate]) [Month]" +
                "	  ,DATEPART(day, [TRDate]) [day]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE DATEPART(month, [TRDate]) = DATEPART(month, '" + lateDate + "')" +
                "       AND DATEPART(year, [TRDate]) = DATEPART(year, '" + lateDate + "')" +
                "  GROUP BY" +
                "  CAST([TRDate] AS DATE)" +
                "  ,DATENAME(month, [TRDate])" +
                "  ,DATEPART(day, [TRDate])" +
                "  ORDER BY TRDate";

            return sql;
        }

        public static string GetReportConsolidateWeekly(string lateDate)
        {
            string sql = "SET NOCOUNT ON;" +
                "    SELECT" +
                "      DATEPART(YEAR,[TRDate])[Year]" +
                "	  ,DATENAME(month,[TRDate])[Month]" +
                "	  ,DATEPART(month,[TRDate])[MonthNo]" +
                "	  ,DATENAME(week,[TRDate])[Week]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE DATEPART(month, [TRDate]) = DATEPART(month, '" + lateDate + "')" +
                "       AND DATEPART(year, [TRDate]) = DATEPART(year, '" + lateDate + "')" +
                "  GROUP BY" +
                "      DATEPART(YEAR, [TRDate])" +
                "	  	  ,DATENAME(month, [TRDate])" +
                "	  ,DATEPART(month, [TRDate])" +
                "	  ,DATENAME(week, [TRDate])" +
                "  ORDER BY DATENAME(WEEK, [TRDate])";

            return sql;
        }

        public static string GetReportConsolidateMonthly(string lateDate)
        {
            string sql = "	SET NOCOUNT ON;" +
                "    SELECT" +
                "      DATEPART(YEAR,[TRDate])[Year]" +
                "	  ,DATENAME(month,[TRDate])[Month]" +
                "	  ,DATEPART(month,[TRDate])[MonthNo]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,1, DATEADD(year, -1, '" + lateDate + "')) AND '" + lateDate + "'" +
                "  GROUP BY" +
                "      DATEPART(YEAR, [TRDate])" +
                "	  	  ,DATENAME(month, [TRDate])" +
                "	  ,DATEPART(month, [TRDate])" +
                "  ORDER BY DATEPART(month, [TRDate]) ";

            return sql;
        }

        public static string GetReportConsolidateYearly(string lateDate)
        {
            return "SET NOCOUNT ON;" +
                "   SELECT" +
                "   DATEPART(YEAR,[TRDate])[Year],sum([Amount]) [Amount]" +
                "        FROM" +
                "   [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR]" +
                "        on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE DATEPART(year, [TRDate]) = DATEPART(year,'"+lateDate+"')" +
                "       GROUP BY" +
                "   DATEPART(YEAR, [TRDate])";
        }

        /// <summary>
        /// Notice
        /// </summary>
        public static string GetNoticeList()
        {
            return "SELECT [No],[NoticeDate],[Type],[Title],[Message],[Viewed],[Acted]" +
                "        FROM [dbo].[POSMCOperationNotices]" +
                "        WHERE [OperationNo] = (SELECT MAX(No) FROM POSMCOperation)  " +
                "           AND isnull(Hidden,0) = 0" +
                "           OR[OperationNo] IS NULL" +
                "           AND isnull(Hidden,0) = 0 ";
        }

        public static string UpdateNoticeViewed(string noticeNo)
        {
            return "UPDATE [dbo].[POSMCOperationNotices]" +
                "   SET [Viewed] = 1" +
                "   WHERE [No] = '" + noticeNo + "'";
        }

        public static string UpdateNoticeHidden(string noticeNo)
        {
            return "UPDATE [dbo].[POSMCOperationNotices]" +
                "   SET [Hidden] = 1" +
                "   WHERE [No] = '" + noticeNo + "'";
        }

        public static string UpdateNoticeActed(string noticeNo, int action)
        {
            return "UPDATE [dbo].[POSMCOperationNotices]" +
                "   SET [Acted] = 1, [Action] = " + action +
                "   WHERE [No] = '" + noticeNo + "'";
        }
        #endregion

        #region DataSet for Email
        public static void CreateNewDataSetProcedures()
        {
            // Other Procedures
            GetProcedureSQLOtherAppCustomerList();
            GetProcedureSQLOtherAppInventoryReport();
            GetProcedureSQLOtherAppLeastSoldItem();
            GetProcedureSQLOtherAppProductItemList();
            GetProcedureSQLOtherAppTopSoldItem();
            GetProcedureSQLOtherAppFinancialStatement();
            GetProcedureSQLOtherAppItemSoldBreakdown();
            GetProcedureSQLOtherAppMonthlySalesReport();
            GetProcedureSQLOtherAppPayInsPayouts();
            GetProcedureSQLOtherAppPettyCash();

            // Sales Report Procedures
            GetProcedureSQLSalesReportDaily();
            GetProcedureSQLSalesReportHourly();
            GetProcedureSQLSalesReportYearly();
            GetProcedureSQLSalesReportWeekly();
            GetProcedureSQLSalesReportMonthly();

            // Item Sold Procedures
            GetProcedureSQLItemSoldDaily();
            GetProcedureSQLItemSoldHourly();
            GetProcedureSQLItemSoldMonthly();
            GetProcedureSQLItemSoldWeekly();
            GetProcedureSQLItemSoldYearly();

            // Staff Procedures
            GetProcedureSQLDailyTimeRecordByStaff();
        }

        public static void CommonProcedures(string createSql, string alterSql)
        {
            __SQL_CONNECTION = new SqlConnection(builder.ConnectionString);
            __SQL_CONNECTION.Open();

            // Create or Alter Get Numeric SQL
            try
            {
                SqlCommand cmd = new SqlCommand(createSql, __SQL_CONNECTION);
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("There is already an object named"))
                {
                    SqlCommand cmd = new SqlCommand(alterSql, __SQL_CONNECTION);
                    cmd.ExecuteNonQuery();
                }
            }
            finally
            {
                __SQL_CONNECTION.Close();
            }
        }


        /// <summary>
        /// Staff and Staff Profile
        /// </summary>
        public static void GetProcedureSQLDailyTimeRecordByStaff()
        {
            string subSql = "   @date as date" +
                "	,@username as varchar(50) " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT [U].[UserName],[U].[Role],[LastName],[FirstName],[Email],[Shift],[Date],[TimeIn],[TimeOut]" +
                "        FROM [dbo].[POSMCUser] [U]" +
                "        LEFT JOIN (SELECT isnull([TIN].[UserName], [TOUT].[UserName]) [UserName],isnull([TIN].[Shift], [TOUT].[Shift]) [Shift],isnull([TIN].[Date], [TOUT].[Date]) [Date],[TimeIn],[TimeOut]" +
                "        FROM (SELECT[UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeIn]" +
                "               FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE[Type] = 'TIME-IN' and[UserName] <> 'ADMIN' " +
                "           GROUP BY[UserName], [Type], [Shift], [AttendanceDate]) [TIN]" +
                "        FULL OUTER JOIN (SELECT[UserName], [Type], [Shift], cast([AttendanceDate] as date ) [Date],max([LogDate]) [TimeOut]" +
                "        FROM [POSLaundry].[dbo].[POSMCUserLog]" +
                "        WHERE [Type] = 'TIME-OUT' and [UserName] <> 'ADMIN' " +
                "        GROUP BY [UserName], [Type], [Shift], [AttendanceDate]) [TOUT]" +
                "        ON [TIN].[UserName] = [TOUT].[UserName]" +
                "        AND [TIN].[Shift] = [TOUT].[Shift] AND [TIN].[Date] = [TOUT].[Date]) [TIME] ON [U].UserName = [TIME].UserName" +
                "       LEFT JOIN dbo.[User] ON [User].UserName = [U].UserName" +
                "       LEFT JOIN dbo.Employee[E] ON [User].EmployeeID = [E].ID " +
                "       WHERE [U].[Role] <> 'ADMIN'  and [Date] between dateadd(day,-15, cast(@date as date)) and cast(@date as date) and [U].[UserName] = @username" +
                "     ORDER BY [Date],[Shift];" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_DailyTimeRecordByStaff] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_DailyTimeRecordByStaff] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        /// <summary>
        /// Sales Reports
        /// </summary>
        public static void GetProcedureSQLSalesReportDaily()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate],DATENAME(month, [TRDate]) [Month],DATEPART(day, [TRDate]) [dayNo]" +
                "	   ,DATENAME(week, [TRDate]) [Week],DATENAME(dw, [TRDate]) [day],sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(month, -3, CAST(@date as date)) AND CAST(DATEADD(day, -1, @date) as date)" +
                "  GROUP BY" +
                "  CAST([TRDate] AS DATE),DATENAME(month, [TRDate]),DATEPART(day, [TRDate]),DATENAME(dw, [TRDate]),DATENAME(week, [TRDate])" +
                "  ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_SalesReport_Daily] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_SalesReport_Daily] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLSalesReportHourly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT" +
                "      CAST([TRDate] AS DATE) [TRDate],DATENAME(dw, [TRDate]) [Day],DATEPART(hh, [TRDate]) [Time],sum([Amount]) [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day, -7, CAST(@date AS DATE)) and @date " +
                "  GROUP BY CAST([TRDate] AS DATE),DATENAME(dw, [TRDate]),DATEPART(hh, [TRDate])" +
                "  ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_SalesReport_Hourly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_SalesReport_Hourly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLSalesReportYearly()
        {
            string subSql = "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT DATEPART(YEAR,[TRDate])[Year],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        GROUP BY DATEPART(YEAR, [TRDate])" +
                "  ORDER BY DATEPART(YEAR, [TRDate]) " +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_SalesReport_Yearly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_SalesReport_Yearly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLSalesReportWeekly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    	SET NOCOUNT ON;" +
                "    SELECT DATEPART(YEAR,[TRDate])[Year],DATENAME(month,[TRDate])[Month],DATEPART(month,[TRDate])[MonthNo],DATENAME(week,[TRDate])[Week]" +
                "      ,sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,1, DATEADD(month, -4, @date)) AND @date" +
                "  GROUP BY DATEPART(YEAR, [TRDate]),DATENAME(month, [TRDate]),DATEPART(month, [TRDate]),DATENAME(week, [TRDate]),DATENAME(weekday, [TRDate])" +
                "  ORDER BY DATENAME(WEEK, [TRDate])" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_SalesReport_Weekly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_SalesReport_Weekly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLSalesReportMonthly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    	SET NOCOUNT ON;" +
                "    SELECT DATEPART(YEAR,[TRDate])[Year],DATENAME(month,[TRDate])[Month],DATEPART(month,[TRDate])[MonthNo],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day,1, DATEADD(year, -1, @date)) AND @date" +
                "  GROUP BY DATEPART(YEAR, [TRDate]),DATENAME(month, [TRDate]),DATEPART(month, [TRDate])" +
                "  ORDER BY DATEPART(month, [TRDate]) " +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_SalesReport_Monthly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_SalesReport_Monthly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        /// <summary>
        /// Item Sold
        /// </summary>
        public static void GetProcedureSQLItemSoldDaily()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate],DATENAME(dd, [TRDate]) [DayNo],DATENAME(dw, [TRDate]) [Day],[DetailsCode],[Preparation],sum([Qty]) [Qty],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left join[POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "	   WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(day, -7, @date ) and @date" +
                "  GROUP BY CAST([TRDate] AS DATE),DATENAME(dd, [TRDate]),DATENAME(dw, [TRDate]),[DetailsCode],[Preparation]" +
                "        ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ItemSoldDaily] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ItemSoldDaily] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLItemSoldHourly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate],DATENAME(dw, [TRDate]) [Day],DATEPART(hh, [TRDate]) [Time],[DetailsCode],[Preparation],sum([Qty]) [Qty],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left join[POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS date) >= (@date ) " +
                "  GROUP BY CAST([TRDate] AS DATE),DATENAME(dw, [TRDate]),DATEPART(hh, [TRDate]),[DetailsCode],[Preparation]" +
                "        ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ItemSoldHourly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ItemSoldHourly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLItemSoldMonthly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate],DATENAME(MONTH, [TRDate]) [month],[DetailsCode],[Preparation],sum([Qty]) [Qty],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left join[POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(month, -3, @date ) AND @date" +
                "  GROUP BY CAST([TRDate] AS DATE),DATENAME(month, [TRDate]),[DetailsCode],[Preparation]" +
                "        ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ItemSoldMonthly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ItemSoldMonthly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLItemSoldWeekly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate],DATEPART(week, [TRDate]) [WeekNo],DATENAME(MONTH, [TRDate]) [month],[DetailsCode],[Preparation],sum([Qty]) [Qty],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left join[POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(week, -5, @date)  AND @date" +
                "  GROUP BY CAST([TRDate] AS DATE),DATEPART(week, [TRDate]),DATENAME(month, [TRDate]),[DetailsCode],[Preparation]" +
                "        ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ItemSoldWeekly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ItemSoldWeekly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLItemSoldYearly()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT DATENAME(year, [TRDate]) [Year],[DetailsCode],[Preparation],sum([Qty]) [Qty],sum([Amount]) [Amount]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left join[POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        WHERE CAST([TRDate] AS DATE) BETWEEN DATEADD(year, -3, @date)  AND @date" +
                "  GROUP BY DATENAME(year, [TRDate]),[DetailsCode],[Preparation]" +
                "        ORDER BY DATENAME(year, [TRDate])" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ItemSoldYearly] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ItemSoldYearly] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        /// <summary>
        /// Others
        /// </summary>
        public static void GetProcedureSQLOtherAppCustomerList()
        {
            string subSql = "AS " +
                "BEGIN " +
                "    SELECT [ClientID],[RegistrationDate],[LastName],[FirstName],[MiddleName],[Gender],[BirthDate],[Mobile],[Email],[Address],ISNULL([PremiumMember],0) [PremiumMember]" +
                "        FROM [dbo].[POSMCClient]" +
                "        ORDER BY [LastName] ASC" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_CustomerList] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_CustomerList] " + subSql;

            CommonProcedures(createSql, alterSql);
        }
    
        public static void GetProcedureSQLOtherAppInventoryReport()
        {
            string subSql = "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT [I].[Code],[I].[Item],[I].[Category],[I].[Unit],(ISNULL([Is].[Quantity],0)) [Stocks],(ISNULL([RD].[IRQuantity],0)) [Replenish],SUM(ISNULL([U].[Quantity],0)) [Usage]" +
                "		  ,(ISNULL([PD].[IPQuantity],0)) [Wasted],[IS].[UpdatedDate]" +
                "        FROM [dbo].[POSMCItem] [I]" +
                "        LEFT JOIN [dbo].[POSMCItemStocks] [IS] ON[IS].[ItemCode] = [I].[Code]" +
                "        LEFT JOIN(SELECT [IR].[ItemCode], SUM([IR].[RQuantity]) [IRQuantity],[IR].[Unit]" +
                "        FROM(SELECT [No]" +
                "     FROM [dbo].[POSMCItemReplenish]" +
                "                   WHERE ([CancelBy] IS NULL AND[ConsolidationNo] IS NULL)) [R]" +
                "        LEFT JOIN(SELECT [ReplenishNo], [ItemCode], SUM([Quantity])[RQuantity], [Unit]" +
                "                        FROM [dbo].[POSMCItemReplenishDetails]" +
                "                    GROUP BY [ReplenishNo], [ItemCode], [Unit]) [IR]" +
                "        ON[IR].[ReplenishNo] = [R].[No]" +
                "        GROUP BY [IR].[ItemCode],[IR].[Unit]) [RD]" +
                "        ON[RD].[ItemCode] = [I].[Code]" +
                "        LEFT JOIN(SELECT [IP].[ItemCode], SUM([IP].[RQuantity]) [IPQuantity],[IP].[Unit]" +
                "        FROM(SELECT [No]" +
                "      FROM [dbo].[POSMCItemPullOut]" +
                "                    WHERE ([CancelBy] is null and[ConsolidationNo] is null)) [P]" +
                "        LEFT JOIN(SELECT [PullOutNo], [ItemCode], SUM([Quantity])[RQuantity], [Unit]" +
                "                     FROM [dbo].[POSMCItemPullOutDetails]" +
                "                  GROUP BY [PullOutNo], [ItemCode], [Unit]) [IP]" +
                "        ON[IP].[PullOutNo] = [p].[No]" +
                "        GROUP BY [IP].[ItemCode],[IP].[Unit]) [PD]" +
                "        ON[PD].[ItemCode] = [I].[Code]" +
                "        LEFT JOIN(SELECT [I].[Code], [I].[Item], SUM([JODS].[DQuantity]) [Quantity],[JODS].[Unit]" +
                "        FROM [dbo].[POSMCItem] [I]" +
                "        LEFT JOIN(SELECT [SP].[JODetailNo], [SP].[ItemCode], [SP].[Item], SUM([SP].[Quantity]) [DQuantity],[SP].[Unit],[JOD].[DeletedBy],[J].[EntryDate],[J].[CancelBy]" +
                "        FROM(((           [dbo].[POSMCJobOrderDetailProducts] [SP]" +
                "                             LEFT JOIN (SELECT [No],[JONo],[DeletedBy]" +
                "                   FROM [dbo].[POSMCJobOrderDetails]) [JOD]" +
                "        ON[JOD].[No] = [SP].[JODetailNo])" +
                "						     LEFT JOIN(SELECT [No], [OperationNo], [EntryDate], [CancelBy]" +
                "                                          FROM [dbo].[POSMCJobOrder]) [J]" +
                "        ON[J].[No] = [JOD].[JONo])" +
                "						     LEFT JOIN(SELECT [No]" +
                "                                          FROM [dbo].[POSMCOperation]" +
                "                                         WHERE [ConsolidationNo] IS NULL) [O]" +
                "        ON[O].[No] = [J].[OperationNo])" +
                "					GROUP BY [SP].[JODetailNo],[SP].[ItemCode],[SP].[Item],[SP].[Unit],[JOD].[DeletedBy],[J].[EntryDate],[J].[CancelBy]) [JODS]" +
                "        ON[JODS].[ItemCode] = [I].[Code]" +
                "        WHERE [JODS].[DQuantity] IS NOT NULL" +
                "         AND[JODS].[DeletedBy]" +
                "        IS NULL" +
                "               AND[JODS].[CancelBy]" +
                "        IS NULL" +
                "          GROUP BY [I].[Code],[I].[Item],[JODS].[Unit]" +
                "        UNION ALL" +
                "            SELECT [I].[Code],[I].[Item],SUM([JODS].[DQuantity]) [Quantity],[JODS].[Unit]" +
                "        FROM [dbo].[POSMCItem] [I]" +
                "        LEFT JOIN(SELECT [SP].[SessionDetailNo], [SP].[ItemCode], [SP].[Item]" +
                "                  , SUM([SP].[Quantity]) DQuantity,[SP].[Unit],[S].[DoneBy],[S].[ConsolidationNo],[S].[SessionDate],[JOD].[DeletedBy],[J].[CancelBy]" +
                "        FROM(((           [dbo].[POSMCJobOrderDetailSessionProducts] [SP]" +
                "                            LEFT JOIN (SELECT [No],[JODetailNo],[DoneBy],[ConsolidationNo],[SessionDate]" +
                "                   FROM [dbo].[POSMCJobOrderDetailSessions]) [S]" +
                "        ON[S].[No] = [SP].[SessionDetailNo])" +
                "							LEFT JOIN(SELECT [No], [JONo], [DeletedBy]" +
                "                                         FROM [dbo].[POSMCJobOrderDetails]) [JOD]" +
                "        ON[JOD].[No] = [S].[JODetailNo])" +
                "							LEFT JOIN(SELECT [No], [OperationNo], [CancelBy]" +
                "                                         FROM [dbo].[POSMCJobOrder]) [J]" +
                "        ON[J].[No] = [JOD].[JONo])" +
                "				   WHERE [S].[DoneBy] IS NOT NULL" +
                "                    AND[S].[ConsolidationNo] IS NULL" +
                "                     AND[JOD].[DeletedBy] IS NULL" +
                "                     AND[J].[CancelBy] IS NULL" +
                "                GROUP BY [SP].[SessionDetailNo],[SP].[ItemCode],[SP].[Item],[SP].[Unit],[S].[DoneBy],[S].[ConsolidationNo],[S].[SessionDate],[JOD].[DeletedBy],[J].[CancelBy]) [JODS]" +
                "        ON[JODS].[ItemCode] = [I].[Code]" +
                "        GROUP BY [I].[Code],[I].[Item],[JODS].[Unit]) [U]" +
                "        ON[U].[Code] = [I].[Code]" +
                "        WHERE(([IS].[Unit] IS NOT NULL) OR([U].[Unit] IS NOT NULL) OR([RD].[Unit] IS NOT NULL) OR([PD].[Unit] IS NOT NULL))" +
                "		  AND([I].[Disabled] IS NULL OR[I].[Disabled] = 0)" +
                "    GROUP BY [I].[Code],[I].[Item],[I].[Unit],[IS].[UpdatedDate],[Is].[Quantity],[RD].[IRQuantity],[PD].[IPQuantity],[I].[Category]" +
                " END";

            string createSql = "CREATE PROCEDURE [dbo].[App_InventoryReport] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_InventoryReport] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppLeastSoldItem()
        {
            string subSql = "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT TOP 20 [Details],SUM([Qty]) [Qty]" +
                "        FROM [dbo].[POSMCTransactionReceipt] [TR]" +
                "        LEFT JOIN [dbo].[POSMCTransactionReceiptDetails] [TRD]" +
                "        ON[TR].[No] = [TRD].[TRNo]" +
                "        WHERE [TR].[CancelBy] IS NULL" +
                "      AND([TR].[TRDate] >= DATEADD(month, -1, GETDATE()))" +
                "  GROUP BY [Details]" +
                "  ORDER BY [Qty] ASC" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_LeastSoldItem] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_LeastSoldItem] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppProductItemList()
        {
            string subSql = "AS " +
                "BEGIN " +
                "    SELECT [O].[Code],[O].[Category],[O].[Name],[O].[Price],ISNULL([Costing],0) [Costing],STUFF((SELECT ' ' + [OP].[Item]" +
                "                    ,' ' + CONVERT(varchar,[OP].[Quantity]),'' + [OP].[Unit] + ', '" +
                "	            FROM [dbo].[POSMCOfferedProducts] [OP]" +
                "        WHERE [OP].[OfferedCode] = [O].[Code]" +
                "        FOR XML PATH('')), 1, 1, '') [Products],STUFF((SELECT ' ' + [OS].[Description],' ' + CONVERT(varchar,[OS].[Duration]) + 'mins, '" +
                "				FROM [dbo].[POSMCOfferedSessions] [OS]" +
                "        WHERE [OS].[OfferedCode] = [O].[Code]" +
                "        FOR XML PATH('')), 1, 1, '') [Services]" +
                "        FROM [dbo].[POSMCOffered] [O]" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ProductItemList] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ProductItemList] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppTopSoldItem()
        {
            string subSql = "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT TOP 20[Details],SUM([Qty]) [Qty]" +
                "        FROM [dbo].[POSMCTransactionReceipt] [TR]" +
                "        LEFT JOIN [dbo].[POSMCTransactionReceiptDetails] [TRD]" +
                "        ON[TR].[No] = [TRD].[TRNo]" +
                "        WHERE [TR].[CancelBy] IS NULL" +
                "      AND([TR].[TRDate] >= DATEADD(month, -1, GETDATE()))" +
                "  GROUP BY [Details]" +
                "  ORDER BY [Qty] DESC" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_TopSoldItem] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_TopSoldItem] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppFinancialStatement()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    	 SET NOCOUNT ON;" +
                "        SELECT DATENAME(month,[TRDate])[Month],month([TRDate]) [MonthSort],0 [Sort],'INCOME' [Type],[Preparation] [Business]" +
                "     ,sum([Amount]) - sum(iif([CancelDate] is null, 0, [Amount]))  [Amount]" +
                "        FROM" +
                "       [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left JOIN [POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        left join(SELECT CAST([OpenedDate] AS DATE) [OpenedDate] FROM [POSLaundry].[dbo].[POSMCOperation] GROUP BY CAST([OpenedDate] AS DATE)) [O]" +
                "        on CAST([TRDate] AS DATE) = CAST(O.[OpenedDate] AS DATE)" +
                "       WHERE year([TRDate]) = year(@date)" +
                "  GROUP BY [Category], DATENAME(month,[TRDate]),[Preparation], month([TRDate])" +
                "  UNION" +
                " SELECT [Month],[MonthSort],1,[Type],[PayOuts],sum(-[Amount] ) [Amount]" +
                "        FROM" +
                "    ( SELECT DATENAME(month,[OpenedDate])[Month], month([OpenedDate])[MonthSort],'EXPENSES' [Type],'PAYOUTS' [Business], [PayOuts]" +
                "          , [Amount] [Amount]" +
                "      FROM [dbo].[POSMCOperationPayOuts]" +
                "      LEFT JOIN [dbo].[POSMCOperation] ON [POSMCOperationPayOuts].OperationNo = [POSMCOperation].[No]" +
                "      WHERE" +
                "              year([OpenedDate]) = year(@date)) PAYOUTS" +
                "     GROUP BY [Month],[MonthSort],[Type] ,[Business],[PayOuts]" +
                "        ORDER BY [Type] desc" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_FinancialStatement] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_FinancialStatement] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppItemSoldBreakdown()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT [PI].[Category],[PI].[Code],[PI].[Item],cast([OrderDate] as DATE) [UsageDate],sum([Quantity]) [Usage],[PJODP].[Unit]" +
                "        FROM [POSLaundry].[dbo].[POSMCItem] [PI]" +
                "        RIGHT JOIN [POSLaundry].[dbo].[POSMCJobOrderDetailProducts] [PJODP]" +
                "        ON[PI].Code = PJODP.[ItemCode]" +
                "       LEFT JOIN [POSLaundry].[dbo].[POSMCJobOrderDetails] [PJOD] ON[PJODP].JODetailNo = [PJOD].[No]" +
                "        LEFT JOIN [POSLaundry].[dbo].[POSMCJobOrder] [PJO] ON[PJOD].[JONo] = [PJO].[No]" +
                "        WHERE isnull([ExcludeInventory],0) = 0" +
                "		and DeletedDate is null and CancelDate is null and isnull([Disabled],0) =0 and[OrderDate] between dateadd(month,-1, @date) and @date" +
                " GROUP BY [PI].[Category],[PI].[Code],[PI].[Item],cast([OrderDate] as date),isnull([Disabled],0),isnull([CriticalLevel],0),[PJODP].[Unit]" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_ItemSoldBreakdown] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_ItemSoldBreakdown] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppMonthlySalesReport()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT CAST([TRDate] AS DATE) [TRDate],[Category],[Details],sum([Qty]) [Qty],sum([Amount]) [Amount],sum([PTRD].[DiscountAmount])  [DC]" +
                "	  ,-sum(iif([CancelDate] is null, 0, [Amount])) [Cancel],sum(iif([CancelDate] is null, [PTRD].[Costing], 0)) [Cost]" +
                "        FROM [POSLaundry].[dbo].[POSMCTransactionReceiptDetails] [PTRD]" +
                "        left join[POSLaundry].[dbo].[POSMCTransactionReceipt] [PTR] on[PTRD].TRNo = [PTR].[No]" +
                "        left join[POSLaundry].[dbo].[POSMCOffered] [PO] on[PTRD].[DetailsCode] = [PO].[Code]" +
                "        left join(SELECT CAST([OpenedDate] AS DATE) [OpenedDate], sum([BankDeposit]) [BankDeposit] FROM [POSLaundry].[dbo].[POSMCOperation] GROUP BY CAST([OpenedDate] AS DATE)) [O]" +
                "        on CAST([TRDate] AS DATE) = CAST(O.[OpenedDate] AS DATE)" +
                "       WHERE [TRDate] between dateadd(month,-1, @date) and @date" +
                "  GROUP BY [Category],[Details], CAST([TRDate] AS DATE),[O].[BankDeposit]" +
                "        ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_MonthlySalesReport] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_MonthlySalesReport] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppPayInsPayouts()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    	SET NOCOUNT ON;" +
                "       SELECT CAST([OpenedDate] AS DATE) [TRDate],[Category],[Details],sum([Ins]) [Ins],sum([Outs]) [Outs]" +
                "        FROM" +
                "    (SELECT [OperationNo],'PAYINS' [Category], [PayIns] [Details], [Amount] [Ins],0 [Outs]" +
                "      FROM [dbo].[POSMCOperationPayIns]" +
                "    UNION" +
                "    SELECT [OperationNo],'PAYOUTS', [PayOuts],0,-[Amount]" +
                "      FROM [dbo].[POSMCOperationPayOuts]) INSOUTS" +
                "      LEFT JOIN[dbo].[POSMCOperation] ON INSOUTS.OperationNo = [POSMCOperation].[No]" +
                "      WHERE [OpenedDate] between dateadd(month,-1, @date) and @date" +
                "     GROUP BY CAST([OpenedDate] AS DATE),[Category],[Details]" +
                "        ORDER BY TRDate" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_PayInsPayouts] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_PayInsPayouts] " + subSql;

            CommonProcedures(createSql, alterSql);
        }

        public static void GetProcedureSQLOtherAppPettyCash()
        {
            string subSql = "   @date as date " +
                "AS " +
                "BEGIN " +
                "    SET NOCOUNT ON;" +
                "    SELECT [BeginningDate][DateEntry],'BEGBAL'[Code],'Beginning Balance'[Description],''[User],[BeginningBalance] [Debit],0 [Credit]" +
                "        FROM [dbo].[POSMCPettyCashBalance]" +
                "        WHERE [No] = (SELECT max([No]) FROM [dbo].[POSMCPettyCashBalance])" +
                "   UNION" +
                "   SELECT CAST([ExpensedDate] AS DATE),[Expenses],[Description],[ExpensedBy] [User],0 [Debit],[Amount] [Credit]" +
                "        FROM [POSLaundry].[dbo].[POSMCPettyCash]" +
                "        UNION" +
                "   SELECT CAST([ReplenishedDate] AS DATE) [DateEntry],'PETTYREPLENISH' [Code],'Petty Cash Replenishment',[ReplenishedBy] [User]	" +
                "	,[Expenses] [Debit],0 [Credit]" +
                "        FROM [POSLaundry].[dbo].[POSMCPettyCashReplenishment]" +
                "        UNION" +
                "   SELECT CAST([DeletedDate] AS DATE) [DateEntry],[Expenses] [Code],'CANCELLED ' + [Description],[DeletedBy] [User]	" +
                "	,[Amount] [Debit],0 [Credit]" +
                "        FROM [POSLaundry].[dbo].[POSMCPettyCash]" +
                "        WHERE [DeletedDate] is not null" +
                " END";
            string createSql = "CREATE PROCEDURE [dbo].[App_PettyCash] " + subSql;
            string alterSql = "ALTER PROCEDURE [dbo].[App_PettyCash] " + subSql;

            CommonProcedures(createSql, alterSql);
        }



        /// <summary>
        /// Get DataSet
        /// </summary>
        public static DataSet GetReportDataSet(String storeName, String dateTime, String userName)
        {
            String connectionString = builder.ConnectionString;

            DataSet ds = null;
            SqlConnection connection = new SqlConnection(connectionString);

            try
            {
                connection.Open();

                ds = new DataSet();

                SqlCommand command = new SqlCommand(storeName, connection);
                if (dateTime != Global.EMPTY_STRING)
                {
                    command.Parameters.Add(new SqlParameter("@date", Convert.ToDateTime(dateTime)));
                }
                if (userName != Global.EMPTY_STRING)
                {
                    command.Parameters.Add(new SqlParameter("@username", userName));
                }
                command.CommandType = CommandType.StoredProcedure;

                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(ds);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                connection.Close();
                connection.Dispose();
            }

            return ds;
        }
        #endregion
    }
}
