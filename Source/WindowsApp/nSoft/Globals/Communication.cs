#define TEST_MODE

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace nSoft.Globals
{
    public static class Communication
    {
        #region "Const"
        public const string _Exception_Prefix = "exception:";
#if TEST_MODE
        public const string _Server_Address_Default_Value = "http://192.168.1.100:10000/communication/";
#else
        //public const string _Server_Address_Default_Value = "http://104.215.13.181/communication/";
        public const string _Server_Address_Default_Value = "http://35.247.134.80/communication/";
#endif
        public const string _Get_Requested_Data = "getRequestedData";
        public const string _Update_Response_Data = "updateResponseData";
        public const string _Clean_Data_Log = "cleanMachineDataLog";

        public const int _Result_Success = 201;
        public const int _Result_Failed = 202;
        public const int _Result_Empty_Machine_ID = 210;
        #endregion

        #region "Methods"
        public async static Task<string> CallGetAPI(string apiUriString, string parameter = "")
        {
            string response = null;

            try
            {
                Uri apiUri = new Uri(apiUriString + parameter);
                WebRequest request = WebRequest.Create(apiUri);
                WebResponse webResponse = await request.GetResponseAsync();
                using (StreamReader streamReader = new StreamReader(webResponse.GetResponseStream()))
                    response = streamReader.ReadToEnd();
            }
            catch (UriFormatException ex)
            {
                response = string.Format(_Exception_Prefix + "{0}", Properties.Resources.CONNECTION_STATUS_ADDRESS_ERROR);
            }
            catch (WebException ex)
            {
                response = string.Format(_Exception_Prefix + "{0}", Properties.Resources.CONNECTION_STATUS_SERVER_ERROR);
            }

            if (response == null)
                response = string.Format(_Exception_Prefix + "{0}", Properties.Resources.CONNECTION_STATUS_ERROR);

            return response;
        }

        public static string CallPostAPI(string strUrl, string strParam)
        {
            string response = null;

            try
            {
                System.Net.HttpWebRequest req = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(strUrl);
                Encoding encoding = Encoding.UTF8;
                //encoding.GetBytes(postData);
                byte[] bs = Encoding.ASCII.GetBytes(strParam);
                string responseData = System.String.Empty;
                req.Method = "POST";
                req.ContentType = "application/x-www-form-urlencoded";
                req.ContentLength = bs.Length;

                try
                {
                    using (System.IO.Stream reqStream = req.GetRequestStream())
                    {
                        reqStream.Write(bs, 0, bs.Length);
                        reqStream.Close();
                    }

                    using (System.Net.HttpWebResponse res = (System.Net.HttpWebResponse)req.GetResponse())
                    {
                        using (System.IO.StreamReader reader = new System.IO.StreamReader(res.GetResponseStream(), encoding))
                        {
                            responseData = reader.ReadToEnd().ToString();
                            response = responseData;
                        }
                    }
                }
                catch (System.Exception ex)
                {
                    response = string.Format(_Exception_Prefix + "{0}", Properties.Resources.CONNECTION_STATUS_SERVER_ERROR);
                }
            }
            catch (System.Exception ex)
            {
                response = string.Format(_Exception_Prefix + "{0}", Properties.Resources.CONNECTION_STATUS_SERVER_ERROR);
            }

            if (response == null)
                response = string.Format(_Exception_Prefix + "{0}", Properties.Resources.CONNECTION_STATUS_ERROR);

            return response;
        }

        public async static void GetRequestedData()
        {
            try
            {
                string responseString = null;

                using (var task = Task.Run(() => CallGetAPI(_Server_Address_Default_Value + _Get_Requested_Data + "?machineID=" + Global.__MACHINE_ID)))
                    responseString = await task;

                if (!responseString.Contains(_Exception_Prefix))
                {
                    JObject response = JObject.Parse(responseString);
                    int code = response["code"].ToObject<int>();
                    var data = JArray.Parse(response["data"].ToString());

                    foreach (var datum in data)
                    {
                        var parsedData = datum.ToObject<Dictionary<string, object>>();

                        int rowId = 0;
                        string requestBy = "";
                        int sqlNo = 0;
                        string searchKey = "";
                        foreach (var param in parsedData)
                        {
                            if (param.Key == "id")
                                rowId = Int32.Parse(param.Value.ToString());
                            if (param.Key == "request_by")
                                requestBy = param.Value.ToString();
                            else if (param.Key == "request_data")
                            {
                                JObject rowRequest = JObject.Parse(param.Value.ToString());
                                sqlNo = rowRequest["sqlNo"].ToObject<int>();
                                searchKey = rowRequest["searchKey"].ToObject<string>();
                            }
                        }

                        Global.__SERVICE_RUNNING_STATUS = false;
                        string result = "";
                        using (var task = Task.Run(() => DBConnection.GetDataFromSQLNo(sqlNo, searchKey, requestBy))) {
                            result = await task;
                            UpdateResponseData(result, rowId, requestBy, sqlNo);
                            Global.__SERVICE_RUNNING_STATUS = true;
                        }
                    }
                }
                else
                {
                    Global.MainViewModel.ShowStatus(Properties.Resources.CONNECTION_STATUS_ERROR);
                    Global.MainViewModel.AddToLogs(Properties.Resources.CONNECTION_STATUS_ERROR);
                }
            }
            catch (JsonReaderException ex)
            {
                Global.MainViewModel.ShowStatus(Properties.Resources.JSON_PARSE_ERROR);
                Global.MainViewModel.AddToLogs(Properties.Resources.JSON_PARSE_ERROR);
            }
            catch (Exception ex)
            {
                Global.MainViewModel.ShowStatus(Properties.Resources.ERROR);
                Global.MainViewModel.AddToLogs(Properties.Resources.ERROR);
            }
        }

        public async static void CleanDataLog()
        {
            try
            {
                string responseString = null;

                using (var task = Task.Run(() => CallGetAPI(_Server_Address_Default_Value + _Clean_Data_Log + "?machineID=" + Global.__MACHINE_ID)))
                    responseString = await task;

                if (!responseString.Contains(_Exception_Prefix))
                {
                    JObject response = JObject.Parse(responseString);
                    int code = response["code"].ToObject<int>();                    
                }
                else
                {
                    Global.MainViewModel.ShowStatus(Properties.Resources.CONNECTION_STATUS_ERROR);
                    Global.MainViewModel.AddToLogs(Properties.Resources.CONNECTION_STATUS_ERROR);
                }
            }
            catch (JsonReaderException ex)
            {
                Global.MainViewModel.ShowStatus(Properties.Resources.JSON_PARSE_ERROR);
                Global.MainViewModel.AddToLogs(Properties.Resources.JSON_PARSE_ERROR);
            }
            catch (Exception ex)
            {
                Global.MainViewModel.ShowStatus(Properties.Resources.ERROR);
                Global.MainViewModel.AddToLogs(Properties.Resources.ERROR);
            }
        }

        public async static void UpdateResponseData(string data, int dataId, string requestBy, int sqlNo)
        {
            // change special character 
            data = data.Replace("&", "_");

            try
            {
                string responseString = null;

                using (var task = Task.Run(() => CallPostAPI(_Server_Address_Default_Value + _Update_Response_Data, "machineID=" + Global.__MACHINE_ID +
                                        "&sqlNo=" + sqlNo + "&dataId=" + dataId + "&responseData=" + data)))
                    responseString = await task;

                if (!responseString.Contains(_Exception_Prefix))
                {
                    JObject response = JObject.Parse(responseString);
                    int code = response["code"].ToObject<int>();
                    if (code == _Result_Success)
                    {
                        Global.MainViewModel.ShowStatus(Properties.Resources.RUNNING);
                        Global.AddResponseLogToMainViewModel(requestBy);
                    }
                }
                else
                {
                    Global.MainViewModel.ShowStatus(Properties.Resources.CONNECTION_STATUS_ERROR);
                    Global.MainViewModel.AddToLogs(Properties.Resources.CONNECTION_STATUS_ERROR);
                }
            }
            catch (JsonReaderException ex)
            {
                Global.MainViewModel.ShowStatus(Properties.Resources.JSON_PARSE_ERROR);
                Global.MainViewModel.AddToLogs(Properties.Resources.JSON_PARSE_ERROR);
            }
            catch (Exception ex)
            {
                Global.MainViewModel.ShowStatus(Properties.Resources.ERROR);
                Global.MainViewModel.AddToLogs(Properties.Resources.ERROR);
            }
        }
        #endregion
    }
}
