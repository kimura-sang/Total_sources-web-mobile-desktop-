//
//  TransactionViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import QMUIKit
import Motion
import PullToRefresh
private let PageSize = 20

class TransactionViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var transactions:[TransactionModel] = []
    var noticeArrayList:[NoticeModel] = []
    var strShiftNo = "";
    var strShiftDate = "";
    var strShiftName = "";
    var strOpenDate = "";
    var strOpenName = "";
    var strCloseDate = "";
    var strCloseName = "";
    var strGrossSale = "";
    var strCashReceived = "";
    var strCashCount = "";
    var strBankDeposit = "";
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var transactionShidfId = ""
    fileprivate var dataSourceCount = PageSize
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var toggleView: UIView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblShiftName: UILabel!
    @IBOutlet weak var lblShiftDate: UILabel!
    @IBOutlet weak var lblOpenStaffName: UILabel!
    @IBOutlet weak var lblOpenStaffDate: UILabel!
    @IBOutlet weak var lblCloseStaffName: UILabel!
    @IBOutlet weak var lblCloseStaffDate: UILabel!
    @IBOutlet weak var mainValueView: UIView!
    @IBOutlet weak var lblGrossSales: UILabel!
    @IBOutlet weak var lblCashReceived: UILabel!
    @IBOutlet weak var lblCashCount: UILabel!
    @IBOutlet weak var lblBackDeposit: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBOutlet weak var shiftNameView: UIView!
    @IBOutlet weak var openStaffView: UIView!
    @IBOutlet weak var imgOpenStaff: UIImageView!
    @IBOutlet weak var closeStaffView: UIView!
    @IBOutlet weak var imgCloseStaff: UIImageView!
    
    @IBAction func tryToggleOn(_ sender: Any) {
        self.bottomBarHeight.constant = 60.0
        sendRequestToServer(sqlNo: __TRANSACTIONS_GET_PREV, searchKey: self.transactionShidfId)
    }
    
    @IBAction func tryToggleOff(_ sender: Any) {
        self.bottomBarHeight.constant = 60.0
        sendRequestToServer(sqlNo: __TRANSACTIONS_GET_NEXT, searchKey: self.transactionShidfId)
    }
    
    @IBAction func tryConnectAgain(_ sender: Any) {
        if MACHINE_ID != ""{
            isNoticeRequest = false
            QMUITips.showLoading(" Loading ", in: self.view)
            cannotConnectView.isHidden = true
            startConnectTimer()
        }
    }
    deinit {
        transactionTable.removeAllPullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        prepareTransition()
        
        initUI()
       
        if MACHINE_ID == "" {
            cannotConnectView.isHidden = false
        } else {
            sendRequestToServer(sqlNo: __TRANSACTIONS_GET, searchKey: self.transactionShidfId)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isClickMenu {
            isClickMenu = false
            let moveController = self.storyboard?.instantiateViewController(withIdentifier: menuItems[selectedMenuIndex][3])
            if #available(iOS 13.0, *) {
               moveController!.modalPresentationStyle = .fullScreen
            }
            self.present(moveController!, animated: true, completion: nil)
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
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.backgroundColor = UIColor.init(red: 147/255, green: 203/255, blue: 220/255, alpha: 1)
        refreshControl.addTarget(self, action: #selector(requestInventoryData), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func requestInventoryData() {
        let deadline = DispatchTime.now() + .milliseconds(800)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    func initUI() {
        if #available(iOS 10.0, *) {
            transactionTable.refreshControl = refresher
        } else {
            transactionTable.addSubview(refresher)
        }
        
        transactionTable.backgroundColor = UIColor.white
        shopTableView.backgroundColor = UIColor.white
        
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        mainValueView.layer.borderWidth = 1.0
        mainValueView.layer.borderColor = UIColor.white.cgColor
        shiftNameView.layer.cornerRadius = 20.0
        shiftNameView.layer.borderWidth = 3.0
        shiftNameView.layer.borderColor = UIColor.white.cgColor
        imgOpenStaff.layer.cornerRadius = 17.5
        imgCloseStaff.layer.cornerRadius = 17.5
        openStaffView.layer.cornerRadius = 10.0
        closeStaffView.layer.cornerRadius = 10.0
    }
    
    func sendRequestToServer(sqlNo:Int, searchKey:String) {
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
                    self.requestUDID = data["uuid"] as! String
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
    func stopTimer() {
        timer.invalidate()
        counter = 0
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
            toggleView.isHidden = true
            if isNoticeRequest {
                isNoticeRequest = false
            }
        } else {
            if isNoticeRequest{
                self.getNoticeData()
            } else {
                self.getRequestData()
            }
        }
    }
    
    func getNoticeData() {
        HttpRequest.getNoticeData(UDID: requestNoticeUDID, didFuncLoad: {result, error in
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
                             self.toggleView.isHidden = true
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
                             self.toggleView.isHidden = true
                        }
                    }
                }
            }
        })
    }
    
    func getRequestData() {
        HttpRequest.getDashboardData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.toggleView.isHidden = true
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.transactions = []
                
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    var jsonData: Dictionary = [String: Any]()
                    jsonData = responseData[0] as! Dictionary
                    
                    let transactionShiftContent = jsonData["transactionShift"] as! String
                    let transactionListContent = jsonData["transactionList"] as! String
                    if transactionShiftContent != "[]" {
                         var transactionShift: [[String]] = []
                         do {
                             transactionShift = try JSONDecoder().decode(Array.self, from: transactionShiftContent.data(using: .utf8)!)
                         } catch let error {
                             print(error.localizedDescription)
                         }
                        let tempOne = transactionShift[0] as NSArray
                        self.strShiftDate = tempOne[2] as! String
                        self.strCloseDate = tempOne[4] as! String

                        let shiftType = tempOne[1] as! String
                        if shiftType.contains("FIRST") {
                            self.strShiftName = "1"
                        } else if shiftType.contains("SECOND") {
                            self.strShiftName = "2"
                        } else if shiftType.contains("THIRD") {
                            self.strShiftName = "3"
                        }
                        self.strOpenName = tempOne[3] as! String
                        self.strCloseName = tempOne[5] as! String
                        self.strCashReceived = tempOne[6] as! String
                        self.strGrossSale = tempOne[7] as! String
                        self.strCashCount = tempOne[8] as! String
                        self.strBankDeposit = tempOne[9] as! String
                        self.transactionShidfId = tempOne[0] as! String
                    } else {
                        self.strCloseDate = __DEFAULT_STRING
                        self.strShiftDate = __DEFAULT_STRING
                        self.strOpenDate = __DEFAULT_STRING
                        self.strShiftName = __DEFAULT_STRING
                        self.strOpenName = __DEFAULT_STRING
                        self.strCloseName = __DEFAULT_STRING
                        self.strCashReceived = __DEFAULT_STRING
                        self.strGrossSale = __DEFAULT_STRING
                        self.strCashCount = __DEFAULT_STRING
                        self.strBankDeposit = __DEFAULT_STRING
                    }
                    
                    if transactionListContent != "[]"
                    {
                        var transactionList: [[String]] = []
                        do {
                            transactionList = try JSONDecoder().decode(Array.self, from: transactionListContent.data(using: .utf8)!)
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        
                       //print(jsonArray) // use the json here
                        for i in (0...transactionList.count - 1) {
                            let tempTwo:NSArray = transactionList[i] as NSArray
                            let operationId = tempTwo[0] as! String
                            let amount = tempTwo[1] as! String
                            let userName = tempTwo[2] as! String
                            self.transactions.append(TransactionModel(id: "", name: userName, photo: "", operation: operationId, amount: amount))
                        }
                    }
                    
                    self.connectionSuccess()
                } else {
                    if self.counter >=  __SERVER_CONNECTION_COUNT {
                        QMUITips.hideAllTips()
                        self.stopTimer()
                        self.cannotConnectView.isHidden = false
                        self.toggleView.isHidden = true
                    }
                }
            }
        })
    }
    
    func getDecimalFromString(strNumber:String) -> String {
        let correctAmount = Double(strNumber)!
        let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
        return formattedDouble
    }
    
    func getTimeFromString(strTime:String) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "HH:mm:ss"

        let fullDate = dateFormatter.date(from: strTime)

        dateFormatter.dateFormat = "hh:mm a"

        let time2 = dateFormatter.string(from: fullDate!)
        return time2
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
        
        timer.invalidate()
        counter = 0
        
        toggleView.isHidden = false
        lblShiftName.text = strShiftName
        lblOpenStaffName.text = strOpenName
        lblCloseStaffName.text = strCloseName
        if strShiftDate != __DEFAULT_STRING {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            if let ddDate = dateFormatter.date(from:strShiftDate) {
            //dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
                let timeStamp = dateFormatter.string(from: ddDate)
                lblShiftDate.text = timeStamp
                
                dateFormatter.dateFormat = "hh:mm a"
                lblOpenStaffDate.text = dateFormatter.string(from: ddDate)
            }
            
        } else {
            lblShiftDate.text = __DEFAULT_STRING
            lblOpenStaffDate.text = __DEFAULT_STRING
        }
        
        if strCloseDate != __DEFAULT_STRING {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            if let ddDate = dateFormatter.date(from:strShiftDate) {
            //dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
//                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
//                let timeStamp = dateFormatter.string(from: ddDate)
                //lblShiftDate.text = timeStamp
                
                dateFormatter.dateFormat = "hh:mm a"
                lblCloseStaffDate.text = dateFormatter.string(from: ddDate)
            }
        } else {
            lblCloseStaffDate.text = __DEFAULT_STRING
        }
        
        if strCashReceived != __DEFAULT_STRING {
            lblCashReceived.text = self.getDecimalFromString(strNumber: strCashReceived)
        } else {
            lblCashReceived.text = __DEFAULT_STRING
        }
        
        if strGrossSale != __DEFAULT_STRING {
            lblGrossSales.text = self.getDecimalFromString(strNumber: strGrossSale)
        } else {
            lblGrossSales.text = __DEFAULT_STRING
        }
        
        if strCashCount != __DEFAULT_STRING {
            lblCashCount.text = self.getDecimalFromString(strNumber: strCashCount)
        }  else {
              lblCashCount.text = __DEFAULT_STRING
        }
        
        if strBankDeposit != __DEFAULT_STRING {
            lblBackDeposit.text = self.getDecimalFromString(strNumber: strBankDeposit)
        }  else {
            lblBackDeposit.text = __DEFAULT_STRING
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
        
        transactionTable.reloadData()
        shopTableView.reloadData()
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
    
    @IBAction func showMenu(_ sender: Any) {
        showSideMenu()
    }
    
    func showSideMenu(){
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftSideMenu") as! UISideMenuNavigationController
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
    
    var isUpSlide = true
    var isSliding = false
    @IBAction func showMyShops(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: view)
        if velocity.y > 0 {
            self.isNoticeRequest = false
            self.isUpSlide = true
            if self.isSliding {
                UIView.animate(withDuration: 0.5, animations: {
                    self.shopView.frame.origin.y = UIScreen.main.bounds.height - 60
                })
            }
            print("Slide down")
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.shopView.frame.origin.y = 80
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
                    self.requestNoticeUDID = data["uuid"] as! String
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
    
    @IBAction func goHome(_ sender: Any) {
        
    }
    
}

extension TransactionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == transactionTable{
            return transactions.count
        } else {
            return noticeArrayList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == transactionTable {
            let transaction = transactions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
            cell.set(model: transaction)
            cell.selectionStyle = .none
            return cell
        } else {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionNoticeTableViewCell") as! TransactionNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == shopTableView {
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
}

extension TransactionViewController:TransactionNoticeTableViewCellDelegate {
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

extension TransactionViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension TransactionViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}

private extension TransactionViewController {
    func setupPullToRefresh() {
        transactionTable.addPullToRefresh(PullToRefresh()) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount = PageSize
                self?.transactionTable.endRefreshing(at: .top)
            }
        }
        
        transactionTable.addPullToRefresh(PullToRefresh(position: .bottom)) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount += PageSize
                self?.transactionTable.reloadData()
                self?.transactionTable.endRefreshing(at: .bottom)
            }
        }
    }
}
