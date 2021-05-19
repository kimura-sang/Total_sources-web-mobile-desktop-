//
//  MoreViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import SideMenu
import Motion


class MoreViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    
    var strUDID = ""
    var strNoticeUDID = ""
    var selectedReportDate = "";
    var selectedCategory = "";
    var noticeArrayList:[NoticeModel] = []
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var isNoticeRequest = false
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var lblSelectedDate: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var btnMonthlySalesReport: UIButton!
    @IBOutlet weak var monthlySalesReportView: UIView!
    @IBOutlet weak var btnItemSoldBreakdown: UIButton!
    @IBOutlet weak var itemSoldBreakdownView: UIView!
    @IBOutlet weak var btnPayInOut: UIButton!
    @IBOutlet weak var payInOutView: UIView!
    @IBOutlet weak var btnFinancialStatement: UIButton!
    @IBOutlet weak var financialStatementView: UIView!
    @IBOutlet weak var btnCashSummary: UIButton!
    @IBOutlet weak var cashSummaryView: UIView!
    @IBOutlet weak var btnCustomerList: UIButton!
    @IBOutlet weak var customerListView: UIView!
    @IBOutlet weak var btnOfferItemList: UIButton!
    @IBOutlet weak var offerItemListView: UIView!
    @IBOutlet weak var btnInventoryReport: UIButton!
    @IBOutlet weak var inventoryReportView: UIView!
    @IBOutlet weak var btnTopSoldItem: UIButton!
    @IBOutlet weak var topSoldItemView: UIView!
    @IBOutlet weak var btnLeastSoldItem: UIButton!
    @IBOutlet weak var leastSoldItemView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        selectedReportDate = __EMPTY_STRING;
        selectedCategory = __EMPTY_STRING;
        initUI()
    }
    
    @IBOutlet weak var lblCannotDescription: UILabel!
    @IBAction func tryConnectAgain(_ sender: Any) {
        isNoticeRequest = false
        QMUITips.showLoading(" Loading ", in: self.view)
        cannotConnectView.isHidden = true
        startConnectTimer()
    }
    var isUpSlide = true
    var isSliding = false
    @IBAction func showNoticeTable(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: view)
        if velocity.y > 0 {
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
                    self!.isClickHiddenBtn = false
                    self!.isClickActionBtn = false
                    self?.sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
                    self!.isSliding = true
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
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
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        bottomBarHeight.constant = 60.0
        noticeTable.backgroundColor = UIColor.white
        
        btnMonthlySalesReport.layer.cornerRadius = 15
        btnItemSoldBreakdown.layer.cornerRadius = 15
        btnPayInOut.layer.cornerRadius = 15
        btnFinancialStatement.layer.cornerRadius = 15
        btnCashSummary.layer.cornerRadius = 15
        btnCustomerList.layer.cornerRadius = 15
        btnOfferItemList.layer.cornerRadius = 15
        btnInventoryReport.layer.cornerRadius = 15
        btnTopSoldItem.layer.cornerRadius = 15
        btnLeastSoldItem.layer.cornerRadius = 15
        mainView.layer.cornerRadius = mainViewCornerRadius
        topView.layer.cornerRadius = mainViewCornerRadius
//        monthlySalesReportView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        itemSoldBreakdownView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        payInOutView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        financialStatementView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        cashSummaryView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        customerListView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        offerItemListView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        inventoryReportView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        topSoldItemView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        leastSoldItemView.createTopDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        leastSoldItemView.createBottomDottedLine(width: 1.0, color: UIColor.black.cgColor)
//        monthlySalesReportView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        itemSoldBreakdownView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        payInOutView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        financialStatementView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        cashSummaryView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        customerListView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        offerItemListView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        inventoryReportView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        topSoldItemView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
//        leastSoldItemView.createLeftDottedLine(height: 1.0, color: UIColor.black.cgColor)
        lblSelectedDate.text = self.getCurrentDate()
        //selectedReportDate = __EMPTY_STRING
        selectedCategory = __EMPTY_STRING
    }
    
    
    

    
