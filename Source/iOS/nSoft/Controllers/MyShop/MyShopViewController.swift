//
//  MyShopViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import QMUIKit
import Motion

class MyShopViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var noticeArrayList:[NoticeModel] = []
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var shopList:[ShopModel] = []
    
    @IBOutlet weak var btnAddNewShop: UIButton!
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var noticeTableView: UITableView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        initUI()
        updateShopLog()
        
    }
    
    @IBAction func tryConnectAgain(_ sender: Any) {
        if MACHINE_ID != ""{
            QMUITips.showLoading(" Loading ", in: self.view)
            cannotConnectView.isHidden = true
            startConnectTimer()
        }
    }
    func stopTimer() {
        timer.invalidate()
        counter = 0
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
        
        if isBackFromAddShop {
            isBackFromAddShop = false
            updateShopLog()
        }
    }
    
    
    
    func initUI(){
        selectedMenuIndex = 1
        btnAddNewShop.layer.cornerRadius = 20.0
        topView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        topView.layer.shadowRadius = 1
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        
        noticeTableView.backgroundColor = UIColor.white
        shopTableView.backgroundColor = UIColor.white
    }
    
    func updateShopLog() {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.updateShopLog(userId: userID, userEmail: userEmail, didFuncLoad: { result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.refreshShopTable()
                self.showDialog(title: "Warning", message: "Networrk Error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    Motion.delay(6.0) { [weak self] in
                        self!.getShops()
                    }
                } else if(responseCode == __RESULT_EMPTY_SHOP) {
                    QMUITips.hideAllTips()
                    self.refreshShopTable()
                } else if(responseCode == __RESULT_FAILED) {
                    QMUITips.hideAllTips()
                    self.refreshShopTable()
                }
                
            }
        })
    }
    
    func refreshShopTable() {
        shopList = []
        self.shopTableView.reloadData()
    }
    
    func getShops(){
        shopList = []
        HttpRequest.getShopList(userId: userID, didFuncLoad: { result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Networrk Error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    if responseData.count > 0 {
                        
                        if responseData.count == 1{
                            var data: Dictionary = [String: Any]()
                            data = responseData[0] as! Dictionary
                            selectedShopIndex = 0;
                            SHOP_NAME = data["shop_name"] as! String
                            SHOP_BRANCH = data["branch"] as! String
                            MACHINE_ID = data["machine_id"] as! String
                            
                            self.lblShopName.text = SHOP_NAME
                            self.lblShopBranch.text = SHOP_BRANCH
                            
                            defaultSettings.set(SHOP_NAME, forKey: "SHOP_NAME")
                            defaultSettings.set(SHOP_BRANCH, forKey: "SHOP_BRANCH")
                            defaultSettings.set(MACHINE_ID, forKey: "MACHINE_ID")
                        }
                        
                        for i in (0...responseData.count - 1){
                            var data: Dictionary = [String: Any]()
                            data = responseData[i] as! Dictionary
                            let shopId = data["id"] as! String
                            let shopName = data["shop_name"] as! String
                            let shopBranch = data["branch"] as! String
                            let shopMachineID = data["machine_id"] as! String
                            let shopAmount = data["amount"] as! String
                            let shopOnlineStatus  = data["online_status"] as! String
                            self.shopList.append(ShopModel(id: shopId, name: shopName, branch: shopBranch, machineId: shopMachineID, amount: shopAmount, onlineStatus: Int(shopOnlineStatus)!))
                        }
                        
                    }
                    
                    self.shopTableView.reloadData()
                    
                    if MACHINE_ID != "" {
                        if self.shopList.count > 0 {
                            for i in (0...self.shopList.count - 1){
                                if MACHINE_ID == self.shopList[i].shopMachineId {
                                    selectedShopIndex = i
                                    let rowToSelect:NSIndexPath = NSIndexPath(row: selectedShopIndex, section: 0);
                                    self.shopTableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
                                    self.lblShopName.text = SHOP_NAME
                                    self.lblShopBranch.text = SHOP_BRANCH
                                    break
                                }
                            }
                        }
                        
                    }
                    QMUITips.hideAllTips()
                    
                } else if(responseCode == __RESULT_EMPTY_SHOP) {
                    QMUITips.hideAllTips()
                    //self.showDialog(title: "Warning", message: "Expired date is over")
                } else if(responseCode == __RESULT_FAILED) {
                    QMUITips.hideAllTips()
                    //self.showDialog(title: "Warning", message: "Login Failed")
                }
                
            }
        })
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
        noticeTableView.reloadData()
    }
    
    
    @IBAction func showMenu(_ sender: Any) {
        showSideMenu()
    }
    
    @IBAction func goToAddShop(_ sender: Any) {
        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewShopViewController") as! AddNewShopViewController
        if #available(iOS 13.0, *) {
            moveController.modalPresentationStyle = .fullScreen
        }
        self.present(moveController, animated: true, completion: nil)
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

extension MyShopViewController: SideMenuViewControllerDelegate {
    func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MyShopViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTableView {
            return noticeArrayList.count
        } else {
            return shopList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTableView {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShopNoticeTableViewCell") as! MyShopNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        else {
            let shop = shopList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShopTableViewCell") as! MyShopTableViewCell
            cell.set(shop: shop)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == noticeTableView {
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
            if let cell = tableView.cellForRow(at: indexPath){
                cell.backgroundColor = UIColor.init(red: 107/255, green: 220/255, blue: 86/255, alpha: 1)
                let imgShop = cell.viewWithTag(13) as? UIImageView
                imgShop?.image = UIImage(named: "icon_home_white")
           }
            let shop = shopList[indexPath.row]
            selectedShopIndex = indexPath.row
            SHOP_NAME = shop.shopName
            SHOP_BRANCH = shop.shopBranch
            MACHINE_ID = shop.shopMachineId
            
            self.lblShopName.text = SHOP_NAME
            self.lblShopBranch.text = SHOP_BRANCH
            
            defaultSettings.set(shop.shopName, forKey: "SHOP_NAME")
            defaultSettings.set(shop.shopBranch, forKey: "SHOP_BRANCH")
            defaultSettings.set(shop.shopMachineId, forKey: "MACHINE_ID")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
             let imgShop = cell.viewWithTag(13) as? UIImageView
             imgShop?.image = UIImage(named: "home_clor_icon")
        }
    }
}

extension MyShopViewController:MyShopNoticeTableViewCellDelegate {
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


extension MyShopViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension MyShopViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
