//
//  UserInfoViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import Motion
import QMUIKit

class UserInfoViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var noticeArrayList:[NoticeModel] = []
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblExpiredDate: UILabel!
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        initUI()
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
        if isBackFromNoticeDetail {
                   isBackFromNoticeDetail = false
                   sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
               }
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
    
       func startConnectTimer() {
           timer.invalidate()
           counter = 0
           timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
       }
    func stopTimer() {
        timer.invalidate()
        counter = 0
    }
       
       @objc func getData() {
           counter += 1
           if counter >= __SERVER_CONNECTION_COUNT {
               QMUITips.hideAllTips()
               counter = 0
               timer.invalidate()
           } else {
               self.getNoticeData()
           }
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
    
    func initUI() {
        noticeTable.backgroundColor = UIColor.white
        mainView.layer.cornerRadius = mainViewCornerRadius
        btnChangePassword.layer.cornerRadius = 20.0
        lblName.text = userName
        lblEmail.text = userEmail
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
        if let ddDate = dateFormatter.date(from:userExpiredDate) {
            dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
            let timeStamp = dateFormatter.string(from: ddDate)
            self.lblExpiredDate.text = timeStamp
        } else {
            self.lblExpiredDate.text = __DEFAULT_STRING
        }
        switch(userOwnerLevel) {
        case 0:
            self.lblRole.text = "Owner"
            break
        case 1:
            self.lblRole.text = "Manager"
            break
        case 2:
            self.lblRole.text = "Supervisor"
            break
        case 3:
            self.lblRole.text = "Staff"
            break
        default:
            self.lblRole.text = __EMPTY_STRING
        }
        
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
    
    @IBAction func openSideMenu(_ sender: Any) {
        showSideMenu()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func goChangePassword(_ sender: Any) {
        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        if #available(iOS 13.0, *) {
            moveController.modalPresentationStyle = .fullScreen
        }
        self.present(moveController, animated: true, completion: nil)
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

extension UserInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeArrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notice = noticeArrayList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoNoticeTableViewCell") as! UserInfoNoticeTableViewCell
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

extension UserInfoViewController:UserInfoNoticeTableViewCellDelegate {
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

extension UserInfoViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension UserInfoViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
