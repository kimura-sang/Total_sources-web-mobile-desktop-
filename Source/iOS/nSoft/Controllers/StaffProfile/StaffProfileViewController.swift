//
//  StaffProfileViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion

class StaffProfileViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var staffTransactions:[StaffTransactionModel] = []
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var minDate = ""
    var maxDate = ""
    var selectedDate = ""
    var isSendEmail = false
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var staffTableView: UITableView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        initUI()
        sendRequestToServer(sqlNo: __STAFFS_SELECTED_DETAIL)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBackFromNoticeDetail {
            isBackFromNoticeDetail = false
            sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
        }
    }
    @IBAction func tryPrevProfile(_ sender: Any) {
        selectedDate = getPrevDate(currentDate: selectedDate)
        sendRequestToServer(sqlNo: __STAFFS_PREV_DETAIL)
    }
    
    @IBAction func tryNextProfile(_ sender: Any) {
        selectedDate = getNextDate(currentDate: selectedDate)
        sendRequestToServer(sqlNo: __STAFFS_NEXT_DETAIL)
    }
    
    func getCurrentDate() -> String{
        let date = Date()
        let format = DateFormatter()
        //format.dateFormat = "MMMM dd, yyyy"
        //let formattedDate = format.string(from: date)
        
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
    }
    
    func getNextDate(currentDate:String) -> String {
        //let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        if let cDate = format.date(from: currentDate) {
            let nextDay = cDate.add(days: 1)
            return format.string(from: nextDay!)
        } else {
            return currentDate
        }
        
    }
    
    func getPrevDate(currentDate:String) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let cDate = format.date(from: currentDate)
        let nextDay = cDate!.subtract(days: 1)
        return format.string(from: nextDay!)
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
                    self.isNoticeRequest = false
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
    
    @IBAction func tryConnectAgain(_ sender: Any) {
        self.isNoticeRequest = false
        self.isSendEmail = false
        QMUITips.showLoading(" Loading ", in: self.view)
        cannotConnectView.isHidden = true
        self.startConnectTimer()
    }
    @IBAction func sendMessage(_ sender: Any) {
        
        sendRequestToServerForEmail(sqlNo: __EMAIL_STAFF_PROFILE, categoryName: currentStaffName, selectedDate: selectedDate)
        isSendEmail = true
    }
    
    
    func initUI(){
        noticeTable.backgroundColor = UIColor.white
        staffTableView.backgroundColor = UIColor.white
        imgProfile.layer.borderWidth = 1.0
        imgProfile.layer.borderColor = profileBorderColor
        imgProfile.layer.cornerRadius = 45.0
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        bottomBarHeight.constant = 60.0
        
        selectedDate = getCurrentDate()
        if isTest {
            selectedDate = "2019-10-14"
        }
        minDate = __EMPTY_STRING
        maxDate = __EMPTY_STRING
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getPreviousUniqueID(position:Int) -> String {
        var strUnitqueId = ""
        if position > 0 {
            strUnitqueId = staffArrayList[position - 1].name
        }
        return strUnitqueId
    }
    
    func getNextUniqueID(position:Int) -> String {
        var strUnitqueId = ""
        if position < staffArrayList.count {
            strUnitqueId = staffArrayList[position + 1].name
        }
        return strUnitqueId
    }
    
    func sendRequestToServer(sqlNo:Int) {
        QMUITips.showLoading(" Loading ", in: self.view)
        var searchKey = ""
        if sqlNo == __STAFFS_PREV_DETAIL {
            searchKey = self.getPreviousUniqueID(position: currentStaffPosition) + "_" + selectedDate
        } else if sqlNo == __STAFFS_NEXT_DETAIL {
            searchKey = self.getNextUniqueID(position: currentStaffPosition) + "_" + selectedDate
        } else {
            searchKey = currentStaffName + "_" + selectedDate
        }
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
                    if sqlNo == __STAFFS_PREV_DETAIL && currentStaffPosition > 0 {
                        currentStaffPosition -= 1
                    } else if sqlNo == __STAFFS_NEXT_DETAIL && currentStaffPosition < staffArrayList.count {
                        currentStaffPosition += 1
                    }
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
    
    func sendRequestToServerForEmail(sqlNo:Int, categoryName:String, selectedDate:String) {
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
                        self.requestUDID = data["uuid"] as! String
                        self.startConnectTimer()
                    } else if(responseCode == __RESULT_FAILED) {
                       QMUITips.hideAllTips()
                       self.showDialog(title: "Warning", message: "Getting uuid failed")
                    }
                }
        })
    }
    
    func getEmailSendStatus() {
        HttpRequest.getDashboardData(UDID: requestUDID, didFuncLoad: {result, error in
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
    
    func stopTimer() {
        timer.invalidate()
        counter = 0
    }
    
    func startConnectTimer() {
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getStaff), userInfo: nil, repeats: true)
    }
    
    @objc func getStaff() {
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
                    self.getRequestData()
                }
            }
        }
    }
    
    func getStandardDateFormat(currentDate:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
        if let ddDate = dateFormatter.date(from:currentDate) {
        //dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let timeStamp = dateFormatter.string(from: ddDate)
            return timeStamp
        } else {
            return __DEFAULT_STRING
        }

    }
    
    func getStandardDateFormatThreeMonth(currentDate:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
        if let ddDate = dateFormatter.date(from:currentDate) {
        //dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let timeStamp = dateFormatter.string(from: ddDate)
            return timeStamp
        } else {
            return __DEFAULT_STRING
        }

    }
    
    func getStandardTimeFormat(strTime:String) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "hh:mm:ss a"

        if let fullDate = dateFormatter.date(from: strTime) {

            dateFormatter.dateFormat = "hh:mm a"

            let time2 = dateFormatter.string(from: fullDate)
            return time2
        } else {
            return __DEFAULT_STRING
        }
        
    }
    
    func getRequestData() {
        HttpRequest.getStaffProfileData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.staffTransactions = []
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    let tempProfile = data["profile"] as! NSArray
                    //let tempAttendance = data["attendance"] as! NSArray
                    self.minDate = __EMPTY_STRING
                    self.maxDate = __EMPTY_STRING
                    
                    if tempProfile.count > 0 {
                        for i in 0...tempProfile.count - 1 {
                            let tempArray = tempProfile[i] as! NSArray
                            let tempShiftName = tempArray[5] as! String
                            var shiftNo = "1"
                            if tempShiftName.contains("1") {
                                shiftNo = "1"
                            } else if tempShiftName.contains("2") {
                                shiftNo = "2"
                            } else if tempShiftName.contains("3") {
                                shiftNo = "3"
                            }
                            let tempDate = tempArray[6] as! String
                            let tempTimeIn = tempArray[7] as! String
                            let tempTimeOut = tempArray[8] as! String
                            var strDate = ""
                            var strTimeIn = ""
                            var strTimeOut = ""
                            let tempDateArr = tempDate.split(separator: " ")
                            
                            if tempDate != "" && tempDateArr.count == 3 {
                                strDate = self.getStandardDateFormatThreeMonth(currentDate: String(tempDateArr[0]))
                                if i == 0 {
                                    self.minDate = strDate
                                }
                                if i == tempProfile.count - 1 {
                                    self.maxDate = strDate
                                }
                            }
                            
                            let tempTimeInArr = tempTimeIn.split(separator: " ")
                            let tempTimeOutArr = tempTimeOut.split(separator: " ")
                            if tempTimeIn != "" && tempTimeInArr.count == 3 {
                                strTimeIn = self.getStandardTimeFormat(strTime: String(tempTimeInArr[1] + " " + String(tempTimeInArr[2])))
                            }
                            if tempTimeOut != "" && tempTimeOutArr.count == 3 {
                                strTimeOut = self.getStandardTimeFormat(strTime: String(tempTimeOutArr[1]) + " " + String(tempTimeOutArr[2]))
                            }
                            self.staffTransactions.append(StaffTransactionModel(transactionDate: strDate, no: shiftNo, timeIn: strTimeIn, timeOut: strTimeOut))
                        }
                    }
                    
//                    if tempProfile.count > 0{
//                        let jsonData = tempProfile[0] as! NSArray
//                        currentStaffId = jsonData[0] as! String
//                        let firstName = jsonData[1] as! String
//                        let lastName = jsonData[2] as! String
//                        currentStaffName = firstName + " " + lastName
//                        currentStaffEmail = jsonData[4] as! String
//                        currentStaffRole = jsonData[5] as! String
//                    }
                    
//                    if tempAttendance.count > 0 {
//                        for i in (0...tempAttendance.count - 1) {
//                            let tempArr:NSArray = tempAttendance[i] as! NSArray
//                            let dateTime:String = tempArr[0] as! String
//                            let status:String = tempArr[1] as! String
//                            var strDay = ""
//                            var strDate = ""
//                            var strTime = ""
//                            var strInOut = ""
//                            strInOut = status
//
//                            let dateTimeArr = dateTime.split(separator: " ")
//                            if dateTimeArr.count == 2 {
//                                let dtStart = String(dateTimeArr[0])
//                                strTime = String(dateTimeArr[1])
//                                let dateFormatter = DateFormatter()
//                                dateFormatter.dateFormat = "yyyy-MM-dd"
//                                dateFormatter.locale = Locale(identifier: "UTC")
//                                let ddtStart = dateFormatter.date(from: dtStart)
//                                dateFormatter.dateFormat = "EEE, d MMM yyyy"
//                                let timeStampArr = dateFormatter.string(from: ddtStart!)
//                                let dateArr = timeStampArr.split(separator: ",")
//                                if dateArr.count == 2 {
//                                    strDay = String(dateArr[0])
//                                    strDate = String(dateArr[1])
//                                }
//
//                            }
//
//                        self.staffTransactions.append(StaffTransactionModel(transactionDate: strDate, transactionWeek: strDay, transactionTime: strTime, inOut: strInOut))
//
//                        }
//                    }
                    self.connectionSuccess()
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
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
        
        timer.invalidate()
        counter = 0
        
        lblFullName.text = currentStaffName
        lblName.text = currentStaffName
        lblRole.text = currentStaffRole
        lblDate.text = self.minDate + " - " + self.maxDate
        lblEmail.text = currentStaffEmail
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
        staffTableView.reloadData()
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
    
    func getNoticeData() {
        HttpRequest.getNoticeData(UDID: requestNoticeUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
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
}

extension StaffProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return staffTransactions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffProfileNoticeTableViewCell") as! StaffProfileNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let staffTransaction = staffTransactions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffProfileTableViewCell") as! StaffProfileTableViewCell
            cell.set(model: staffTransaction)
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
}

extension StaffProfileViewController:StaffProfileNoticeTableViewCellDelegate {
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

extension StaffProfileViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension StaffProfileViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