//    @IBAction func sendEmailToCustomer(_ sender: Any) {
//        sendRequestToServer(sqlNo: __EMAIL_REPORTS_CUSTOMER_LIST, categoryName: selectedCategory, selectedDate: selectedDate)
//    }
//    @IBAction func sendEmailProductItems(_ sender: Any) {
//        sendRequestToServer(sqlNo: __EMAIL_REPORTS_PRODUCT_ITEM_LIST, categoryName: selectedCategory, selectedDate: selectedDate)
//    }
//    @IBAction func sendEmailInventory(_ sender: Any) {
//        sendRequestToServer(sqlNo: __EMAIL_REPORTS_INVENTORY, categoryName: selectedCategory, selectedDate: selectedDate)
//    }
//    @IBAction func sendEmailTopItems(_ sender: Any) {
//        sendRequestToServer(sqlNo: __EMAIL_REPORTS_TOP_ITEMS, categoryName: selectedCategory, selectedDate: selectedDate)
//    }
//    @IBAction func sendEmailLeastItems(_ sender: Any) {
//        sendRequestToServer(sqlNo: __EMAIL_REPORTS_LEAST_ITEMS, categoryName: selectedCategory, selectedDate: selectedDate)
//    }
    @IBAction func sendMailForMSReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_MONTHLY_REPORT, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func sendMailForISBReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_ITEM_SOLD_BREAKDOWN, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    @IBAction func sendMailForPIPOReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_PAYINS_PAYOUT, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func sendMailForFSReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_FINANCIAL_STATEMENT, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func sendMailForPCSReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_PETTY_CASH, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func sendMailForCLReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_CUSTOMER_LIST, categoryName: selectedCategory, selectedDate: selectedReportDate)
        
    }
    @IBAction func sendMailForOILReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_PRODUCT_ITEM_LIST, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func sendMailForIReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_INVENTORY, categoryName: selectedCategory, selectedDate: selectedReportDate)
        
    }
    @IBAction func sendMailForTSIReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_TOP_ITEMS, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func sendMailFOrLSIReport(_ sender: Any) {
        sendRequestToServer(sqlNo: __EMAIL_REPORTS_LEAST_ITEMS, categoryName: selectedCategory, selectedDate: selectedReportDate)
    }
    
    @IBAction func showSideMenu(_ sender: Any) {
        showSideMenu()
    }
    
    @IBAction func setDate(_ sender: Any) {
        RPicker.selectDate { (selectedDate) in
            // TODO: Your implementation for date
            self.selectedReportDate = selectedDate.dateString("yyyy-MM-dd")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            if let ddDate = dateFormatter.date(from:self.selectedReportDate) {
                dateFormatter.dateFormat = "MMMM dd, yyyy"///this is what you want to convert format
                let timeStamp = dateFormatter.string(from: ddDate)
                self.lblSelectedDate.text = timeStamp
                //self.sendRequestToServer(sqlNo: __REPORTS_ITEM_SOLD, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            } else {
                self.lblSelectedDate.text = __DEFAULT_STRING
                //self.sendRequestToServer(sqlNo: __REPORTS_ITEM_SOLD, categoryName: self.selectedCategory, selectedDate: self.selectedReportDate)
            }
        }
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
                self.getEmailSendStatus()
            }
        }
    }
    
    func getEmailSendStatus() {
        HttpRequest.getDashboardData(UDID: strUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
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
                    if sendStatus.contains("Success"){
                        self.showDialog(title: "", message: "Email sending success")
                    } else {
                        self.showDialog(title: "", message: "Email sending failed")
                    }
                } else {
                    if self.counter >=  __SERVER_CONNECTION_COUNT {
                        QMUITips.hideAllTips()
                        self.stopTimer()
                        self.cannotConnectView.isHidden = false
                          //self.cannotConnectView.isHidden = false
                    }
                }
            }
        })
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
        
        timer.invalidate()
        counter = 0
        
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
                        }
                    }
                }
            }
        })
    }
}

extension MoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return noticeArrayList.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreNoticeTableViewCell") as! MoreNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
extension MoreViewController:MoreNoticeTableViewCellDelegate {
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

extension MoreViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension MoreViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
