//
//  ReportViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/22.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import Charts
import QMUIKit
import SideMenu
import Motion

class ReportViewController: DemoBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    let labelColor = UIColor.init(red: 139/255, green: 200/255, blue: 219/255, alpha: 1)
    let mondayMarkColor = UIColor.init(red: 139/255, green: 200/255, blue: 219/255, alpha: 1)
    let tuesdayMarkColor = UIColor.init(red: 216/255, green: 27/255, blue: 96/255, alpha: 1)
    let wednesdayMarkColor = UIColor.green
    let thursdayMarkColor = UIColor.init(red: 255/255, green: 104/255, blue: 6/255, alpha: 1)
    let fridayMarkColor = UIColor.init(red: 255/255, green: 242/255, blue: 0, alpha: 1)
    let saturdayMarkColor = UIColor.init(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
    let sundayMarkColor = UIColor.init(red: 250/255, green: 129/255, blue: 129/255, alpha: 1)
    var timer = Timer()
    var machineTimer = Timer()
    var counter = 0
    
    var strUDID = ""
    var strNoticeUDID = ""
    var selectedReportDate = ""
    var selectedCategory = ""
    var noticeArrayList:[NoticeModel] = []
    var reportArrayList:[ReportModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    
    let HOURLY_CATEGORY = "Hourly"
    let DAILY_CATEGORY = "Daily"
    let WEEKLY_CATEGORY = "Weekly"
    let MONTHLY_CATEGORY = "Monthly"
    let YEARLY_CATEGORY = "Yearly"
    
    let MONDAY = 0
    let TUESDAY = 1
    let WEDNESDAY = 2
    let THURSDAY = 3
    let FRIDAY = 4
    let SATURDAY = 5
    let SUNDAY = 6
    
    let strMonday = "Monday"
    let strTuesday = "Tuesday"
    let strWednesday = "Wednesday"
    let strThursday = "Thursday"
    let strFriday = "Friday"
    let strSaturday = "Saturday"
    let strSunday = "Sunday"
    
    var firstMonthName = ""
    var secondMonthName = ""
    var thirdMonthName = ""
    var fourthMonthName = ""
    var fifthMonthName = ""
    var monthCount = 0
    var isSendEmail = false
    var weekMinimumNo = 0
    var weekMaximumNo = 0
    var monthMinimumNo = 0
    var monthMaximumNo = 0
    var dateCategories:[ReportDateModel] = []
    var totalHourlyObjects:[ReportHourlyModel] = []
    var mondayHourlyObjects:[ReportHourlyModel] = []
    var tuesdayHourlyObjects:[ReportHourlyModel] = []
    var wednesdayHourlyObjects:[ReportHourlyModel] = []
    var thursdayHourlyObjects:[ReportHourlyModel] = []
    var fridayHourlyObjects:[ReportHourlyModel] = []
    var saturdayHourlyObjects:[ReportHourlyModel] = []
    var sundayHourlyObjects:[ReportHourlyModel] = []

    var totalDailyObjects:[ReportDailyModel] = []
    var firstDailyObjects:[ReportDailyModel] = []
    var secondDailyObjects:[ReportDailyModel] = []
    var thirdDailyObjects:[ReportDailyModel] = []
    var fourthDailyObjects:[ReportDailyModel] = []
    var fifthDailyObjects:[ReportDailyModel] = []
    
    var totalWeeklyObjects:[ReportWeeklyModel] = []
    var totalMonthlyObjects:[ReportMonthlyModel] = []
    var totalYearlyObjects:[ReportYearlyModel] = []
    var barChartXValues:[String] = []
    var barChartYValues:[Double] = []
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    @IBOutlet weak var lblTime1Title: UILabel!
    @IBOutlet weak var lblTim2Title: UILabel!
    @IBOutlet weak var lblAmount2: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var barChatView: BarChartView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var wrapTableView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTableTitle: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var ReportThreeCellTable: UITableView!
    @IBOutlet weak var salesAmountTable: UITableView!
    @IBOutlet weak var reportTableWrapView: UIView!
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
                self.chartView.clear()
                self.barChatView.clear()
                self.sendRequestToServer(sqlNo: __REPORTS_SALES, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            }
        }
    }
    
    @IBAction func sendMail(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_SALES, categoryName: selectedCategory, selectedDate: selectedReportDate)
        isSendEmail = true
    }
    @IBAction func showSideMenu(_ sender: Any) {
        showSideMenu()
    }
    
    func showSideMenu(){
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
    
    func initUI() {
        mainView.layer.cornerRadius = mainViewCornerRadius
        topView.layer.cornerRadius = mainViewCornerRadius
        wrapTableView.layer.borderWidth = 1.0
        wrapTableView.layer.borderColor = UIColor.init(red: 233/255, green: 242/255, blue: 244/255, alpha: 1).cgColor
        
        reportTableWrapView.layer.borderWidth = 1.0
        reportTableWrapView.layer.borderColor = UIColor.init(red: 233/255, green: 242/255, blue: 244/255, alpha: 1).cgColor
        
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        lblDate.text = self.getCurrentDate()
        self.bottomBarHeight.constant = 60
        noticeTable.backgroundColor = UIColor.white
        dateCategoryCollectionView.backgroundColor = UIColor.white
        salesAmountTable.backgroundColor = UIColor.white
        ReportThreeCellTable.backgroundColor = UIColor.white
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
        selectedMenuIndex = 0
        prepareView()
        prepareTransition()
        
        initUI()
        initCategory()
        
        //self.selectedReportDate = __EMPTY_STRING
        self.selectedCategory = HOURLY_CATEGORY
        
        if MACHINE_ID == "" {
            cannotConnectView.isHidden = false
        } else {
            self.sendRequestToServer(sqlNo: __REPORTS_SALES, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate);
        }
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isReportPage = false
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        //self.setDataCount(Int(19), range: UInt32(30))
    }
    
    override func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        super.chartValueSelected(chartView, entry: entry, highlight: highlight)
//
//        self.chartView.centerViewToAnimated(xValue: entry.x, yValue: entry.y, axis: self.chartView.data!.getDataSetByIndex(highlight.dataSetIndex).axisDependency, duration: 1)
    }
    
    func initChart(categoryType:String) {
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.autoScaleMinMaxEnabled = false
        //chartView.
        chartView.pinchZoomEnabled = false
        
        let l = chartView.legend
        l.form = .square
        l.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
        l.textColor = labelColor
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = labelColor
        xAxis.gridColor = .white
        if categoryType == HOURLY_CATEGORY {
            xAxis.axisMaximum = 24
            xAxis.axisMinimum = 6
            xAxis.labelCount = 18
        } else if categoryType == DAILY_CATEGORY {
            xAxis.axisMaximum = 31
            xAxis.axisMinimum = 0
            xAxis.labelCount = 16
        } else if categoryType == WEEKLY_CATEGORY {
            xAxis.axisMaximum = Double(weekMaximumNo)
            xAxis.axisMinimum = Double(weekMinimumNo)
            xAxis.labelCount = weekMaximumNo - weekMinimumNo
        } else if categoryType == MONTHLY_CATEGORY {
            xAxis.axisMaximum = Double(monthMaximumNo)
            xAxis.axisMinimum = Double(monthMinimumNo)
            xAxis.labelCount = monthMaximumNo - monthMinimumNo
        }
       
        xAxis.labelPosition = .bottom
        xAxis.axisLineColor = labelColor
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = labelColor
        leftAxis.gridColor = .white
        leftAxis.axisLineColor = labelColor
        leftAxis.labelCount = 5
        leftAxis.axisMinimum = 0
        
        chartView.rightAxis.enabled = false
        
        //chartView.animate(xAxisDuration: 2.5)
    }
    
    func initBarChart() {
        barChatView.delegate = self

        barChatView.chartDescription?.enabled = false
        barChatView.maxVisibleCount = 60
        barChatView.pinchZoomEnabled = false
        barChatView.drawBarShadowEnabled = false
        barChatView.doubleTapToZoomEnabled = false
        barChatView.scaleXEnabled = false
        barChatView.scaleYEnabled = false
        barChatView.isUserInteractionEnabled = false
        let xAxis = barChatView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = labelColor
        xAxis.gridColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        xAxis.axisLineColor = labelColor
        xAxis.labelCount = totalYearlyObjects.count

        let leftAxis = barChatView.leftAxis
        leftAxis.labelTextColor = labelColor
        leftAxis.gridColor = .white
        leftAxis.axisLineColor = labelColor
        leftAxis.labelCount = 5
        leftAxis.axisMinimum = 0

        barChatView.rightAxis.enabled = false
        barChatView.tintColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)

        barChatView.legend.enabled = false
                
        barChatView.animate(yAxisDuration: 1.0)
    }
    
    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
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
        chartDataSet.colors = [mondayMarkColor]
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
        chartData.barWidth = Double(0.4)
        barChatView.data = chartData
        let xAxisValue = barChatView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
    }
    
    func setWeeklyData() {
        if self.totalWeeklyObjects.count > 0 {
            let yVals1 = (0..<self.totalWeeklyObjects.count).map { (i) -> ChartDataEntry in
                let  yValue = totalWeeklyObjects[i].amount
                let xValue = totalWeeklyObjects[i].weekNo
                return ChartDataEntry(x: Double(xValue), y: Double(yValue))
            }
            
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: "week", markColor: mondayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
        }
    }
    
    func setMonthlyData() {
        if self.totalMonthlyObjects.count > 0 {
            let yVals1 = (0..<self.totalMonthlyObjects.count).map { (i) -> ChartDataEntry in
                let yValue = totalMonthlyObjects[i].amount
                let xValue = totalMonthlyObjects[i].monthNo
                return ChartDataEntry(x: Double(xValue), y: Double(yValue))
            }
            
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: "month", markColor: mondayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
        }
    }
    
    func setDailyData(count:Int, monthNames:[String]) {
        switch(count) {
        case 1:
            let yVals1 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.firstDailyObjects.count > 0 {
                    for j in (0...self.firstDailyObjects.count - 1) {
                        if i == firstDailyObjects[j].day {
                            value = firstDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: monthNames[0], markColor: mondayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
            break
        case 2:
            let yVals1 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.firstDailyObjects.count > 0 {
                    for j in (0...self.firstDailyObjects.count - 1) {
                        if i == firstDailyObjects[j].day {
                            value = firstDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            
            let yVals2 = (0..<32).map { (i) -> ChartDataEntry in
                   var value = 0
                   if self.secondDailyObjects.count > 0 {
                       for j in (0...self.secondDailyObjects.count - 1) {
                           if i == secondDailyObjects[j].day {
                               value = secondDailyObjects[j].amount
                           }
                       }
                   }
                   return ChartDataEntry(x: Double(i), y: Double(value))
               }
            
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: monthNames[0], markColor: mondayMarkColor),
                                                self.setChartHeader(values: yVals2, name: monthNames[1], markColor: tuesdayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
            break
        case 3:
            let yVals1 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.firstDailyObjects.count > 0 {
                    for j in (0...self.firstDailyObjects.count - 1) {
                        if i == firstDailyObjects[j].day {
                            value = firstDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            
            let yVals2 = (0..<32).map { (i) -> ChartDataEntry in
                   var value = 0
                   if self.secondDailyObjects.count > 0 {
                       for j in (0...self.secondDailyObjects.count - 1) {
                           if i == secondDailyObjects[j].day {
                               value = secondDailyObjects[j].amount
                           }
                       }
                   }
                   return ChartDataEntry(x: Double(i), y: Double(value))
               }
            let yVals3 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.thirdDailyObjects.count > 0 {
                    for j in (0...self.thirdDailyObjects.count - 1) {
                        if i == thirdDailyObjects[j].day {
                            value = thirdDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: monthNames[0], markColor: mondayMarkColor),
                                                self.setChartHeader(values: yVals2, name: monthNames[1], markColor: tuesdayMarkColor),
                                                self.setChartHeader(values: yVals3, name: monthNames[2], markColor: wednesdayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
            break
        case 4:
            let yVals1 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.firstDailyObjects.count > 0 {
                    for j in (0...self.firstDailyObjects.count - 1) {
                        if i == firstDailyObjects[j].day {
                            value = firstDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            
            let yVals2 = (0..<32).map { (i) -> ChartDataEntry in
                   var value = 0
                   if self.secondDailyObjects.count > 0 {
                       for j in (0...self.secondDailyObjects.count - 1) {
                           if i == secondDailyObjects[j].day {
                               value = secondDailyObjects[j].amount
                           }
                       }
                   }
                   return ChartDataEntry(x: Double(i), y: Double(value))
               }
            let yVals3 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.thirdDailyObjects.count > 0 {
                    for j in (0...self.thirdDailyObjects.count - 1) {
                        if i == thirdDailyObjects[j].day {
                            value = thirdDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            let yVals4 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.fourthDailyObjects.count > 0 {
                    for j in (0...self.fourthDailyObjects.count - 1) {
                        if i == fourthDailyObjects[j].day {
                            value = fourthDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: monthNames[0], markColor: mondayMarkColor),
                                                self.setChartHeader(values: yVals2, name: monthNames[1], markColor: tuesdayMarkColor),
                                                self.setChartHeader(values: yVals3, name: monthNames[2], markColor: wednesdayMarkColor),
                                                self.setChartHeader(values: yVals4, name: monthNames[3], markColor: thursdayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
            break
        case 5:
            let yVals1 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.firstDailyObjects.count > 0 {
                    for j in (0...self.firstDailyObjects.count - 1) {
                        if i == firstDailyObjects[j].day {
                            value = firstDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            
            let yVals2 = (0..<32).map { (i) -> ChartDataEntry in
                   var value = 0
                   if self.secondDailyObjects.count > 0 {
                       for j in (0...self.secondDailyObjects.count - 1) {
                           if i == secondDailyObjects[j].day {
                               value = secondDailyObjects[j].amount
                           }
                       }
                   }
                   return ChartDataEntry(x: Double(i), y: Double(value))
               }
            let yVals3 = (0..<32).map { (i) -> ChartDataEntry in
                var value = 0
                if self.thirdDailyObjects.count > 0 {
                    for j in (0...self.thirdDailyObjects.count - 1) {
                        if i == thirdDailyObjects[j].day {
                            value = thirdDailyObjects[j].amount
                        }
                    }
                }
                return ChartDataEntry(x: Double(i), y: Double(value))
            }
            let yVals4 = (0..<32).map { (i) -> ChartDataEntry in
                   var value = 0
                   if self.fourthDailyObjects.count > 0 {
                       for j in (0...self.fourthDailyObjects.count - 1) {
                           if i == fourthDailyObjects[j].day {
                               value = fourthDailyObjects[j].amount
                           }
                       }
                   }
                   return ChartDataEntry(x: Double(i), y: Double(value))
               }
            let yVals5 = (0..<32).map { (i) -> ChartDataEntry in
                   var value = 0
                   if self.fifthDailyObjects.count > 0 {
                       for j in (0...self.fifthDailyObjects.count - 1) {
                           if i == fifthDailyObjects[j].day {
                               value = fifthDailyObjects[j].amount
                           }
                       }
                   }
                   return ChartDataEntry(x: Double(i), y: Double(value))
               }
            let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: monthNames[0], markColor: mondayMarkColor),
                                                self.setChartHeader(values: yVals2, name: monthNames[1], markColor: tuesdayMarkColor),
                                                self.setChartHeader(values: yVals3, name: monthNames[2], markColor: wednesdayMarkColor),
                                                self.setChartHeader(values: yVals4, name: monthNames[3], markColor: thursdayMarkColor),
                                                self.setChartHeader(values: yVals5, name: monthNames[4], markColor: fridayMarkColor)])
            data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
            data.setValueFont(.systemFont(ofSize: 9))
            
            chartView.data = data
            break
        default:
            break
        }
    }
    
    func setChartHeader(values:[ChartDataEntry], name:String, markColor:UIColor) -> LineChartDataSet{
        let set1 = LineChartDataSet(entries: values, label: name)
        set1.axisDependency = .left
        set1.setColor(markColor)
        set1.setCircleColor(markColor)
        set1.lineWidth = 2
        set1.circleRadius = 3
        set1.fillAlpha = 65/255
        set1.fillColor = markColor
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        return set1
    }
    
    func setHourlyData(count: Int) {
        let yVals1 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.mondayHourlyObjects.count > 0 {
                for j in (0...self.mondayHourlyObjects.count - 1) {
                    if i == mondayHourlyObjects[j].day {
                        value = mondayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        let yVals2 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.tuesdayHourlyObjects.count > 0 {
                for j in (0...self.tuesdayHourlyObjects.count - 1) {
                    if i == tuesdayHourlyObjects[j].day {
                        value = tuesdayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        let yVals3 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.wednesdayHourlyObjects.count > 0 {
                for j in (0...self.wednesdayHourlyObjects.count - 1) {
                    if i == wednesdayHourlyObjects[j].day {
                        value = wednesdayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        let yVals4 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.thursdayHourlyObjects.count > 0 {
                for j in (0...self.thursdayHourlyObjects.count - 1) {
                    if i == thursdayHourlyObjects[j].day {
                        value = thursdayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        let yVals5 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.fridayHourlyObjects.count > 0 {
                for j in (0...self.fridayHourlyObjects.count - 1) {
                    if i == fridayHourlyObjects[j].day {
                        value = fridayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        let yVals6 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.saturdayHourlyObjects.count > 0 {
                for j in (0...self.saturdayHourlyObjects.count - 1) {
                    if i == saturdayHourlyObjects[j].day {
                        value = saturdayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        let yVals7 = (6..<25).map { (i) -> ChartDataEntry in
            var value = 0
            if self.sundayHourlyObjects.count > 0 {
                for j in (0...self.sundayHourlyObjects.count - 1) {
                    if i == sundayHourlyObjects[j].day {
                        value = sundayHourlyObjects[j].amount
                    }
                }
            }
            return ChartDataEntry(x: Double(i), y: Double(value))
        }
        
        let data = LineChartData(dataSets: [self.setChartHeader(values: yVals1, name: "mon", markColor: mondayMarkColor),
                                            self.setChartHeader(values: yVals2, name: "tue", markColor: tuesdayMarkColor),
                                            self.setChartHeader(values: yVals3, name: "wed", markColor: wednesdayMarkColor),
                                            self.setChartHeader(values: yVals4, name: "tur", markColor: thursdayMarkColor),
                                            self.setChartHeader(values: yVals5, name: "fri", markColor: fridayMarkColor),
                                            self.setChartHeader(values: yVals6, name: "sat", markColor: saturdayMarkColor),
                                            self.setChartHeader(values: yVals7, name: "sun", markColor: sundayMarkColor)])
        data.setValueTextColor(UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0))
        data.setValueFont(.systemFont(ofSize: 9))
        
        chartView.data = data
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
    
    func startConnectTimer() {
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getOffers), userInfo: nil, repeats: true)
    }
    func stopTimer() {
        timer.invalidate()
        counter = 0
    }
    
    @objc func getOffers() {
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
                self.stopTimer()
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
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    self.isSendEmail = false
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
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.totalHourlyObjects = []
                self.totalDailyObjects = []
                self.firstDailyObjects = []
                self.secondDailyObjects = []
                self.thirdDailyObjects = []
                self.fourthDailyObjects = []
                self.fifthDailyObjects = []
                self.totalWeeklyObjects = []
                self.totalMonthlyObjects = []
                self.totalYearlyObjects = []
                
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
                        if self.selectedCategory == self.HOURLY_CATEGORY {
                            for i in (0...tempResult.count - 1) {
                                let tempArr:NSArray = tempResult[i] as! NSArray
                                let dateTime:String = tempArr[0] as! String
                                let weekDay:String = tempArr[1] as! String
                                let rTime:String = tempArr[2] as! String
                                let amount:String = tempArr[3] as! String
                                self.totalHourlyObjects.append(ReportHourlyModel(no: String(i + 1), reportDateTime: dateTime, weekDay: weekDay, day: Int(rTime)!, amount: Int(Float(amount)!)))
                            }
                            
                            //if self.totalHourlyObjects.count > 0 {
                                self.showHourlyInformation()
                            //}
                        } else if self.selectedCategory == self.DAILY_CATEGORY {
                            var tempMonthName = ""
                            var monthFlag = 0
                            for i in (0...tempResult.count - 1) {
                                let tempArr:NSArray = tempResult[i] as! NSArray
                                var weekDay:String = tempArr[0] as! String
                                let month:String = tempArr[1] as! String
                                let day:String = tempArr[2] as! String
                                let weekNo:String = tempArr[3] as! String
                                weekDay = tempArr[4] as! String
                                let amount:String = tempArr[5] as! String
                               
                                if tempMonthName != month {
                                    monthFlag += 1
                                    tempMonthName = month
                                    self.monthCount = monthFlag
                                }
                                
                                if monthFlag == 1 {
                                    self.firstMonthName = tempMonthName
                                    self.firstDailyObjects.append(ReportDailyModel(no: String(i + 1), weekDay: weekDay, month: month, weekNo: weekNo, day: Int(day)!, amount: Int(Float(amount)!)))
                                } else if monthFlag == 2 {
                                    self.secondMonthName = tempMonthName
                                    self.secondDailyObjects.append(ReportDailyModel(no: String(i + 1), weekDay: weekDay, month: month, weekNo: weekNo, day: Int(day)!, amount: Int(Float(amount)!)))
                                } else if monthFlag == 3 {
                                    self.thirdMonthName = tempMonthName
                                    self.thirdDailyObjects.append(ReportDailyModel(no: String(i + 1), weekDay: weekDay, month: month, weekNo: weekNo, day: Int(day)!, amount: Int(Float(amount)!)))
                                } else if monthFlag == 4 {
                                    self.fourthMonthName = tempMonthName
                                    self.fourthDailyObjects.append(ReportDailyModel(no: String(i + 1), weekDay: weekDay, month: month, weekNo: weekNo, day: Int(day)!, amount: Int(Float(amount)!)))
                                } else if monthFlag == 5 {
                                    self.fifthMonthName = tempMonthName
                                    self.fifthDailyObjects.append(ReportDailyModel(no: String(i + 1), weekDay: weekDay, month: month, weekNo: weekNo, day: Int(day)!, amount: Int(Float(amount)!)))
                                }
                                self.totalDailyObjects.append(ReportDailyModel(no: String(i + 1), weekDay: weekDay, month: month, weekNo: weekNo, day: Int(day)!, amount: Int(Float(amount)!)))
                            }
                            
                            //if self.totalDailyObjects.count > 0 {
                                self.showDailyInformation()
                            //}
                        } else if self.selectedCategory == self.WEEKLY_CATEGORY {
                            for i in (0...tempResult.count - 1) {
                                 let tempArr:NSArray = tempResult[i] as! NSArray
                                 let weekNo:String = tempArr[0] as! String
                                 let amount:String = tempArr[1] as! String
                                 self.totalWeeklyObjects.append(ReportWeeklyModel(weekNo: Int(weekNo)!, amount: Int(Float(amount)!)))
                            }
                            self.showWeelyInformation()
                        } else if self.selectedCategory == self.MONTHLY_CATEGORY {
                            for i in (0...tempResult.count - 1) {
                                let tempArr:NSArray = tempResult[i] as! NSArray
                                let year:String = tempArr[0] as! String
                                let month:String = tempArr[1] as! String
                                let monthNo:String = tempArr[2] as! String
                                let amount:String = tempArr[3] as! String
                                self.totalMonthlyObjects.append(ReportMonthlyModel(year: Int(year)!, monthName: month, monthNo: Int(monthNo)!, amount: Int(Float(amount)!)))
                            }
                            self.showMonthlyInformation()
                        } else if self.selectedCategory == self.YEARLY_CATEGORY {
                            for i in (0...tempResult.count - 1) {
                                let tempArr:NSArray = tempResult[i] as! NSArray
                                let year:String = tempArr[0] as! String
                                let amount:String = tempArr[1] as! String
                                self.totalYearlyObjects.append(ReportYearlyModel(year: Int(year)!, amount: Int(Float(amount)!)))
                            }
                            self.showYearlyInformation()
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
    
    func showReportList() {
        self.reportArrayList = []
        if self.selectedCategory == self.HOURLY_CATEGORY {
            lblTime1Title.text = "Date"
            lblTim2Title.text = "Time"
            wrapTableView.isHidden = true
            reportTableWrapView.isHidden = false
            
            if totalHourlyObjects.count > 0 {
                for i in (0...totalHourlyObjects.count - 1) {
                    let amount = totalHourlyObjects[i].amount
                    let title1 = totalHourlyObjects[i].weekDay
                    let title2 = String(totalHourlyObjects[i].day)
                    self.reportArrayList.append(ReportModel(no: String(i), title1: title1, title2: title2, amount: amount))
                }
            }
            
            ReportThreeCellTable.reloadData()
        }
        
        else if self.selectedCategory == self.DAILY_CATEGORY {
            lblTime1Title.text = "Month"
            lblTim2Title.text = "Date"
            wrapTableView.isHidden = true
            reportTableWrapView.isHidden = false
            
            if totalDailyObjects.count > 0{
                for i in (0...totalDailyObjects.count - 1) {
                    let amount = totalDailyObjects[i].amount
                    let title1 = totalDailyObjects[i].month
                    let title2 = String(totalDailyObjects[i].day)
                    self.reportArrayList.append(ReportModel(no: String(i), title1: title1, title2: title2, amount: amount))
                }
            }
            
             ReportThreeCellTable.reloadData()
        }
        
        else if self.selectedCategory == self.WEEKLY_CATEGORY {
            wrapTableView.isHidden = false
            reportTableWrapView.isHidden = true
            
            lblTableTitle.text = "Week"
            if totalWeeklyObjects.count > 0 {
                for i in (0...totalWeeklyObjects.count - 1) {
                    let amount = totalWeeklyObjects[i].amount
                    let title = String(totalWeeklyObjects[i].weekNo)
                    self.reportArrayList.append(ReportModel(no: String(i), title1: title, title2: "", amount: amount))
                }
            }
            
            salesAmountTable.reloadData()
        }
        
        else if self.selectedCategory == self.MONTHLY_CATEGORY {
            lblTime1Title.text = "Year"
            lblTim2Title.text = "Month"
            wrapTableView.isHidden = true
            reportTableWrapView.isHidden = false
            
            if totalMonthlyObjects.count > 0{
                for i in (0...totalMonthlyObjects.count - 1) {
                    let amount = totalMonthlyObjects[i].amount
                    let title1 = String(totalMonthlyObjects[i].year)
                    let title2 = totalMonthlyObjects[i].monthName
                    self.reportArrayList.append(ReportModel(no: String(i), title1: title1, title2: title2, amount: amount))
                }
            }
            
            ReportThreeCellTable.reloadData()
        }
        
        else if self.selectedCategory == self.YEARLY_CATEGORY {
            lblTableTitle.text = "Year"
            wrapTableView.isHidden = false
            reportTableWrapView.isHidden = true
            if totalYearlyObjects.count > 0{
                for i in (0...totalYearlyObjects.count - 1) {
                    let amount = totalYearlyObjects[i].amount
                    let title = String(totalYearlyObjects[i].year)
                    self.reportArrayList.append(ReportModel(no: String(i), title1: title, title2: "", amount: amount))
                }
            }
            
            salesAmountTable.reloadData()
        }
    }
    
    func showHourlyInformation() {
        self.showReportList()
        initChart(categoryType: HOURLY_CATEGORY)
        
        self.mondayHourlyObjects = []
        self.tuesdayHourlyObjects = []
        self.wednesdayHourlyObjects = []
        self.thursdayHourlyObjects = []
        self.fridayHourlyObjects = []
        self.saturdayHourlyObjects = []
        self.sundayHourlyObjects = []
        
        for i in (0...totalHourlyObjects.count - 1) {
            if totalHourlyObjects[i].weekDay == strMonday {
                mondayHourlyObjects.append(totalHourlyObjects[i])
            } else if totalHourlyObjects[i].weekDay == strTuesday {
                tuesdayHourlyObjects.append(totalHourlyObjects[i])
            } else if totalHourlyObjects[i].weekDay == strWednesday {
                wednesdayHourlyObjects.append(totalHourlyObjects[i])
            } else if totalHourlyObjects[i].weekDay == strThursday {
                thursdayHourlyObjects.append(totalHourlyObjects[i])
            } else if totalHourlyObjects[i].weekDay == strFriday {
                fridayHourlyObjects.append(totalHourlyObjects[i])
            } else if totalHourlyObjects[i].weekDay == strSaturday {
                saturdayHourlyObjects.append(totalHourlyObjects[i])
            } else if totalHourlyObjects[i].weekDay == strSunday {
                sundayHourlyObjects.append(totalHourlyObjects[i])
            }
        }
        
        self.setHourlyData(count: 19)
    }
    
    func showDailyInformation() {
        self.showReportList()
        var monthNames:[String] = []
        initChart(categoryType: DAILY_CATEGORY)
        switch(self.monthCount) {
        case 0:
            break
        case 1:
            monthNames.append(firstMonthName)
            self.setDailyData(count: monthCount, monthNames: monthNames)
        case 2:
            monthNames.append(firstMonthName)
            monthNames.append(secondMonthName)
            self.setDailyData(count: monthCount, monthNames: monthNames)
        case 3:
            monthNames.append(firstMonthName)
            monthNames.append(secondMonthName)
            monthNames.append(thirdMonthName)
            self.setDailyData(count: monthCount, monthNames: monthNames)
        case 4:
            monthNames.append(firstMonthName)
            monthNames.append(secondMonthName)
            monthNames.append(thirdMonthName)
            monthNames.append(fourthMonthName)
            self.setDailyData(count: monthCount, monthNames: monthNames)
        case 5:
            monthNames.append(firstMonthName)
            monthNames.append(secondMonthName)
            monthNames.append(thirdMonthName)
            monthNames.append(fourthMonthName)
            monthNames.append(fifthMonthName)
            self.setDailyData(count: monthCount, monthNames: monthNames)
        default:
            break
        }
    }
    
    func showWeelyInformation() {
        self.showReportList()
        weekMinimumNo = 0
        weekMaximumNo = 0
        if totalWeeklyObjects.count > 0 {
            for i in (0...totalWeeklyObjects.count - 1) {
                let weekNo = totalWeeklyObjects[i].weekNo
                if i == 0 {
                    weekMaximumNo = Int(weekNo)
                    weekMinimumNo = Int(weekNo)
                }
                
                if Int(weekNo) > weekMaximumNo {
                    weekMaximumNo = Int(weekNo)
                }
                
                if Int(weekNo) < weekMinimumNo {
                    weekMinimumNo = Int(weekNo)
                }
            }
        }
        
        initChart(categoryType: WEEKLY_CATEGORY)
        
        self.setWeeklyData()
    }
    
    
    func showMonthlyInformation() {
        self.showReportList()
        monthMinimumNo = 0
        monthMaximumNo = 0
        if totalMonthlyObjects.count > 0 {
            for i in (0...totalMonthlyObjects.count - 1) {
                let monthNo = totalMonthlyObjects[i].monthNo
                if i == 0 {
                    monthMaximumNo = Int(monthNo)
                    monthMinimumNo = Int(monthNo)
                }
                
                if Int(monthNo) > monthMaximumNo {
                    monthMaximumNo = Int(monthNo)
                }
                
                if Int(monthNo) < monthMinimumNo {
                    monthMinimumNo = Int(monthNo)
                }
            }
        }
        initChart(categoryType: MONTHLY_CATEGORY)
        
        self.setMonthlyData()
    }
    
    func showYearlyInformation() {
        showReportList()
        self.axisFormatDelegate = self
        self.barChartXValues = []
        self.barChartYValues = []
        if totalYearlyObjects.count > 0 {
            for i in (0...totalYearlyObjects.count - 1) {
                //self.barChartXValues.append(" ")
                self.barChartXValues.append(String(totalYearlyObjects[i].year))
                
                //self.barChartYValues.append(0)
                self.barChartYValues.append(Double(totalYearlyObjects[i].amount))
            }
        }
//        self.barChartXValues.append(" ")
//        self.barChartYValues.append(0)
        
        initBarChart()
        setChart(dataEntryX: barChartXValues, dataEntryY: barChartYValues)
        
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
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
       
        timer.invalidate()
        counter = 0
        self.showReportList()
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
        dateCategoryCollectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else if tableView == salesAmountTable {
            return reportArrayList.count
        } else {
            return reportArrayList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportNoticeTableViewCell") as! ReportNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else if tableView == salesAmountTable {
            let report = reportArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SalesAmountTableViewCell") as! SalesAmountTableViewCell
            cell.set(model: report)
            cell.selectionStyle = .none
            return cell
        } else {
            let report = reportArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportThreeTableViewCell") as! ReportThreeTableViewCell
            cell.set(model: report)
            cell.selectionStyle = .none
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
        self.chartView.clear()
        self.barChatView.clear()
        if selectedIndex == 4 {
            self.chartView.isHidden = true
            self.barChatView.isHidden = false
        } else {
            self.chartView.isHidden = false
            self.barChatView.isHidden = true
        }
        bottomBarHeight.constant = 60.0
        dateCategoryCollectionView.reloadData()
        self.reportArrayList = []
        salesAmountTable.reloadData()
        ReportThreeCellTable.reloadData()
        sendRequestToServer(sqlNo: __REPORTS_SALES, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
}

extension ReportViewController:ReportNoticeTableViewCellDelegate {
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

extension Date {
    
    func dateString(_ format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}

extension ReportViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return barChartXValues[Int(value)]
    }
}

extension ReportViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension ReportViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
