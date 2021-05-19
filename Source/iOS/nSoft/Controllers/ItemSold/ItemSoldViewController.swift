//
//  ItemSoldViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Charts
import Motion
import SideMenu

class ItemSoldViewController: DemoBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
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
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var timer = Timer()
    var counter = 0
    var singleCharCount = 0
    var isSendEmail = false
    var strUDID = ""
    var strNoticeUDID = ""
    var selectedReportDate = ""
    var selectedCategory = ""
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var dateCategories:[ReportDateModel] = []
    var reportArrayList:[ReportModel] = []
    var totalChartObjects:[ItemSoldChartModel] = []
    var totalHourlyObjects:[ItemSoldHourlyModel] = []
    var totalDailyObjects:[ItemSoldDailyModel] = []
    var totalWeeklyObjects:[ItemSoldWeeklyModel] = []
    var totalMonthlyObjects:[ItemSoldMonthlyModel] = []
    var totalYearlyObjects:[ItemSoldYearlyModel] = []
    var barChartXValues:[String] = []
    var barChartYValues:[Double] = []
    var singleBarChartColor:UIColor?
    var singleBarChartBranchName:String = ""
    @IBOutlet weak var reportThreeCellView: UIView!
    @IBOutlet weak var reportThreeCellTable: UITableView!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var barChatView: BarChartView!
    @IBOutlet weak var barSingleChartView: BarChartView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var wrapTableView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTableTitle: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    weak var axisFormatDelegate: IAxisValueFormatter?
    @IBOutlet weak var salesAmountTable: UITableView!
    @IBOutlet weak var dateCategoryCollectionView: UICollectionView!
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
    @IBAction func selectDate(_ sender: Any) {
        RPicker.selectDate { (selectedDate) in
            // TODO: Your implementation for date
            self.selectedReportDate = selectedDate.dateString("yyyy-MM-dd")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            if let ddDate = dateFormatter.date(from:self.selectedReportDate) {
                dateFormatter.dateFormat = "MMMM dd, yyyy"///this is what you want to convert format
                let timeStamp = dateFormatter.string(from: ddDate)
                self.lblDate.text = timeStamp
                self.barChatView.clear()
                self.sendRequestToServer(sqlNo: __REPORTS_ITEM_SOLD, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            } else {
                self.lblDate.text = __DEFAULT_STRING
                self.barChatView.clear()
                self.sendRequestToServer(sqlNo: __REPORTS_ITEM_SOLD, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            }
        }
    }
    
    @IBAction func sendMail(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_SALES, categoryName: selectedCategory, selectedDate: selectedReportDate)
        isSendEmail = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        initCategory()
        selectedCategory = HOURLY_CATEGORY
        self.sendRequestToServer(sqlNo: __REPORTS_ITEM_SOLD, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
    }
    
    func initBarChart() {
        barChatView.delegate = self
                
        barChatView.chartDescription?.enabled =  false
        
        barChatView.pinchZoomEnabled = false
        barChatView.drawBarShadowEnabled = false
        barChatView.doubleTapToZoomEnabled = false
        barChatView.scaleXEnabled = false
        barChatView.scaleYEnabled = false
        barChatView.isUserInteractionEnabled = false
//        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1), font: .systemFont(ofSize: 12), textColor: .white, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
//        marker.chartView = barChatView
//        marker.minimumSize = CGSize(width: 80, height: 40)
//        barChatView.marker = marker
        
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
    
    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double], dataXValueArr:[String]) -> [BarChartDataEntry]{
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
    
    func setBarChart(barChartArray:[ItemSoldChartModel]) {
        let groupSpace = 0.08
        let barSpace = 0.03
        let barWidth = Double(1.0 - groupSpace) / Double(barChartArray.count) - barSpace
        // (0.2 + 0.03) * 4 + 0.08 = 1.00 -> interval per "group"

        let count = barChartArray[0].barChartArrays.count
        let staftValue = Int(barChartArray[0].barChartArrays[0].labelName)
        
        var dataSets:[BarChartDataSet] = []
        for i in (0...barChartArray.count - 1) {
            let labelName = barChartArray[i].itemName
            let color = barChartArray[i].color
            var chartXValues:[String] = []
            var chartYValues:[Double] = []
            let barChartValues = barChartArray[i].barChartArrays
            if barChartValues.count > 0 {
                for j in 0...barChartValues.count - 1 {
                    chartXValues.append(barChartValues[j].labelName)
                    chartYValues.append(Double(barChartValues[j].amount)!)
                }
            }
            let dataEntries = setChart(dataEntryX: chartXValues, dataEntryY: chartYValues, dataXValueArr: chartXValues)
            
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
        barChatView.xAxis.axisMinimum = Double(staftValue!)
        barChatView.xAxis.labelCount = count
        // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
        barChatView.xAxis.axisMaximum = Double(staftValue!) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(count)
        
        data.groupBars(fromX: Double(staftValue!), groupSpace: groupSpace, barSpace: barSpace)

        barChatView.data = data
    }
    
    func initSingleBarChart() {
        barSingleChartView.delegate = self

        barSingleChartView.chartDescription?.enabled = false
        barSingleChartView.maxVisibleCount = 60
        barSingleChartView.pinchZoomEnabled = false
        barSingleChartView.drawBarShadowEnabled = false
        barSingleChartView.doubleTapToZoomEnabled = false
        barSingleChartView.scaleXEnabled = false
        barSingleChartView.scaleYEnabled = false
        barSingleChartView.isUserInteractionEnabled = false
        let xAxis = barSingleChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = labelColor
        xAxis.gridColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        xAxis.axisLineColor = labelColor
        xAxis.labelCount = singleCharCount

        let leftAxis = barSingleChartView.leftAxis
        leftAxis.labelTextColor = labelColor
        leftAxis.gridColor = .white
        leftAxis.axisLineColor = labelColor
        leftAxis.labelCount = 5
        leftAxis.axisMinimum = 0

        barSingleChartView.rightAxis.enabled = false
        barSingleChartView.tintColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)

        barSingleChartView.legend.enabled = false
                
        barSingleChartView.animate(yAxisDuration: 1.0)
    }
    
    func setSingleChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
        //barChatView.noDataText = "You need to provide data for the chart."
        var dataEntries:[BarChartDataEntry] = []
        for i in 0..<forX.count{
           // print(forX[i])
           // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: barChartXValues as AnyObject?)
            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: singleBarChartBranchName)
        chartDataSet.colors = [singleBarChartColor!]
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
        chartData.barWidth = Double(0.7)
        barSingleChartView.data = chartData
        let xAxisValue = barSingleChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
    }
    
    func initCategory() {
        dateCategories.append(ReportDateModel(category: "Hourly", status: true))
        dateCategories.append(ReportDateModel(category: "Daily", status: false))
        dateCategories.append(ReportDateModel(category: "Weekly", status: false))
        dateCategories.append(ReportDateModel(category: "Monthly", status: false))
        dateCategories.append(ReportDateModel(category: "Yearly", status: false))
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
    
    func initUI() {
        mainView.layer.cornerRadius = mainViewCornerRadius
        topView.layer.cornerRadius = mainViewCornerRadius
        wrapTableView.layer.borderWidth = 1.0
        wrapTableView.layer.borderColor = UIColor.init(red: 233/255, green: 242/255, blue: 244/255, alpha: 1).cgColor
        reportThreeCellView.layer.borderWidth = 1.0
        reportThreeCellView.layer.borderColor = UIColor.init(red: 233/255, green: 242/255, blue: 244/255, alpha: 1).cgColor
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        lblDate.text = self.getCurrentDate()
        noticeTable.backgroundColor = UIColor.white
        dateCategoryCollectionView.backgroundColor = UIColor.white
        salesAmountTable.backgroundColor = UIColor.white
        reportThreeCellTable.backgroundColor = UIColor.white
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
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
       
        timer.invalidate()
        counter = 0
        if !isSendEmail {
            getGraphInformation()
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
        reportThreeCellTable.reloadData()
        dateCategoryCollectionView.reloadData()
        
        self.isSendEmail = false
    }
    
    func getColor(no:Int) -> UIColor {
        var color:UIColor = mondayMarkColor
        switch(no % 8) {
        case 0:
            color = mondayMarkColor
            break
        case 1:
            color = tuesdayMarkColor
            break
        case 2:
            color = wednesdayMarkColor
            break
        case 3:
            color = thursdayMarkColor
            break
        case 4:
            color = fridayMarkColor
            break
        case 5:
            color = saturdayMarkColor
            break
        case 6:
            color = sundayMarkColor
            break
        default:
            color = mondayMarkColor
            break
        }
        return color
    }
    
    func sendRequestToServer(sqlNo:Int, categoryName:String, selectedDate:String) {
           QMUITips.showLoading(" Loading ", in: self.view)
           HttpRequest.requestUDIDWithSearchKey(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, searchKey: categoryName + "_" + selectedDate, didFuncLoad: { result, error in
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
                } else {
                    self.getSoldReportData()
                }
            }
            
        }
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
    
    func getSoldReportData() {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.getReportData(UDID: strUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.totalHourlyObjects = []
                self.totalDailyObjects = []
                self.totalWeeklyObjects = []
                self.totalMonthlyObjects = []
                self.totalYearlyObjects = []
                self.totalChartObjects = []
                self.reportArrayList = []
                
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    let tempResult = data["result"] as! NSArray
                    if tempResult.count == 0 {
                        QMUITips.hideAllTips()
                    } else {
                        for i in (0...tempResult.count - 1){
                            
                            if self.selectedCategory == self.HOURLY_CATEGORY {
                                let tempData = tempResult[i] as! NSArray
                                let dateTime1 = tempData[0] as! String
                                let weekDay = tempData[1] as! String
                                let dateTime2 = tempData[2] as! String
                                let itemname = tempData[3] as! String
                                let itemCount = tempData[4] as! String
                                let amount = tempData[5] as! String
                                
                                self.totalHourlyObjects.append(ItemSoldHourlyModel(name: itemname, time1: dateTime1, weekday: weekDay, time2: dateTime2, amount: amount, count: Int(itemCount)!))
                                
                                self.reportArrayList.append(ReportModel(no: String(i + 1), title1: itemname, title2: dateTime2, amount: Int(itemCount)!))
                            } else if self.selectedCategory == self.DAILY_CATEGORY {
                                let tempData = tempResult[i] as! NSArray
                                let dateTime1 = tempData[0] as! String
                                let day = tempData[1] as! String
                                let weekday = tempData[2] as! String
                                let itemname = tempData[3] as! String
                                let itemCount = tempData[4] as! String
                                let amount = tempData[5] as! String
                                
                                self.totalDailyObjects.append(ItemSoldDailyModel(name: itemname, dateTime: dateTime1, weekDay: weekday, day: day, amount: amount, count: Int(itemCount)!))
                                
                                self.reportArrayList.append(ReportModel(no: String(i + 1), title1: itemname, title2: day, amount: Int(itemCount)!))
                            } else if self.selectedCategory == self.WEEKLY_CATEGORY {
                                let tempData = tempResult[i] as! NSArray
                                let week = tempData[0] as! String
                                let monthName = tempData[1] as! String
                                let itemname = tempData[2] as! String
                                let itemCount = tempData[3] as! String
                                let amount = tempData[4] as! String
                                
                                self.totalWeeklyObjects.append(ItemSoldWeeklyModel(name: itemname, month: monthName, week: Int(week)!, amount: amount, count: Int(itemCount)!))
                                
                                self.reportArrayList.append(ReportModel(no: String(i + 1), title1: itemname, title2: week, amount: Int(itemCount)!))
                            } else if self.selectedCategory == self.MONTHLY_CATEGORY {
                                let tempData = tempResult[i] as! NSArray
                                let monthName = tempData[0] as! String
                                let itemname = tempData[1] as! String
                                let itemCount = tempData[2] as! String
                                let amount = tempData[3] as! String
                                let no = self.months.index(of: monthName)! + 1
                                
                                self.totalMonthlyObjects.append(ItemSoldMonthlyModel(no: no, name: itemname, month: monthName, amount: amount, count: Int(itemCount)!))
                                
                                self.reportArrayList.append(ReportModel(no: String(i + 1), title1: itemname, title2: monthName, amount: Int(itemCount)!))
                            } else if self.selectedCategory == self.YEARLY_CATEGORY {
                                let tempData = tempResult[i] as! NSArray
                                let year = tempData[0] as! String
                                let itemname = tempData[1] as! String
                                let itemCount = tempData[2] as! String
                                let amount = tempData[3] as! String
                                
                                self.totalYearlyObjects.append(ItemSoldYearlyModel(name: itemname, year: year, amount: amount, count: Int(itemCount)!))
                                
                                self.reportArrayList.append(ReportModel(no: String(i + 1), title1: itemname, title2: year, amount: Int(itemCount)!))
                            }
                           
                        }
                    }
                    
                    self.connectionSuccess()
                    
                } else if(responseCode == __RESULT_FAILED) {
                   if self.counter >=  __SERVER_CONNECTION_COUNT {
                          QMUITips.hideAllTips()
                          self.stopTimer()
                          self.cannotConnectView.isHidden = false
                    }
                }
            }
        })
    }
    
    func getGraphInformation() {
        self.totalChartObjects = []
        if selectedCategory == HOURLY_CATEGORY
        {
            lblDateTitle.text = "Time"
            var timeArray:[Int] = []
            var itemArray:[String] = []
            if self.totalHourlyObjects.count > 0 {
                for i in 0...self.totalHourlyObjects.count - 1 {
                    if !timeArray.contains(Int(self.totalHourlyObjects[i].dateTime2)!) {
                        timeArray.append(Int(self.totalHourlyObjects[i].dateTime2)!)
                    }
                    if !itemArray.contains(self.totalHourlyObjects[i].itemName) {
                        itemArray.append(self.totalHourlyObjects[i].itemName)
                    }
                }
            }
            
            if itemArray.count > 0 {
                for i in 0...itemArray.count - 1 {
                    let strItem:String = itemArray[i]
                    let no = i
                    let selectedStatus = true
                    let color = self.getColor(no: i)
                    var tempItemList:[ItemSoldHourlyModel] = []
                    for k in 0...self.totalHourlyObjects.count - 1 {
                        if self.totalHourlyObjects[k].itemName == strItem {
                            tempItemList.append(self.totalHourlyObjects[k])
                        }
                    }
                    var barChartObjects:[BarChartModel] = []
                    for j in 0...timeArray.count - 1 {
                        let labelName = timeArray[j]
                        var amount = 0
                        if tempItemList.count > 0 {
                            for k in 0...tempItemList.count - 1 {
                                if tempItemList[k].dateTime2 == String(timeArray[j]) {
                                    amount = tempItemList[k].itemCount
                                }
                            }
                        }
                        barChartObjects.append(BarChartModel(name: String(labelName), amount: String(amount)))
                        
                    }
                    
                    self.totalChartObjects.append(ItemSoldChartModel(name: strItem, no: String(no), chartArray: barChartObjects, color: color, status: selectedStatus))
                }
            }
        } else if selectedCategory == DAILY_CATEGORY {
            lblDateTitle.text = "Day"
            var dayArray:[Int] = []
            var itemArray:[String] = []
            if self.totalDailyObjects.count > 0 {
                for i in 0...self.totalDailyObjects.count - 1 {
                    if !dayArray.contains(Int(self.totalDailyObjects[i].day)!) {
                        dayArray.append(Int(self.totalDailyObjects[i].day)!)
                    }
                    if !itemArray.contains(self.totalDailyObjects[i].itemName) {
                        itemArray.append(self.totalDailyObjects[i].itemName)
                    }
                }
            }
            
            if itemArray.count > 0 {
                for i in 0...itemArray.count - 1 {
                    let strItem:String = itemArray[i]
                    let no = i
                    let selectedStatus = true
                    let color = self.getColor(no: i)
                    var tempItemList:[ItemSoldDailyModel] = []
                    for k in 0...self.totalDailyObjects.count - 1 {
                        if self.totalDailyObjects[k].itemName == strItem {
                            tempItemList.append(self.totalDailyObjects[k])
                        }
                    }
                    var barChartObjects:[BarChartModel] = []
                    for j in 0...dayArray.count - 1 {
                        let labelName = dayArray[j]
                        var amount = 0
                        if tempItemList.count > 0 {
                            for k in 0...tempItemList.count - 1 {
                                if tempItemList[k].day == String(dayArray[j]) {
                                    amount = tempItemList[k].itemCount
                                }
                            }
                        }
                        barChartObjects.append(BarChartModel(name: String(labelName), amount: String(amount)))
                        
                    }
                    
                    self.totalChartObjects.append(ItemSoldChartModel(name: strItem, no: String(no), chartArray: barChartObjects, color: color, status: selectedStatus))
                }
            }
        } else if selectedCategory == WEEKLY_CATEGORY {
            lblDateTitle.text = "Week"
            var weekArray:[Int] = []
            var itemArray:[String] = []
            if self.totalWeeklyObjects.count > 0 {
                for i in 0...self.totalWeeklyObjects.count - 1 {
                    if !weekArray.contains(self.totalWeeklyObjects[i].week) {
                        weekArray.append(self.totalWeeklyObjects[i].week)
                    }
                    if !itemArray.contains(self.totalWeeklyObjects[i].itemName) {
                        itemArray.append(self.totalWeeklyObjects[i].itemName)
                    }
                }
            }
            
            if itemArray.count > 0 {
                for i in 0...itemArray.count - 1 {
                    let strItem:String = itemArray[i]
                    let no = i
                    let selectedStatus = true
                    let color = self.getColor(no: i)
                    var tempItemList:[ItemSoldWeeklyModel] = []
                    for k in 0...self.totalWeeklyObjects.count - 1 {
                        if self.totalWeeklyObjects[k].itemName == strItem {
                            tempItemList.append(self.totalWeeklyObjects[k])
                        }
                    }
                    var barChartObjects:[BarChartModel] = []
                    for j in 0...weekArray.count - 1 {
                        let labelName = weekArray[j]
                        var amount = 0
                        if tempItemList.count > 0 {
                            for k in 0...tempItemList.count - 1 {
                                if tempItemList[k].week == weekArray[j] {
                                    amount = tempItemList[k].itemCount
                                }
                            }
                        }
                        barChartObjects.append(BarChartModel(name: String(labelName), amount: String(amount)))
                        
                    }
                    
                    self.totalChartObjects.append(ItemSoldChartModel(name: strItem, no: String(no), chartArray: barChartObjects, color: color, status: selectedStatus))
                }
            }
        } else if selectedCategory == MONTHLY_CATEGORY {
            lblDateTitle.text = "Month"
            var monthArray:[Int] = []
            var itemArray:[String] = []
            if self.totalMonthlyObjects.count > 0 {
                for i in 0...self.totalMonthlyObjects.count - 1 {
                    if !monthArray.contains(self.totalMonthlyObjects[i].monthNo) {
                        monthArray.append(self.totalMonthlyObjects[i].monthNo)
                    }
                    if !itemArray.contains(self.totalMonthlyObjects[i].itemName) {
                        itemArray.append(self.totalMonthlyObjects[i].itemName)
                    }
                }
            }
            
            if itemArray.count > 0 {
                for i in 0...itemArray.count - 1 {
                    let strItem:String = itemArray[i]
                    let no = i
                    let selectedStatus = true
                    let color = self.getColor(no: i)
                    var tempItemList:[ItemSoldMonthlyModel] = []
                    for k in 0...self.totalMonthlyObjects.count - 1 {
                        if self.totalMonthlyObjects[k].itemName == strItem {
                            tempItemList.append(self.totalMonthlyObjects[k])
                        }
                    }
                    var barChartObjects:[BarChartModel] = []
                    for j in 0...monthArray.count - 1 {
                        let labelName = monthArray[j]
                        var amount = 0
                        if tempItemList.count > 0 {
                            for k in 0...tempItemList.count - 1 {
                                if tempItemList[k].monthNo == monthArray[j] {
                                    amount = tempItemList[k].itemCount
                                }
                            }
                        }
                        barChartObjects.append(BarChartModel(name: String(labelName), amount: String(amount)))
                        
                    }
                    
                    self.totalChartObjects.append(ItemSoldChartModel(name: strItem, no: String(no), chartArray: barChartObjects, color: color, status: selectedStatus))
                }
            }
        } else if selectedCategory == YEARLY_CATEGORY {
            lblDateTitle.text = "Year"
            var yearArray:[Int] = []
            var itemArray:[String] = []
            if self.totalYearlyObjects.count > 0 {
                for i in 0...self.totalYearlyObjects.count - 1 {
                    if !yearArray.contains(Int(self.totalYearlyObjects[i].year)!) {
                        yearArray.append(Int(self.totalYearlyObjects[i].year)!)
                    }
                    if !itemArray.contains(self.totalYearlyObjects[i].itemName) {
                        itemArray.append(self.totalYearlyObjects[i].itemName)
                    }
                }
            }
            
            if itemArray.count > 0 {
                for i in 0...itemArray.count - 1 {
                    let strItem:String = itemArray[i]
                    let no = i
                    let selectedStatus = true
                    let color = self.getColor(no: i)
                    var tempItemList:[ItemSoldYearlyModel] = []
                    for k in 0...self.totalYearlyObjects.count - 1 {
                        if self.totalYearlyObjects[k].itemName == strItem {
                            tempItemList.append(self.totalYearlyObjects[k])
                        }
                    }
                    var barChartObjects:[BarChartModel] = []
                    for j in 0...yearArray.count - 1 {
                        let labelName = yearArray[j]
                        var amount = 0
                        if tempItemList.count > 0 {
                            for k in 0...tempItemList.count - 1 {
                                if Int(tempItemList[k].year)! == yearArray[j] {
                                    amount = tempItemList[k].itemCount
                                }
                            }
                        }
                        barChartObjects.append(BarChartModel(name: String(labelName), amount: String(amount)))
                        
                    }
                    
                    self.totalChartObjects.append(ItemSoldChartModel(name: strItem, no: String(no), chartArray: barChartObjects, color: color, status: selectedStatus))
                }
            }
        }
        
        
//        Show
//        if totalChartObjects.count > 0 {
//            initBarChart()
//            setBarChart(barChartArray: totalChartObjects)
//        }
        var tempChartObjects:[ItemSoldChartModel] = []
        if totalChartObjects.count != 0 {
            var selectedItemCount = 0;
            for i in 0...totalChartObjects.count - 1 {
                if totalChartObjects[i].selectedStatus {
                    selectedItemCount += 1
                    tempChartObjects.append(totalChartObjects[i])
                }
            }
            
            if selectedItemCount > 1 {
                self.barSingleChartView.isHidden = true
                self.barChatView.isHidden = false
                initBarChart()
                setBarChart(barChartArray: tempChartObjects)
            } else if selectedItemCount == 1 {
                self.axisFormatDelegate = self
                self.barSingleChartView.isHidden = false
                self.barChatView.isHidden = true
                
                self.barChartXValues = []
                self.barChartYValues = []
               
                var xAxisCount = tempChartObjects[0].barChartArrays.count
                if xAxisCount > 0 {
                    var singleChartArray = tempChartObjects[0].barChartArrays
                    self.singleBarChartColor = tempChartObjects[0].color
                    self.singleBarChartBranchName = tempChartObjects[0].itemName
                    var MinValue = Int(singleChartArray[0].labelName)!
                    var MaxValue = Int(singleChartArray[0].labelName)!
                    for i in 0...xAxisCount - 1 {
                        if MinValue > Int(singleChartArray[i].labelName)! {
                            MinValue = Int(singleChartArray[i].labelName)!
                        }
                        if MaxValue < Int(singleChartArray[i].labelName)! {
                            MaxValue = Int(singleChartArray[i].labelName)!
                        }
                    }
                    
                    for i in MinValue...MaxValue {
                        var IsExist = false
                        for j in 0...xAxisCount - 1 {
                            if i == Int(singleChartArray[j].labelName) {
                                self.barChartXValues.append(String(singleChartArray[j].labelName))
                                self.barChartYValues.append(Double(singleChartArray[j].amount) as! Double)
                                IsExist = true
                                break
                            }
                        }
                        if !IsExist {
                            self.barChartXValues.append(String(i))
                            self.barChartYValues.append(0.0)
                        }
                    }
                    singleCharCount = MaxValue - MinValue + 1
                }
                initSingleBarChart()
                setSingleChart(dataEntryX: barChartXValues, dataEntryY: barChartYValues)
            } else {
                barChatView.clear()
                barSingleChartView.clear()
                reportArrayList = []
                reportThreeCellTable.reloadData()
                dateCategoryCollectionView.reloadData()
            }
        }
        
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
        }  else {
            return reportArrayList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSoldNoticeTableViewCell") as! ItemSoldNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let report = reportArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportThreeTableViewCell") as! ReportThreeTableViewCell
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
        return dateCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = dateCategories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as!  DateCollectionViewCell
        cell.set(model: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        for i in (0...dateCategories.count - 1) {
            dateCategories[i].selectedStatus = false
        }
        dateCategories[selectedIndex].selectedStatus = true
        selectedCategory = dateCategories[selectedIndex].selectedCategory
        self.barChatView.clear()
        self.barSingleChartView.clear()
        reportArrayList = []
        bottomBarHeight.constant = 60.0
        reportThreeCellTable.reloadData()
        dateCategoryCollectionView.reloadData()
        sendRequestToServer(sqlNo: __REPORTS_ITEM_SOLD, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }

}

extension ItemSoldViewController:ItemSoldNoticeTableViewCellDelegate {
    func hideNotice(noticeNo: String) {
        selectedNoticeNo = noticeNo
        isClickHiddenBtn = true
        sendNoticeRequest(sqlNo: __NOTICE_HIDDEN, searchKey: noticeNo)
    }
    
    func activeNotice(noticeNo: String) {
        isClickActionBtn = true
        let noticeNoArr = noticeNo.split(separator: "_")
        selectedNoticeNo = String(noticeNoArr[0])
        sendNoticeRequest(sqlNo: __NOTICE_ACTED, searchKey: noticeNo)
    }
}

extension ItemSoldViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension ItemSoldViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}

extension ItemSoldViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return barChartXValues[Int(value)]
    }
}
