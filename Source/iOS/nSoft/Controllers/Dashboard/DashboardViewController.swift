//
//  DashboardViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import QMUIKit
import Motion

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var timer = Timer()
    var machineTimer = Timer()
    var counter = 0
    var machineKind = 1 // 1: washer, 2:dryer
    var requestUDID = ""
    var requestNoticeUDID = ""
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var noticeArrayList:[NoticeModel] = []
    var dashMachines:[MachineModel] = []
    var dashUsers:[DashUserModel] = []
    var dashInventories:[DashInventoryModel] = []
    var dashDryerMachines:[MachineModel] = []
    var dashWasherMachines:[MachineModel] = []
    var categories:[DashCategoryModel] = []
    var userMachines:[String] = []
    var machineStatus:[String] = []
    var strCurrentShift = ""
    var strOpenedDate = ""
    var strShiftOwner = ""
    var strShiftAmount = ""
    var strCurrentDate = ""
    var isSelectedWasher:Bool = true
    var selectedCategoryIndex = 0
    var newNoticeCount:Int = 0
    var isFirst = true
    var isCategoryClicked = false
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var lblNewNoticeCount: UILabel!
    @IBOutlet weak var topValueView: UIView!
    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var topDateView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var middleTopView: UIView!
    @IBOutlet weak var btnWasher: UIButton!
    @IBOutlet weak var btnDryer: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentTopView: UIView!
    @IBOutlet weak var userCollectionView: UICollectionView!
    @IBOutlet weak var inventoryTableView: UITableView!
    @IBOutlet weak var categoryScrollView: UICollectionView!
    @IBOutlet weak var machineCollectionView: UICollectionView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblOpenName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBAction func tryWasher(_ sender: Any) {
        machineKind = 1
        isSelectedWasher = true
        //dashMachines = []
        //dashMachines = dashWasherMachines
        //showCount()
        showMachineList()
        btnWasher.backgroundColor = UIColor.init(displayP3Red: 140/255, green: 199/255, blue: 217/255, alpha: 1)
        btnDryer.backgroundColor = topViewColor
    }
    
    @IBAction func tryDryer(_ sender: Any) {
        machineKind = 2
        isSelectedWasher = false
        //dashMachines = []
        //dashMachines = dashDryerMachines
        //showCount()
        showMachineList()
        btnDryer.backgroundColor = UIColor.init(displayP3Red: 140/255, green: 199/255, blue: 217/255, alpha: 1)
        btnWasher.backgroundColor = topViewColor
    }
    
    @IBAction func tryNextUser(_ sender: Any) {
        userCollectionView.scrollToNextItem()
    }
    @IBAction func tryPrevUser(_ sender: Any) {
        userCollectionView.scrollToPreviousItem()
    }
    @IBAction func tryConnectAgain(_ sender: Any) {
        if MACHINE_ID != "" {
            isNoticeRequest = false
            QMUITips.showLoading(" Loading ", in: self.view)
            cannotConnectView.isHidden = true
            self.startConnectTimer()
        }
    }
    var sideMenuView:SideMenuView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
        prepareTransition()
        
        initUI()
       
        if MACHINE_ID == "" {
            cannotConnectView.isHidden = false
        } else {
            sendRequestToServer(sqlNo: __DASHBOARD_GET, searchKey: __EMPTY_STRING)
            
            categoryScrollView.delegate = self
            categoryScrollView.allowsMultipleSelection = false
        }
    }
    func stopTimer() {
        timer.invalidate()
        counter = 0
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        machineTimer.invalidate()
        
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
            newNoticeCount = 0
            isBackFromNoticeDetail = false
            sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
        }
    }
    
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.backgroundColor = UIColor.init(red: 0, green: 162/255, blue: 188/255, alpha: 1)
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
            inventoryTableView.refreshControl = refresher
        } else {
            inventoryTableView.addSubview(refresher)
        }
        
        inventoryTableView.backgroundColor = UIColor.white
        noticeTable.backgroundColor = UIColor.white
        categoryScrollView.backgroundColor = UIColor.init(red: 0, green: 162/255, blue: 188/255, alpha: 1)
        machineCollectionView.backgroundColor = UIColor.white
        userCollectionView.backgroundColor = UIColor.white
        
        self.bottomBarHeight.constant = 60
        topView.layer.cornerRadius = 10.0
        middleView.layer.cornerRadius = 10.0
        contentView.layer.cornerRadius = 10.0
        topValueView.layer.cornerRadius = 10.0
        topInfoView.layer.cornerRadius = 10.0
        topDateView.layer.cornerRadius = 10.0
        bottomView.layer.cornerRadius = 10.0
        btnWasher.layer.cornerRadius = 17.0
        btnWasher.layer.borderWidth = 1.0
        btnWasher.layer.borderColor = UIColor.white.cgColor
        btnDryer.layer.cornerRadius = 17.0
        btnDryer.layer.borderWidth = 1.0
        btnDryer.layer.borderColor = UIColor.white.cgColor
