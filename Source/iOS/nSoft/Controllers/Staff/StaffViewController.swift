//
//  StaffViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import QMUIKit
import Motion
class StaffViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var staffs:[StaffModel] = []
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    @IBOutlet weak var staffTable: UITableView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBAction func tryConnectAgain(_ sender: Any) {
        if MACHINE_ID != "" {
            isNoticeRequest = false
            QMUITips.showLoading(" Loading ", in: self.view)
            cannotConnectView.isHidden = true
            startConnectTimer()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareView()
        prepareTransition()
        initUI()
        if MACHINE_ID == "" {
            cannotConnectView.isHidden = false
        } else {
            sendRequestToServer(sqlNo: __STAFFS_GET)
        }
    }
    func initUI() {
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        noticeTable.backgroundColor = UIColor.white
        staffTable.backgroundColor = UIColor.white
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
    
    func sendRequestToServer(sqlNo:Int) {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.requestUDID(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, didFuncLoad: { result, error in
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
                self.getRequestData()
            }
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
        HttpRequest.getStaffData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                //self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.staffs = []
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    if responseData.count > 0{
                        for i in (0...responseData.count - 1) {
                            let jsonData = responseData[i] as! NSArray
                            let name = jsonData[0] as! String
                            let role = jsonData[1] as! String
                            let tempShiftNo = jsonData[2] as! String
                            var shiftNo = ""
                            if tempShiftNo != "" {
                                shiftNo = String(tempShiftNo.prefix(1))
                            }
                            let timeIn = jsonData[3] as! String
                            let timeOut = jsonData[4] as! String
                            var strTimeIn = ""
                            var strTimeOut = ""
                            if timeIn != "" {
                                let timeInArr = timeIn.split(separator: " ")
                                if timeInArr.count == 3 {
                                    strTimeIn = self.getStandardTimeFormat(strTime: timeInArr[1] + " " + timeInArr[2])
                                }
                            }
                            
                            if timeOut != "" {
                                let timeOutArr = timeOut.split(separator: " ")
                                if timeOutArr.count == 3 {
                                    strTimeOut = self.getStandardTimeFormat(strTime: timeOutArr[1] + " " + timeOutArr[2])
                                }
                            }
                            
                            self.staffs.append(StaffModel(id: "", name: name, role: role, shiftNo: shiftNo, timeIn: strTimeIn, timeOut: strTimeOut))
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
            }
        })
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
        
        staffArrayList = staffs
        
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
        staffTable.reloadData()
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
       
       func getNoticeData() {
           HttpRequest.getNoticeData(UDID: requestUDID, didFuncLoad: {result, error in
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

extension StaffViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return staffs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffNoticeTableViewCell") as! StaffNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let staff = staffs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffTableViewCell") as! StaffTableViewCell
            cell.set(model: staff)
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
        } else {
            let staff = staffs[indexPath.row]
            currentStaffId = staff.id
            currentStaffName = staff.name
            currentStaffRole = staff.role
            currentStaffPosition = indexPath.row
            
            let moveController = self.storyboard?.instantiateViewController(withIdentifier: "StaffProfileViewController") as! StaffProfileViewController
            if #available(iOS 13.0, *) {
                moveController.modalPresentationStyle = .fullScreen
            }
            self.present(moveController, animated: true, completion: nil)
        }
        
    }
}

extension StaffViewController:StaffNoticeTableViewCellDelegate {
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

extension StaffViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension StaffViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
