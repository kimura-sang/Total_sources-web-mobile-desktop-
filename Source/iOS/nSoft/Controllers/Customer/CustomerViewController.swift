//
//  CustomerViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import QMUIKit
import MessageUI
import Motion

class CustomerViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var customers:[CustomerModel] = []
    var noticeArrayList:[NoticeModel] = []
    var searchValue = ""
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var isToggleClicked = false
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var edtSearch: UITextField!
    
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var customerTable: UITableView!
    @IBOutlet weak var btnToggle: UIButton!
    @IBOutlet weak var bottomBarHeigth: NSLayoutConstraint!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBAction func trySearch(_ sender: Any) {
        searchValue = edtSearch.text!
//        if isToggleClicked {
//            getRequestData(type: __CUSTOMER_REGULAR)
//        } else {
//            getRequestData(type: __CUSTOMER_PREMIUM)
//        }
        if searchValue == "" {
            sendRequestToServer(sqlNo: __CUSTOMERS_GET_SEARCH_ALL)
        } else {
            sendRequestToServer(sqlNo: __CUSTOMERS_GET_SEARCH)
        }
    }
    @IBAction func tryToggle(_ sender: Any) {
        isToggleClicked = !isToggleClicked
        if isToggleClicked {
            getRequestData(type: __CUSTOMER_REGULAR)
            if let image = UIImage(named: "regular_right_icon") {
                isRegularStatus = true
                btnToggle.setImage(image, for: .normal)
            }
        } else {
            getRequestData(type: __CUSTOMER_PREMIUM)
            if let image = UIImage(named: "premium_left_icon") {
                btnToggle.setImage(image, for: .normal)
                isRegularStatus = false
            }
        }
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
                self.bottomBarHeigth.constant = UIScreen.main.bounds.height - 80
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
                             self.cannotConnectView.isHidden = false
                             self.btnToggle.isHidden = true
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
                             self.btnToggle.isHidden = true
                        }
                    }
                }
            }
        })
    }
    
    
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
        prepareView()
        prepareTransition()
        initUI()
        
        if MACHINE_ID == "" {
            btnToggle.isHidden = true
            cannotConnectView.isHidden = false
        }
        else {
            sendRequestToServer(sqlNo: __CUSTOMERS_GET_TOP20)
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
    
    func initUI(){
        mainView.layer.cornerRadius = mainViewCornerRadius
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeigth.constant = 60
        
        noticeTable.backgroundColor = UIColor.white
        customerTable.backgroundColor = UIColor.white
    }

    @IBAction func openMenu(_ sender: Any) {
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
        var searchStatus = false
        if sqlNo == __CUSTOMERS_GET_SEARCH {
            searchStatus = true
        }
        HttpRequest.requestUDIDWithKeyOrNot(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, searchKey: searchValue, status: searchStatus, didFuncLoad: { result, error in
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
            cannotConnectView.isHidden = false
            btnToggle.isHidden = true
            if isNoticeRequest {
                isNoticeRequest = false
            }
        } else {
            if isNoticeRequest{
                self.getNoticeData()
            } else {
                if isToggleClicked {
                    self.getRequestData(type: __CUSTOMER_REGULAR)
                } else {
                    self.getRequestData(type: __CUSTOMER_PREMIUM)
                }
            }
        }
    }
    
    func getRequestData(type:Int) {
        HttpRequest.getCustomerData(UDID: requestUDID, searchType: "", customerType: String(type), didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.btnToggle.isHidden = true
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.customers = []
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    if responseData.count > 0{
                        for i in (0...responseData.count - 1) {
                            let jsonData = responseData[i] as! NSArray
                            let id = jsonData[0] as! String
                            let lastName = jsonData[1] as! String
                            let firstName = jsonData[2] as! String
                            let phoneNumber = jsonData[3] as! String
                            let customerTime = jsonData[4] as! String
                            var dayNumber = 0
                            if customerTime != "" {
                                dayNumber = Int(customerTime)!
                            }
                            let amount = jsonData[5] as! String
                            self.customers.append(CustomerModel(id: id, firstName: firstName, lastName: lastName, amount: amount, phoneNumber: phoneNumber, customerTime: customerTime, dayNum: dayNumber))
                        }
                    }
                    self.connectionSuccess()
                } else if responseCode == __RESULT_SEARCH_EMPTY {
                    self.connectionSuccess()
                } else {
                    if self.counter >=  __SERVER_CONNECTION_COUNT {
                        QMUITips.hideAllTips()
                        self.stopTimer()
                        self.cannotConnectView.isHidden = false
                        self.btnToggle.isHidden = true
                    }
                }
            }
        })
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
        
        timer.invalidate()
        counter = 0
        
        btnToggle.isHidden = false
        
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
        
        customerTable.reloadData()
        noticeTable.reloadData()
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return customers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == customerTable {
            let customer = customers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerTableViewCell") as! CustomerTableViewCell
            cell.set(model: customer)
            cell.delegate = self
            return cell
        } else {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerNoticeTableViewCell") as! CustomerNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == customerTable {
            let customer = customers[indexPath.row]
            selectedCustomerID = customer.id
            
            let moveController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerProfileViewController") as! CustomerProfileViewController
            if #available(iOS 13.0, *) {
                moveController.modalPresentationStyle = .fullScreen
            }
            self.present(moveController, animated: true, completion: nil)
        } else {
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
extension CustomerViewController: CustomerTableViewCellDelegate {
    func sendMessage(phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
           let controller = MFMessageComposeViewController()
           controller.body = "Message Body"
           controller.recipients = [phoneNumber]
           controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func callCustomer(phoneNumber: String) {
       if let url = NSURL(string: "tel://\(phoneNumber)"),   UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
}

extension CustomerViewController:CustomerNoticeTableViewCellDelegate {
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

extension CustomerViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension CustomerViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