//        middleValueView.layer.cornerRadius = 17
//        middleValueView.layer.borderWidth = 1.0
//        middleValueView.layer.borderColor = UIColor.white.cgColor
        middleTopView.layer.cornerRadius = 10.0
        contentTopView.layer.cornerRadius = 10.0
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
    }
    
    @IBAction func openSideMenu(_ sender: Any) {
        self.showSideMenu()
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
                newNoticeCount = 0
                isUpSlide = false
                isSliding = false
                Motion.delay(0.5) { [weak self] in
                    if !self!.isUpSlide {
                        self?.sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
                        self!.isSliding = true
                    }
                }
            }
        }
    }
    
    @IBAction func showNoticeData(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.noticeView.frame.origin.y = 80
            self.bottomBarHeight.constant = UIScreen.main.bounds.height - 80
        })
        if isUpSlide {
            newNoticeCount = 0
            isUpSlide = false
            isSliding = false
            Motion.delay(0.5) { [weak self] in
                if !self!.isUpSlide {
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
                            if viewStatus != "True" {
                                self.newNoticeCount += 1
                            }
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
    
    func sendRequestToServer(sqlNo:Int, searchKey:String) {
        machineTimer.invalidate()
        
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
                    self.requestNoticeUDID = self.requestUDID
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
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTransaction), userInfo: nil, repeats: true)
    }
    
    @objc func getTransaction() {
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
                if !isCategoryClicked {
                    self.getRequestData()
                } else {
                    self.getDashboardCategoryData()
                }
            }
        }
    }
    
    func startMachineTimer() {
        machineTimer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(getMachineStatus), userInfo: nil, repeats: true)
    }
    
    @objc func getMachineStatus() {
        showMachineList()
    }
    
    func getRequestData() {
//        if isTest {
//            requestUDID = "23292b3d9afc99735b9e41cfc0cc9cdd"
//        }
        HttpRequest.getDashboardData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.dashMachines = []
                self.dashUsers = []
                self.dashInventories = []
                self.dashDryerMachines = []
                self.dashWasherMachines = []
                self.categories = []

                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    var jsonData: Dictionary = [String: Any]()
                    jsonData = responseData[0] as! Dictionary

                    let dashOneContent = jsonData["dashboard1"] as! String
                    let dashTwoContent = jsonData["dashboard2"] as! String
                    let dashThreeContent = jsonData["dashboard3"] as! String
                    let dashFourContent = jsonData["dashboard4"] as! String
                    let dashCategoryContent = jsonData["category"] as! String
                    if dashOneContent != "[]" {
                         var dashOne: [[String]] = []
                         do {
                             dashOne = try JSONDecoder().decode(Array.self, from: dashOneContent.data(using: .utf8)!)
                         } catch let error {
                             print(error.localizedDescription)
                         }
                        if dashOne.count > 0 {
                            let temp = dashOne[0] as NSArray
                            self.strCurrentShift = temp[0] as! String
                            self.strOpenedDate = temp[1] as! String
                            self.strShiftOwner = temp[2] as! String
                            self.strShiftAmount = temp[3] as! String
                            self.strCurrentDate = temp[4] as! String
                        }
                        var dashTwo: [[String]] = []
                        do {
                            dashTwo = try JSONDecoder().decode(Array.self, from: dashTwoContent.data(using: .utf8)!)
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        if dashTwo.count > 0 {
                            var count1 = 1
                            var count2 = 1
                            for i in (0...dashTwo.count - 1) {
                                let tempArr:NSArray = dashTwo[i] as NSArray
                                let id = tempArr[0] as! String
                                let name = tempArr[1] as! String
                                let status = tempArr[2] as! String
                                let kind = tempArr[3] as! String
                                let remainTime = tempArr[4] as! String
                                let registerTime = tempArr[5] as! String
                                let machineInfoArr = name.split(separator: " ")
                                let machineNo = Int(machineInfoArr[1])
                                
//                                self.dashMachines.append(MachineModel(id: id, name: name, status: status, kind: kind, remainTime: remainTime, registerTime: registerTime))
                                
                                if kind == "DRYER" {
                                    self.dashDryerMachines.append(MachineModel(no: String(machineNo!), id: id, name: name, status: status, kind: kind, remainTime: remainTime, registerTime: registerTime))
                                    count1 += 1
                                } else if kind == "WASHER" {
                                    self.dashWasherMachines.append(MachineModel(no: String(machineNo!), id: id, name: name, status: status, kind: kind, remainTime: remainTime, registerTime: registerTime))
                                    count2 += 1
                                }
                                self.dashMachines = self.dashWasherMachines
                            }
                        }
                        
                        var dashThree: [[String]] = []
                        do {
                            dashThree = try JSONDecoder().decode(Array.self, from: dashThreeContent.data(using: .utf8)!)
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        if dashThree.count > 0 {
                            for i in (0...dashThree.count - 1) {
                                let tempArr:NSArray = dashThree[i] as NSArray
                                let name = tempArr[0] as! String
                                let unit = tempArr[1] as! String
                                let first = tempArr[2] as! String
                                let second = tempArr[3] as! String
                                let thrid = tempArr[4] as! String
                                var status = false
                                let tempStorage = Int(first)! - Int(second)!
                                if thrid != "0" {
                                    let storage = Int(first)!
                                    let usage = Int(second)!
                                    let amount = Int(thrid)!
                                    if (amount > (storage - usage)) {
                                        status = true
                                    }
                                }
                                
                                self.dashInventories.append(DashInventoryModel(name: name, unit: unit, first: first, second: second, third: String(tempStorage), criticalStatus: status))
                            }
                        }
                        var dashFour: [[String]] = []
                        do {
                            dashFour = try JSONDecoder().decode(Array.self, from: dashFourContent.data(using: .utf8)!)
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        
                        dashUserCount = dashFour.count
                        if dashFour.count > 0 {
                            for i in (0...dashFour.count - 1) {
                               let tempArr:NSArray = dashFour[i] as NSArray
                               let name = tempArr[0] as! String
                               let role = tempArr[1] as! String
                               let timeIn = tempArr[3] as! String
                               let timeOut = tempArr[4] as! String
                                var status = strStaffNone
                                if timeIn == "" && timeOut == "" {
                                    status = strStaffNone
                                } else if timeIn != "" && timeOut == "" {
                                    status = strStaffLogIn
                                } else {
                                    status = strStaffLogOut
                                }
                                self.dashUsers.append(DashUserModel(name: name, role: role, status: status, timeIn: timeIn, timeOut: timeOut))
                            }
                        }
                        var dashCategory: [[String]] = []
                        do {
                            dashCategory = try JSONDecoder().decode(Array.self, from: dashCategoryContent.data(using: .utf8)!)
                        } catch let error {
                            print(error.localizedDescription)
                        }
//                        if self.selectedCategoryIndex == 0 {
//                            self.categories.append(DashCategoryModel(no: 0, name: "ALL", status: true))
//                        } else {
//                            self.categories.append(DashCategoryModel(no: 0, name: "ALL", status: false))
//                        }
                        
                        if dashCategory.count > 0 {
                            for i in (0...dashCategory.count - 1) {
                                let tempArr:NSArray = dashCategory[i] as NSArray
                                let name = tempArr[0] as! String
                                if self.selectedCategoryIndex == i{
                                    self.categories.append(DashCategoryModel(no: i + 1, name: name, status: true))
                                } else {
                                    self.categories.append(DashCategoryModel(no: i + 1, name: name, status: false))
                                }
                                
                            }
                        }
                    }

                    self.connectionSuccess()
                    if self.isFirst{
                        self.isFirst = false
                        self.isNoticeRequest = true
                        self.sendRequestToServer(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
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
    
    func getDashboardCategoryData() {
        HttpRequest.getDashboardData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.dashInventories = []

                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    var jsonData: Dictionary = [String: Any]()
                    jsonData = responseData[0] as! Dictionary

                    let dashThreeContent = jsonData["dashboard3"] as! String
                    
                    var dashThree: [[String]] = []
                    do {
                        dashThree = try JSONDecoder().decode(Array.self, from: dashThreeContent.data(using: .utf8)!)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    if dashThree.count > 0 {
                        for i in (0...dashThree.count - 1) {
                            let tempArr:NSArray = dashThree[i] as NSArray
                            let name = tempArr[0] as! String
                            let unit = tempArr[1] as! String
                            let first = tempArr[2] as! String
                            let second = tempArr[3] as! String
                            let thrid = tempArr[4] as! String
                            var status = false
                            let tempStorage = Int(first)! - Int(second)!
                            if thrid != "0" {
                                let storage = Int(first)!
                                let usage = Int(second)!
                                let amount = Int(thrid)!
                                if (amount > (storage - usage)) {
                                    status = true
                                }
                            }
                            
                            self.dashInventories.append(DashInventoryModel(name: name, unit: unit, first: first, second: second, third: String(tempStorage), criticalStatus: status))
                        }
                    }
                    self.conectionSuccssWithCategory()
                } else {
                    if self.counter >=  __SERVER_CONNECTION_COUNT {
                        QMUITips.hideAllTips()
                        self.stopTimer()
                        self.isCategoryClicked = false
                        self.cannotConnectView.isHidden = false
                    }
                }
            }
        })
    }
    func conectionSuccssWithCategory() {
        QMUITips.hideAllTips()
        counter = 0
        timer.invalidate()
        isCategoryClicked = false
        self.inventoryTableView.reloadData()
    }
    func showMachineList() {
        userMachines = []
        machineStatus = []
        var usedCount = 0
        var machineList:[MachineModel] = []
        
        if machineKind == 1 {
            machineList = dashWasherMachines
        } else if machineKind == 2 {
            machineList = dashDryerMachines
        }
        
        if machineList.count > 0 {
            for i in 0...machineList.count - 1 {
                let tempObject:MachineModel = machineList[i]
                userMachines.append(tempObject.no)
                if tempObject.status == "ON-USE" {
                    var milliseconds:Int64 = 0
                    let currentTimeMillis:Int64 = Int64(Date().timeIntervalSince1970 * 1000)
                    var remainTime:Int = 0
                    remainTime = Int(tempObject.remainTime)!
                    let startTimeArr = tempObject.registerTime.split(separator: ".")
                    let startTime = startTimeArr[0]
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
                    if let ddDate = dateFormatter.date(from:String(startTime)) {
                        milliseconds = Int64(ddDate.millisecondsSince1970)
                        let diffMin:Int = Int((currentTimeMillis - milliseconds) / 60000)
                        if diffMin < remainTime {
                            let rTime = remainTime - diffMin
                            machineStatus.append(String(rTime) + " min")
                            usedCount += 1
                        } else {
                            machineStatus.append("AVAILABLE")
                        }
                    }
                    
                } else {
                    machineStatus.append(tempObject.status)
                }
            }
        }
        
        lblCount.text = String(usedCount) + "/" + String(machineList.count)
        dashMachines = []
        dashMachines = machineList
        
        machineCollectionView.reloadData()
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
       
        timer.invalidate()
        counter = 0

        showDashboardOne()
        showMachineList()
        startMachineTimer()
        
        if newNoticeCount == 0 {
            lblNewNoticeCount.text = " "
        } else {
            lblNewNoticeCount.text = String(newNoticeCount)
        }
       //transactionTable.reloadData()
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
        userCollectionView.reloadData()
        inventoryTableView.reloadData()
        categoryScrollView.reloadData()
        machineCollectionView.reloadData()
    }
    
    func showDashboardOne() {
        if strOpenedDate != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            if let ddDate = dateFormatter.date(from:strOpenedDate) {
            //dateFormatter.dateFormat = "EEEE, dd MMM yyyy"///this is what you want to convert format
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
                let timeStamp = dateFormatter.string(from: ddDate)
                lblDate.text = timeStamp
                
                dateFormatter.dateFormat = "hh:mm a"
                lblTime.text = dateFormatter.string(from: ddDate)
            }
        }
       
        lblOpenName.text = strCurrentShift
        lblName.text = strShiftOwner
        if strShiftAmount != "" {
            let correctAmount = Double(strShiftAmount)!
            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
            lblAmount.text = String(formattedDouble)
        }
    }
        
    func getTimeFromString(strTime:String) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "HH:mm:ss"

        let fullDate = dateFormatter.date(from: strTime)

        dateFormatter.dateFormat = "hh:mm a"

        let time2 = dateFormatter.string(from: fullDate!)
        return time2
    }
    
//    func showCount(){
//        var usedCount = 0
//        for i in (0...dashMachines.count - 1) {
//           var machine = dashMachines[i]
//           if machine.status == "ON-USE" {
//               usedCount += 1
//           }
//        }
//        var totalCount = dashMachines.count
//        lblCount.text = String(usedCount) + "/" + String(totalCount)
//    }
    
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

    @IBAction func goHome(_ sender: Any) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryScrollView{
            return CGSize(width: 100, height: 50)
        } else if collectionView == machineCollectionView {
            return CGSize(width: 70, height: 70)
        } else {
            return CGSize(width: 70, height: 80)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == userCollectionView {
            return dashUsers.count
        } else if collectionView == categoryScrollView {
            return categories.count
        } else {
            return dashMachines.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == userCollectionView {
            let user = dashUsers[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
            cell.set(model: user)
            return cell
        } else if collectionView == categoryScrollView {
            let category = categories[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.set(model: category)
            return cell
        } else {
            let machine = dashMachines[indexPath.row]
            let status = machineStatus[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MachineCollectionViewCell", for: indexPath) as! MachineCollectionViewCell
            cell.set(model: machine, status: status)
             return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryScrollView {
            var selectedCategoryName = __EMPTY_STRING
            selectedCategoryName = categories[indexPath.row].categoryName

            selectedCategoryIndex = indexPath.row
            for i in 0...categories.count - 1 {
                if i == selectedCategoryIndex {
                    categories[i].selectedStatus = true
                } else {
                    categories[i].selectedStatus = false
                }
            }
            categoryScrollView.reloadData()
            bottomBarHeight.constant = 60.0
            isNoticeRequest = false
            isCategoryClicked = true
            sendRequestToServer(sqlNo: __DASHBOARD_GET_CATEGORY, searchKey: selectedCategoryName)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == categoryScrollView {
            var selectedCategoryName = __EMPTY_STRING
            if indexPath.row != 0 {
                selectedCategoryName = categories[indexPath.row].categoryName
            }
            selectedCategoryIndex = indexPath.row
            
            sendRequestToServer(sqlNo: __DASHBOARD_GET, searchKey: selectedCategoryName)
       }
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
extension DashboardViewController: SideMenuViewControllerDelegate {
    func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == inventoryTableView {
            return dashInventories.count
        } else {
            return noticeArrayList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == inventoryTableView {
            let inventory = dashInventories[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryTableViewCell") as! InventoryTableViewCell
            cell.set(model: inventory)
            return cell
        } else {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashNoticeTableViewCell") as! DashNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
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

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func moveToFrame(contentOffset : CGFloat) {
        let movePixel:CGFloat = CGFloat(70.0 * Double(dashUserCount - 1))
        if contentOffset < 0.0 {
            self.setContentOffset(CGPoint(x: 0.0, y: self.contentOffset.y), animated: true)
        } else if contentOffset > movePixel {
            self.setContentOffset(CGPoint(x: movePixel, y: self.contentOffset.y), animated: true)
        } else {
             self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
        }
    }
}
extension DashboardViewController:DashNoticeTableViewCellDelegate {
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
extension DashboardViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension DashboardViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
