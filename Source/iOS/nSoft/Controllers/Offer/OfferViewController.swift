//
//  OfferViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SideMenu
import QMUIKit
import Motion

class OfferViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var noticeReqeustUDID = ""
    var selectedCategoryName = ""
    var categoryList:[OfferCategoryModel] = []
    var offerArrayList:[OfferModel] = []
    var availableOfferList:[OfferModel] = []
    var disableOfferList:[OfferModel] = []
    var selectedCategoryIndex:Int = 0
    var isToggleClicked = false
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var offerTableView: UITableView!
    @IBOutlet weak var mainTopView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnItemReplenish: UIButton!
    @IBOutlet weak var toggleView: UIView!
    @IBOutlet weak var btnToggle: UIButton!
    @IBOutlet weak var cannotConnectView: UIView!
    
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBAction func tryToggle(_ sender: Any) {
        if isToggleClicked {
            if let image = UIImage(named: "available_left_icon") {
                btnToggle.setImage(image, for: .normal)
            }
        } else {
            //getRequestData(type: __CUSTOMER_PREMIUM)
            if let image = UIImage(named: "disable_right_icon") {
                btnToggle.setImage(image, for: .normal)
            }
        }
        self.getOfferWithCategory(clickStatus: isToggleClicked, categoryName: selectedCategoryName)
        isToggleClicked = !isToggleClicked
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

        // Do any additional setup after loading the view.
        prepareView()
        prepareTransition()
        initUI()
        
        if MACHINE_ID == "" {
            toggleView.isHidden = true
            cannotConnectView.isHidden = false
        } else {
            sendRequestToServer(searchKey: "")
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
        btnItemReplenish.layer.cornerRadius = 20.0
        mainView.layer.cornerRadius = mainViewCornerRadius
        mainTopView.layer.cornerRadius = mainViewCornerRadius
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        noticeTable.backgroundColor = UIColor.white
        categoryCollectionView.backgroundColor = UIColor.init(red: 0, green: 162/255, blue: 188/255, alpha: 1)
        offerTableView.backgroundColor = UIColor.white
    }
    
    @IBAction func tryReplenish(_ sender: Any) {
        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "ReplenishmentViewController") as! ReplenishmentViewController
        if #available(iOS 13.0, *) {
            moveController.modalPresentationStyle = .fullScreen
        }
        self.present(moveController, animated: true, completion: nil)
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
    
    func sendRequestToServer(searchKey:String) {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.requestUDIDWithSearchKey(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: __OFFERS_GET, statusID: __DATA_REQUESTED, searchKey: searchKey, didFuncLoad: { result, error in
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
    func stopTimer() {
        timer.invalidate()
        counter = 0
    }
    func startConnectTimer() {
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getOffers), userInfo: nil, repeats: true)
    }
    
    @objc func getOffers() {
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
    
    func getRequestData() {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.getOfferData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.categoryList = []
                self.offerArrayList = []
                self.availableOfferList = []
                self.disableOfferList = []
                
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    let strOfferCategory = data["category"] as! NSArray
                    let strAvailableOffer = data["available"] as! NSArray
                    let strDisableOffer = data["disable"] as! NSArray
                    
                    if strOfferCategory.count != 0 {
                        if self.selectedCategoryIndex == 0 {
                            self.categoryList.append(OfferCategoryModel(no: 0, name: "ALL", status: true))
                        } else {
                            self.categoryList.append(OfferCategoryModel(no: 0, name: "ALL", status: false))
                        }
                        
                        for i in (0...strOfferCategory.count - 1) {
                            let tempArr:NSArray = strOfferCategory[i] as! NSArray
                            let tempStr:String = tempArr[0] as! String
                            //let splitArr = tempStr.split(separator: "")
                            
                            if self.selectedCategoryIndex != 0 && self.selectedCategoryIndex == i + 1 {
                                self.categoryList.append(OfferCategoryModel(no: i + 1, name: tempStr, status: true))
                            } else {
                                self.categoryList.append(OfferCategoryModel(no: i + 1, name: tempStr, status: false))
                            }
                        }
                        
                    }
                    
                    if strAvailableOffer.count != 0 {
                        for i in (0...strAvailableOffer.count - 1) {
                            let tempArr:NSArray = strAvailableOffer[i] as! NSArray
                            let code:String = tempArr[0] as! String
                            let category = tempArr[1] as! String
                            let kind = tempArr[2] as! String
                            let description = tempArr[3] as! String
                            let price = tempArr[4] as! String
                            let cost = tempArr[5] as! String
                            let type = tempArr[6] as! String
                            self.availableOfferList.append(OfferModel(code: code, category: category, kind: kind, description: description, price: price, cost: cost, varType: type))
                        }

                    }
                    
                    if strDisableOffer.count != 0 {
                        for i in (0...strDisableOffer.count - 1) {
                            let tempArr:NSArray = strDisableOffer[i] as! NSArray
                            let code:String = tempArr[0] as! String
                            let category = tempArr[1] as! String
                            let kind = tempArr[2] as! String
                            let description = tempArr[3] as! String
                            let price = tempArr[4] as! String
                            let cost = tempArr[5] as! String
                            let type = tempArr[6] as! String
                            self.disableOfferList.append(OfferModel(code: code, category: category, kind: kind, description: description, price: price, cost: cost, varType: type))
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
    
    func getOfferWithCategory(clickStatus:Bool, categoryName:String) {
        var type = 0
        if clickStatus {
            type = __OFFER_AVAILABLE
        } else {
            type = __OFFER_DISABLE
        }
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.getOfferWithCategory(UDID: requestUDID, status: type
            , categoryName: categoryName, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    self.availableOfferList = []
                    self.disableOfferList = []
                    let responseData = resultDicData["data"] as! NSArray
                    
                    for i in (0...responseData.count - 1) {
                        let tempArr:NSArray = responseData[i] as! NSArray
                        let code:String = tempArr[0] as! String
                        let category = tempArr[1] as! String
                        let kind = tempArr[2] as! String
                        let description = tempArr[3] as! String
                        let price = tempArr[4] as! String
                        let cost = tempArr[5] as! String
                        let type = tempArr[6] as! String
                        if clickStatus {
                            self.availableOfferList.append(OfferModel(code: code, category: category, kind: kind, description: description, price: price, cost: cost, varType: type))
                        } else {
                            self.disableOfferList.append(OfferModel(code: code, category: category, kind: kind, description: description, price: price, cost: cost, varType: type))
                        }
                    }
                    
                    self.shotOfferList(status: clickStatus)
                  
                } else if(responseCode == __RESULT_FAILED) {
                      QMUITips.hideAllTips()
                }
            }
        })
    }
    
    func shotOfferList(status:Bool) {
        QMUITips.hideAllTips()
        if status {
            offerArrayList = availableOfferList
        } else {
            offerArrayList = disableOfferList
        }
        
        offerTableView.reloadData()
    }
    
    func noticeConnectionSuccess() {
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
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
       
        timer.invalidate()
        counter = 0
        offerArrayList = availableOfferList
       
        categoryCollectionView.reloadData()
        offerTableView.reloadData()
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
                    self.noticeReqeustUDID = data["uuid"] as! String
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
        HttpRequest.getNoticeData(UDID: noticeReqeustUDID, didFuncLoad: {result, error in
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
                        self.noticeConnectionSuccess()
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
                       self.noticeConnectionSuccess()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return offerArrayList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfferNoticeTableViewCell") as! OfferNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let offer = offerArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfferTableViewCell") as! OfferTableViewCell
            cell.set(model: offer)
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
        else {
            let offer = offerArrayList[indexPath.row]
            currentOfferDescription = offer.description
            currentOfferCode = offer.code
            currentOfferCategory = offer.category
            currentOfferPrice = offer.price
            
            let moveController = self.storyboard?.instantiateViewController(withIdentifier: "OfferDetailViewController") as! OfferDetailViewController
            if #available(iOS 13.0, *) {
                moveController.modalPresentationStyle = .fullScreen
            }
            self.present(moveController, animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        bottomBarHeight.constant = 60.0
        let category = categoryList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCategoryCollectionViewCell", for: indexPath) as!  OfferCategoryCollectionViewCell
        cell.set(model: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            var selectedCategoryName = __DEFAULT_STRING
            if indexPath.row != 0 {
                selectedCategoryName = categoryList[indexPath.row].categoryName
            }
            selectedCategoryIndex = indexPath.row
            for i in (0...categoryList.count - 1) {
                categoryList[i].selectedStatus = false
            }
            categoryList[selectedCategoryIndex].selectedStatus = true
            bottomBarHeight.constant = 60.0
            categoryCollectionView.reloadData()
            getOfferWithCategory(clickStatus: !isToggleClicked, categoryName: selectedCategoryName)
        }
    }
}

extension OfferViewController:OfferNoticeTableViewCellDelegate {
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

extension OfferViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension OfferViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
