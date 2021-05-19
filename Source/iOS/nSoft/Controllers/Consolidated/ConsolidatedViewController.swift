//
//  ConsolidatedViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion
import SideMenu
import Charts

class ConsolidatedViewController: DemoBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    let labelColor = UIColor.init(red: 139/255, green: 200/255, blue: 219/255, alpha: 1)
    let mondayMarkColor = UIColor.init(red: 139/255, green: 200/255, blue: 219/255, alpha: 1)
    let tuesdayMarkColor = UIColor.init(red: 216/255, green: 27/255, blue: 96/255, alpha: 1)
    let wednesdayMarkColor = UIColor.green
    let thursdayMarkColor = UIColor.init(red: 255/255, green: 104/255, blue: 6/255, alpha: 1)
    let fridayMarkColor = UIColor.init(red: 255/255, green: 242/255, blue: 0, alpha: 1)
    let saturdayMarkColor = UIColor.init(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
    let sundayMarkColor = UIColor.init(red: 250/255, green: 129/255, blue: 129/255, alpha: 1)
    let HOURLY_CATEGORY = "Hourly"
    let DAILY_CATEGORY = "Daily"
    let WEEKLY_CATEGORY = "Weekly"
    let MONTHLY_CATEGORY = "Monthly"
    let YEARLY_CATEGORY = "Yearly"
    var selectedReportDate = ""
    var selectedCategory = ""
    var timer = Timer()
    var counter = 0
    var reportArrayList:[ReportModel] = []
    var noticeArrayList:[NoticeModel] = []
    var strUDID = ""
    var strUDIDs = ""
    var strNoticeUDID = ""
    var machineIds = ""
    var dateCategories:[ReportDateModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var isSendEmail = false
    var branchObjects:[BranchModel] = []
    var totalHourlyObjects:[ConsolidateHourlyModel] = []
    var totalDailyObjects:[ConsolidateDailyModel] = []
    var totalWeeklyObjects:[ConsolidateWeeklyModel] = []
    var totalMonthlyObjects:[ConsolidateMonthlyModel] = []
    var totalYearlyObjects:[ConsolidateYearlyModel] = []
    var totalChartObjects:[ConsolidateChartModel] = []
    var barChartXValues:[String] = []
    weak var axisFormatDelegate: IAxisValueFormatter?
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var barChatView: BarChartView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var barSingleChart: BarChartView!
    @IBOutlet weak var dateCategoryCollectionView: UICollectionView!
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBAction func tryConnectAgain(_ sender: Any) {
        if MACHINE_ID != "" {
            self.isNoticeRequest = false
            isSendEmail = false
            QMUITips.showLoading(" Loading ", in: self.view)
            cannotConnectView.isHidden = true
            startConnectTimer()
        }
    }
    @IBAction func showSideMenu(_ sender: Any) {
        showMenu()
    }
    
    @IBAction func selectDate(_ sender: Any) {
       RPicker.selectDate { (selectedDate) in
           // TODO: Your implementation for date
           self.selectedReportDate = selectedDate.dateString("yyyy-MM-dd")
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            if let ddDate = dateFormatter.date(from:self.selectedReportDate) {
               //dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
               dateFormatter.dateFormat = "MMMM dd, yyyy"
               let timeStamp = dateFormatter.string(from: ddDate)
               self.lblDate.text = timeStamp
               self.barChatView.clear()
               self.sendRequestToServer(sqlNo: __REPORTS_CONSOLIDATE, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            } else {
                self.lblDate.text = __DEFAULT_STRING
                self.barChatView.clear()
                self.sendRequestToServer(sqlNo: __REPORTS_CONSOLIDATE, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            }
        }
    }
    
    func initUI() {
        mainView.layer.cornerRadius = mainViewCornerRadius
        topView.layer.cornerRadius = mainViewCornerRadius
        
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        shopCollectionView.allowsMultipleSelection = true
        lblDate.text = getCurrentDate()
        noticeTable.backgroundColor = UIColor.white
        shopCollectionView.backgroundColor = UIColor.init(red: 145/255, green: 203/255, blue: 221/255, alpha: 1)
        dateCategoryCollectionView.backgroundColor = UIColor.white
    }
    
    func getCurrentDate() -> String{
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "MMMM dd, yyyy"
        let formattedDate = format.string(from: date)
        format.dateFormat = "yyyy-MM-dd"
        selectedReportDate = format.string(from: date)

        
        return formattedDate
    }
    
    @IBAction func sendMail(_ sender: Any) {
        machineIds = ""
        if branchObjects.count > 0 {
            for i in 0...branchObjects.count - 1 {
                if branchObjects[i].status == true {
                    if i == branchObjects.count - 1 {
                        machineIds += branchObjects[i].machineId
                    } else {
                        machineIds += branchObjects[i].machineId + ","
                    }
                }
            }
        }
        sendRequestToServerForEmail(sqlNo: __EMAIL_REPORTS_CONSOLIDATE, categoryName: selectedCategory, selectedDate: selectedReportDate)
        isSendEmail = true
    }
    
    func showMenu(){
        let menu = storyboard!.instantiateViewController(withIdentifier: "ReportLeftMenu") as! UISideMenuNavigationController
        if #available(iOS 13.0, *) {
           menu.modalPresentationStyle = .fullScreen
        }
        menu.menuWidth = 300.0
        self.present(menu, animated: true, completion: nil)
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuShadowOpacity = 0.5
        SideMenuManager.default.menuShadowColor = UIColor.black
    }
    
    func initCategory() {
        dateCategories.append(ReportDateModel(category: "Hourly", status: true))
        dateCategories.append(ReportDateModel(category: "Daily", status: false))
        dateCategories.append(ReportDateModel(category: "Weekly", status: false))
        dateCategories.append(ReportDateModel(category: "Monthly", status: false))
        dateCategories.append(ReportDateModel(category: "Yearly", status: false))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        initCategory()
        
        //selectedReportDate = __EMPTY_STRING
        selectedCategory = HOURLY_CATEGORY
        sendRequestToServer(sqlNo: __REPORTS_CONSOLIDATE, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isReportPage = true
        if isClickReportMenu {
           isClickReportMenu = false
           let moveController = self.storyboard?.instantiateViewController(withIdentifier: reportMenuItems[selectedReportMenuIndex][3])
            if #available(iOS 13.0, *) {
               moveController!.modalPresentationStyle = .fullScreen
            }
           self.present(moveController!, animated: true, completion: nil)
           if selectedReportMenuIndex == 4 {
               selectedReportMenuIndex = 0
           }
        }
        if isClickMenuHeader {
            isClickMenuHeader = false
            let moveController = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoViewController") as! UserInfoViewController
            if #available(iOS 13.0, *) {
                moveController.modalPresentationStyle = .fullScreen
            }
            self.present(moveController, animated: true, completion: nil)
        }

        if isBackFromNoticeDetail {
          isBackFromNoticeDetail = false
          sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
        }
    }
    
    func sendRequestToServer(sqlNo:Int, categoryName:String, selectedDate:String) {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.requestWithUDIDs(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, searchKey: categoryName + "_" + selectedDate, didFuncLoad: { result, error in
               if error != nil{
                   QMUITips.hideAllTips()
                   self.showDialog(title: "Warning", message: "Network Error!")
               } else {
                   var resultDicData: Dictionary = [String: Any]()
                   resultDicData = result as! Dictionary
                   let responseCode = resultDicData["code"] as! Int
                   if responseCode == __RESULT_SUCCESS {
                      let responseData = resultDicData["data"] as AnyObject
                      var data: Dictionary = [String: Any]()
                       data = responseData as! Dictionary
                       let uuidArr = data["uuids"] as! NSArray
                       self.strUDIDs = self.json(from: uuidArr)!
                       Motion.delay(6) { [weak self] in
                          self!.getSoldReportData()
                       }
                       
                   } else if(responseCode == __RESULT_FAILED) {
                      QMUITips.hideAllTips()
                      self.showDialog(title: "Warning", message: "Getting uuid failed")
                   }
               }
           })
       }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func sendRequestToServerForEmail(sqlNo:Int, categoryName:String, selectedDate:String) {
        if machineIds == "" {
            self.showDialog(title: "Warning", message: "Please select shop")
        } else {
             QMUITips.showLoading(" Loading ", in: self.view)
             HttpRequest.requestEmailUDID(machineIds: machineIds, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, searchKey: categoryName + "_" + selectedDate, didFuncLoad: { result, error in
                    if error != nil{
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Network Error!")
                    } else {
                        var resultDicData: Dictionary = [String: Any]()
                        resultDicData = result as! Dictionary
                        let responseCode = resultDicData["code"] as! Int
                        if responseCode == __RESULT_SUCCESS {
                           let responseData = resultDicData["data"] as AnyObject
                           var data: Dictionary = [String: Any]()
                            data = responseData as! Dictionary
                            self.strUDID = data["uuid"] as! String
                            self.startConnectTimer()
                        } else if(responseCode == __RESULT_FAILED) {
                           QMUITips.hideAllTips()
                           self.showDialog(title: "Warning", message: "Getting uuid failed")
                        }
                    }
            })
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        counter = 0
        self.cannotConnectView.isHidden = false
    }
    func startConnectTimer() {
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
    }
    
    @objc func getData() {
        counter += 1
        if counter >= __SERVER_CONNECTION_COUNT {
            QMUITips.hideAllTips()
            counter = 0
            timer.invalidate()
            cannotConnectView.isHidden = false
            if isNoticeRequest {
                isNoticeRequest = false
            }
        } else {
            if isNoticeRequest{
                self.getNoticeData()
            } else {
                if isSendEmail {
                    self.getEmailSendStatus()
                }
            }
            
        }
    }
    
    func getEmailSendStatus() {
        HttpRequest.getDashboardData(UDID: strUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    let responseObject = responseData[0] as AnyObject
                    var tempResult: Dictionary = [String: Any]()
                    tempResult = responseObject as! Dictionary
                    let sendStatus = tempResult["result"] as! String
                    
                    self.connectionSuccess()
                    if sendStatus == "Send Success" {
                        self.showDialog(title: "", message: "Email sending success")
                    } else {
                        self.showDialog(title: "", message: "Email sending failed")
                    }
                } else {
                    if self.counter >=  __SERVER_CONNECTION_COUNT {
                          QMUITips.hideAllTips()
                          self.stopTimer()
                          self.cannotConnectView.isHidden = false
                    }
                }
            }
        })
    }
    
    func sendNoticeRequest(sqlNo:Int, searchKey:String) {
        self.isNoticeRequest = true
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.requestUDIDWithSearchKey(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, searchKey: searchKey, didFuncLoad: { result, error in
            if error != nil{
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network Error!")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                   let responseData = resultDicData["data"] as AnyObject
                   var data: Dictionary = [String: Any]()
                   data = responseData as! Dictionary
                    self.strNoticeUDID = data["uuid"] as! String
                    self.startConnectTimer()
                } else if(responseCode == __RESULT_FAILED) {
                   QMUITips.hideAllTips()
                   self.showDialog(title: "Warning", message: "Getting uuid failed")
                } else if responseCode == __RESULT_INCORRECT_UDID {
                    QMUITips.hideAllTips()
                    defaultSettings.set("LOGOUT", forKey: "IS_LOGOUT")
                    MACHINE_ID = ""
                    SHOP_NAME = ""
                    SHOP_BRANCH = ""
                    userID = ""
                    userEmail = ""
                    userName = ""
                    userPhotoUrl = ""
                    userExpiredDate = ""
                    userOwnerLevel = 0
                    userPassword = ""
                    userUniqueID = ""
                    
                    let moveController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    if #available(iOS 13.0, *) {
                        moveController.modalPresentationStyle = .fullScreen
                    }
                    self.present(moveController, animated: true, completion: nil)

                }
            }
        })
    }
    
    func getNoticeData() {
        HttpRequest.getNoticeData(UDID: strNoticeUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                if !self.isClickHiddenBtn && !self.isClickActionBtn {
                    self.noticeArrayList = []
                    var resultDicData: Dictionary = [String: Any]()
                    resultDicData = result as! Dictionary
                    let responseCode = resultDicData["code"] as! Int
                    if responseCode == __RESULT_SUCCESS {
                        let responseData = resultDicData["data"] as AnyObject
                        var data: Dictionary = [String: Any]()
                        data = responseData as! Dictionary
                        let tempArray = data["result"] as! NSArray
                        if tempArray.count > 0 {
                        for i in (0...tempArray.count - 1)  {
                             let tempData = tempArray[i] as! NSArray
                             let no = tempData[0] as! String
                             let dateTime = tempData[1] as! String
                             let type = tempData[2] as! String
                             let title = tempData[3] as! String
                             let content = tempData[4] as! String
                             let viewStatus = tempData[5] as! String
                             let actionStatus = tempData[6] as! String
                             self.noticeArrayList.append(NoticeModel(no: no, type: type, dateTime: dateTime, title: title, content: content, viewStatus: viewStatus, actionStatus: actionStatus))
                            }
                        }
                        self.connectionSuccess()
                    } else {
                        if self.counter >=  __SERVER_CONNECTION_COUNT {
                             QMUITips.hideAllTips()
                             self.stopTimer()
                             self.cannotConnectView.isHidden = false
                        }
                    }
                } else {
                    var resultDicData: Dictionary = [String: Any]()
                    resultDicData = result as! Dictionary
                    let responseCode = resultDicData["code"] as! Int
                    if responseCode == __RESULT_SUCCESS {
                        self.connectionSuccess()
                    } else {
                        if self.counter >=  __SERVER_CONNECTION_COUNT {
                             QMUITips.hideAllTips()
                             self.stopTimer()
                             self.cannotConnectView.isHidden = false
                        }
                    }
                }
            }
        })
    }
    
    var isUpSlide = true
    var isSliding = false
    
    @IBAction func showNoticeTable(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: view)
        if velocity.y > 0 {
            self.isNoticeRequest = false
            self.isUpSlide = true
            if self.isSliding {
                UIView.animate(withDuration: 0.5, animations: {
                    self.noticeView.frame.origin.y = UIScreen.main.bounds.height - 60
                })
            }
            print("Slide down")
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.noticeView.frame.origin.y = 80
                self.bottomBarHeight.constant = UIScreen.main.bounds.height - 80
            })
            if isUpSlide {
                isUpSlide = false
                isSliding = false
                Motion.delay(0.5) { [weak self] in
                    self?.sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
                    self!.isSliding = true
                }
            }
        }
    }
    func showBarCharts() {
        var tempChartObjects:[ConsolidateChartModel] = []
        if totalChartObjects.count > 0 {
            var selectedShopCount = 0
            for i in 0...totalChartObjects.count - 1 {
                if totalChartObjects[i].selectedStatus {
                    selectedShopCount += 1
                    tempChartObjects.append(totalChartObjects[i])
                }
            }
            
            if selectedShopCount > 1 {
                self.barChatView.isHidden = false
                self.barSingleChart.isHidden = true
                initGroupBarChart()
                setGroupBarChart(barChartArray: tempChartObjects)
                
            } else if selectedShopCount == 1 {
                self.axisFormatDelegate = self
                self.barChatView.isHidden = true
                self.barSingleChart.isHidden = false
                var barChartXValues:[String] = []
                var barChartYValues:[Double] = []
                self.barChartXValues = []
                let barChartArray = tempChartObjects[0].barChartObjects
                let color = tempChartObjects[0].color
                if barChartArray.count > 0 {
                    for i in (0...barChartArray.count - 1) {
                        //self.barChartXValues.append(" ")
                        
                        barChartXValues.append(String(barChartArray[i].labelName))
                        self.barChartXValues.append(String(barChartArray[i].labelName))
                        //self.barChartYValues.append(0)
                        barChartYValues.append(Double(barChartArray[i].amount)!)
                    }
                }
                initBarChart()
                setChart(dataEntryX: barChartXValues, dataEntryY: barChartYValues, chartColor: color)
            } else {
                barChatView.clear()
                barSingleChart.clear()
            }
        }
    }
    
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
       
        timer.invalidate()
        counter = 0
        if !isSendEmail {
            showBarCharts()
        }
        if self.isClickHiddenBtn || self.isClickActionBtn {
            if noticeArrayList.count > 0 {
                for i in (0...noticeArrayList.count - 1) {
                    if selectedNoticeNo == noticeArrayList[i].no {
                        if self.isClickHiddenBtn {
                            noticeArrayList.remove(at: i)
                        } else {
                            noticeArrayList[i].actionStatus = "True"
                        }
                        break
                    }
                }
            }
        }
        noticeTable.reloadData()
        shopCollectionView.reloadData()
        dateCategoryCollectionView.reloadData()
        isSendEmail = false
    }
    
    func getSoldReportData() {
        QMUITips.showLoading(" Loading ", in: self.view)
        
        HttpRequest.getConsolidateResult(UDIDs: strUDIDs, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.branchObjects = []
                self.totalHourlyObjects = []
                self.totalDailyObjects = []
                self.totalWeeklyObjects = []
                self.totalMonthlyObjects = []
                self.totalYearlyObjects = []
                self.totalChartObjects = []
                
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    if responseData.count == 0 {
                        QMUITips.hideAllTips()
                    } else {
                        for i in 0...responseData.count - 1 {
                            var data: Dictionary = [String: Any]()
                            data = responseData[i] as! Dictionary
                            var tempBarChartValues:[BarChartModel] = []
                            let shopName = data["shopName"] as! String
                            let shopBranch = data["branch"] as! String
                            let machienId = data["machineId"] as! String
                            let tempResult = data["data"] as! NSArray
                            self.branchObjects.append(BranchModel(no: String(i), shopName: shopName, status: true, branchName: shopBranch, machineId: machienId))
                            
                            if self.selectedCategory == self.HOURLY_CATEGORY {
                                if tempResult.count > 0 {
                                    for i in (0...tempResult.count - 1) {
                                        let tempArr:NSArray = tempResult[i] as! NSArray
                                        let dateTime:String = tempArr[0] as! String
                                        let weekDay:String = tempArr[1] as! String
                                        let rTime:String = tempArr[2] as! String
                                        let amount:String = tempArr[3] as! String
                                        self.totalHourlyObjects.append(ConsolidateHourlyModel(name: shopName, branch: shopBranch, no: String(i), dateTime: dateTime, weekDay: weekDay, numberTime: rTime, amount: amount))
                                        
                                        tempBarChartValues.append(BarChartModel(name: rTime, amount: amount))
                                    }
                                }
                            } else if self.selectedCategory == self.DAILY_CATEGORY {
                                if tempResult.count > 0 {
                                    for i in (0...tempResult.count - 1) {
                                        let tempArr:NSArray = tempResult[i] as! NSArray
                                        let dateTime:String = tempArr[0] as! String
                                        let month:String = tempArr[1] as! String
                                        let day:String = tempArr[2] as! String
                                        let amount:String = tempArr[3] as! String
                                        
                                        self.totalDailyObjects.append(ConsolidateDailyModel(name: shopName, branch: shopBranch, no: String(i), dateTime: dateTime, month: month, day: day, amount: amount))
                                        
                                       tempBarChartValues.append(BarChartModel(name: day, amount: amount))
                                    }
                                }
                            } else if self.selectedCategory == self.WEEKLY_CATEGORY {
                                if tempResult.count > 0 {
                                    for i in (0...tempResult.count - 1) {
                                         let tempArr:NSArray = tempResult[i] as! NSArray
                                         let year:String = tempArr[0] as! String
                                         let monthName:String = tempArr[1] as! String
                                         let monthNo:String = tempArr[2] as! String
                                         let weekNo:String = tempArr[3] as! String
                                         let amount:String = tempArr[4] as! String
                                         self.totalWeeklyObjects.append(ConsolidateWeeklyModel(name: shopName, branch: shopBranch, year: year, weekNo: weekNo, amount: amount, monthName: monthName, monthNo: monthNo))
                                        
                                        tempBarChartValues.append(BarChartModel(name: weekNo, amount: amount))
                                    }
                                }
                            } else if self.selectedCategory == self.MONTHLY_CATEGORY {
                                if tempResult.count > 0 {
                                    for i in (0...tempResult.count - 1) {
                                        let tempArr:NSArray = tempResult[i] as! NSArray
                                        let year:String = tempArr[0] as! String
                                        let monthName:String = tempArr[1] as! String
                                        let monthNo:String = tempArr[2] as! String
                                        let amount:String = tempArr[3] as! String
                                        self.totalMonthlyObjects.append(ConsolidateMonthlyModel(name: shopName, branch: shopBranch, year: year, amount: amount, monthName: monthName, monthNo: monthNo))
                                        
                                        tempBarChartValues.append(BarChartModel(name: monthNo, amount: amount))
                                    }
                                }
                            } else if self.selectedCategory == self.YEARLY_CATEGORY {
                                if tempResult.count > 0 {
                                    for i in (0...tempResult.count - 1) {
                                        let tempArr:NSArray = tempResult[i] as! NSArray
                                        let year:String = tempArr[0] as! String
                                        let amount:String = tempArr[1] as! String
                                        self.totalYearlyObjects.append(ConsolidateYearlyModel(name: shopName, branch: shopBranch, year: year, amount: amount))
                                        
                                        tempBarChartValues.append(BarChartModel(name: year, amount: amount))
                                    }
                                }
                            }
                            
                            let color:UIColor?
                            switch i % 8 {
                            case 0:
                                color = self.mondayMarkColor
                                break
                            case 1:
                                color = self.tuesdayMarkColor
                                break
                            case 2:
                                color = self.wednesdayMarkColor
                                break
                            case 3:
                                color = self.thursdayMarkColor
                                break
                            case 4:
                                color = self.fridayMarkColor
                                break
                            case 5:
                                color = self.saturdayMarkColor
                                break
                            case 6:
                                color = self.sundayMarkColor
                                break
                            default:
                                color = self.mondayMarkColor
                                break
                            }
                            
                            self.totalChartObjects.append(ConsolidateChartModel(name: shopName, branch: shopBranch, no: String(i), barChartObjects: tempBarChartValues, color: color!, status: true))
                        }
                        
                        
                    }
                    
                    self.connectionSuccess()
                    
                } else if(responseCode == __RESULT_FAILED) {
                     //if self.counter >=  __SERVER_CONNECTION_COUNT {
                          QMUITips.hideAllTips()
                          self.stopTimer()
                          self.cannotConnectView.isHidden = false
                    //}
                }
            }
        })
    }
    
    
    func initBarChart() {
        barSingleChart.delegate = self

        barSingleChart.chartDescription?.enabled = false
        barSingleChart.maxVisibleCount = 60
        barSingleChart.pinchZoomEnabled = false
        barSingleChart.drawBarShadowEnabled = false
        barSingleChart.doubleTapToZoomEnabled = false
        barSingleChart.scaleXEnabled = false
        barSingleChart.scaleYEnabled = false
        barSingleChart.isUserInteractionEnabled = false
        let xAxis = barSingleChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = labelColor
        xAxis.gridColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        xAxis.axisLineColor = labelColor
        xAxis.labelCount = totalYearlyObjects.count

        let leftAxis = barSingleChart.leftAxis
        leftAxis.labelTextColor = labelColor
        leftAxis.gridColor = .white
        leftAxis.axisLineColor = labelColor
        leftAxis.labelCount = 5
        leftAxis.axisMinimum = 0

        barSingleChart.rightAxis.enabled = false
        barSingleChart.tintColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)

        barSingleChart.legend.enabled = false
                
        barSingleChart.animate(yAxisDuration: 1.0)
    }
    
    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double], chartColor:UIColor) {
        //barChatView.noDataText = "You need to provide data for the chart."
        var dataEntries:[BarChartDataEntry] = []
        for i in 0..<forX.count{
           // print(forX[i])
           // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: barChartXValues as AnyObject?)
            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = [chartColor]
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
        chartData.barWidth = Double(0.7)
        barSingleChart.data = chartData
        let xAxisValue = barSingleChart.xAxis
        xAxisValue.labelCount = barChartXValues.count
        xAxisValue.valueFormatter = axisFormatDelegate
    }
    func setBarChartValues(dataEntryX forX:[String],dataEntryY forY: [Double], dataXValueArr:[String]) -> [BarChartDataEntry]{
    //barChatView.noDataText = "You need to provide data for the chart."
        var dataEntries:[BarChartDataEntry] = []
        for i in 0..<forX.count{
           // print(forX[i])
           // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: dataXValueArr as AnyObject?)
            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        return dataEntries
    }
    
    
        func initGroupBarChart() {
            barChatView.delegate = self
                    
            barChatView.chartDescription?.enabled =  false
            
            barChatView.pinchZoomEnabled = false
            barChatView.drawBarShadowEnabled = false
            barChatView.doubleTapToZoomEnabled = false
            barChatView.scaleXEnabled = false
            barChatView.scaleYEnabled = false
            barChatView.isUserInteractionEnabled = false
            let l = barChatView.legend
            l.horizontalAlignment = .right
            l.verticalAlignment = .top
            l.orientation = .vertical
            l.drawInside = true
            l.font = .systemFont(ofSize: 8, weight: .light)
            l.yOffset = 0
            l.xOffset = 10
            l.yEntrySpace = 3
    //        chartView.legend = l

            let xAxis = barChatView.xAxis
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            xAxis.labelPosition = .bottom
            xAxis.labelTextColor = labelColor
            xAxis.axisLineColor = labelColor
            
            xAxis.centerAxisLabelsEnabled = true
            xAxis.valueFormatter = IntAxisValueFormatter()
            
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.maximumFractionDigits = 1
            
            let leftAxis = barChatView.leftAxis
            leftAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            leftAxis.valueFormatter = LargeValueFormatter()
            leftAxis.spaceTop = 0.35
            leftAxis.labelTextColor = labelColor
            leftAxis.gridColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
            leftAxis.axisLineColor = labelColor
            leftAxis.axisMinimum = 0
            
            barChatView.rightAxis.enabled = false
            barChatView.animate(yAxisDuration: 1)
        }
        
        func setBarGroupChartValues(dataEntryX forX:[String],dataEntryY forY: [Double], dataXValueArr:[String]) -> [BarChartDataEntry]{
        //barChatView.noDataText = "You need to provide data for the chart."
            var dataEntries:[BarChartDataEntry] = []
            for i in 0..<forX.count{
               // print(forX[i])
               // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: dataXValueArr as AnyObject?)
                print(dataEntry)
                dataEntries.append(dataEntry)
            }
            return dataEntries
        }
        
        func setGroupBarChart(barChartArray:[ConsolidateChartModel]) {
            let groupSpace = 0.08
            let barSpace = 0.03
            let barWidth = Double(1.0 - groupSpace) / Double(barChartArray.count) - barSpace
            // (0.2 + 0.03) * 4 + 0.08 = 1.00 -> interval per "group"

            var count = 0
            var staftValue = 0
            if barChartArray.count > 0 {
                count = barChartArray[0].barChartObjects.count
                staftValue = Int(barChartArray[0].barChartObjects[0].labelName)!
            }
            
            var dataSets:[BarChartDataSet] = []
            for i in (0...barChartArray.count - 1) {
                let labelName = barChartArray[i].shopBranch
                let color = barChartArray[i].color
                var chartXValues:[String] = []
                var chartYValues:[Double] = []
                let barChartValues = barChartArray[i].barChartObjects
                if barChartValues.count > 0 {
                    for j in 0...barChartValues.count - 1 {
                        chartXValues.append(barChartValues[j].labelName)
                        chartYValues.append(Double(barChartValues[j].amount)!)
                    }
                }
                let dataEntries = setBarGroupChartValues(dataEntryX: chartXValues, dataEntryY: chartYValues, dataXValueArr: chartXValues)
                
                let set = BarChartDataSet(entries: dataEntries, label: labelName)
                set.setColor(color)
                dataSets.append(set)
            }
        
            
            let data = BarChartData(dataSets: dataSets)
            data.setValueFont(.systemFont(ofSize: 10, weight: .light))
            //data.setValueFormatter(LargeValueFormatter())
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            // specify the width each bar should have
            data.barWidth = barWidth

            // restrict the x-axis range
            barChatView.xAxis.axisMinimum = Double(staftValue)
            barChatView.xAxis.labelCount = count
            // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
            barChatView.xAxis.axisMaximum = Double(staftValue) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(count)
            
            data.groupBars(fromX: Double(staftValue), groupSpace: groupSpace, barSpace: barSpace)

            barChatView.data = data
        }
    
    func showDialog(title:String, message:String) {
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
             switch action.style{
             case .default:
                   print("default")

             case .cancel:
                   print("cancel")

             case .destructive:
                   print("destructive")


       }}))
       self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return reportArrayList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConsolidateNoticeTableViewCell") as! ConsolidateNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let report = reportArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSoldTableViewCell") as! ItemSoldTableViewCell
            cell.set(model: report)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            currentNoticeNo = notice.no
            currentNoticeType = notice.type
            currentNoticeTitle = notice.title
            currentNoticeContent = notice.content
            currentNoticeViewStatus = notice.viewStatus
            currentNoticeActionStatus = notice.actionStatus
            let moveController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as! NoticeDetailViewController
            if #available(iOS 13.0, *) {
                moveController.modalPresentationStyle = .fullScreen
            }
            self.present(moveController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dateCategoryCollectionView {
            return dateCategories.count
        } else {
            return branchObjects.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == dateCategoryCollectionView {
            return CGSize(width: 100.0, height: 50)
        } else {
            return CGSize(width: 120.0, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dateCategoryCollectionView {
            let category = dateCategories[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as!  DateCollectionViewCell
            cell.set(model: category)
            return cell
        } else {
            let branch = branchObjects[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCell", for: indexPath) as!  ShopCollectionViewCell
            cell.set(model: branch)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dateCategoryCollectionView {
            let selectedIndex = indexPath.row
            for i in (0...dateCategories.count - 1) {
                dateCategories[i].selectedStatus = false
            }
            dateCategories[selectedIndex].selectedStatus = true
            selectedCategory = dateCategories[selectedIndex].selectedCategory
            self.barChatView.clear()
            self.barSingleChart.clear()
            bottomBarHeight.constant = 60.0
            dateCategoryCollectionView.reloadData()
            self.reportArrayList = []
            sendRequestToServer(sqlNo: __REPORTS_CONSOLIDATE, categoryName: selectedCategory, selectedDate: selectedReportDate)
        } else {
            let selectedIndex = indexPath.row
            for i in (0...branchObjects.count - 1) {
                if i == selectedIndex {
                    branchObjects[i].status = !branchObjects[i].status
                    totalChartObjects[i].selectedStatus = !totalChartObjects[i].selectedStatus
                }
            }
            self.barChatView.clear()
            self.barSingleChart.clear()
            
            bottomBarHeight.constant = 60.0
            showBarCharts()
            shopCollectionView.reloadData()
            
        }
    }

}

extension ConsolidatedViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return barChartXValues[Int(value)]
    }
}

extension ConsolidatedViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension ConsolidatedViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
