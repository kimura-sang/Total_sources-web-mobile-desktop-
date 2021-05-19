//
//  ReplenishmentViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion
import PullToRefresh
private let PageSize = 20

class ReplenishmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var timer = Timer()
    var counter = 0
    var isFirst:Bool = true
    var isInsertItems:Bool = false
    var requestUDID = ""
    var requestNoticeUDID = ""
    var currentCheckedCategoryNo:Int = 0
    var currentCheckdItemNo:Int = 0
    var currentCheckedCategoryName:String = ""
    var replenishItemDetailObjectArrayList:[ReplenishModel] = []
    var itemViewArrayList:[ItemModel] = []
    var itemViewCategoryArrayList:[ItemModel] = []
    var listCategories:[OfferCategoryModel] = []
    var listItems:[String] = []
    var selectedCategoryIndex:Int = 0
    var selectedCategoryName = ""
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    fileprivate var dataSourceCount = PageSize
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var btnReplenish: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomHeaderView: UIView!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var replenishTableView: UITableView!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        QMUITips.showLoading(" Loading ", in: self.view)
        cannotConnectView.isHidden = true
        startConnectTimer()
    }
    @IBAction func trySaveItems(_ sender: Any) {
        if itemViewArrayList.count > 0 {
            isInsertItems = true
            self.showConfirmDialog(title: "Notice", message: "Do you really want to replenish item?")
            //self.saveReplenishItems(sqlNo: String(__OFFERS_REPLENISH_SAVE))
        } else {
            self.showDialog(title: "Warning", message: "There is no items")
        }
    }
    deinit {
        replenishTableView.removeAllPullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        initUI()
        self.isFirst = true
        self.sendRequestToServer(sqlNo: __OFFERS_REPLENISH_GET_CATEGORY, searchKey: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBackFromNoticeDetail {
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
            replenishTableView.refreshControl = refresher
        } else {
            replenishTableView.addSubview(refresher)
        }
        
        topView.layer.cornerRadius = mainViewCornerRadius
        topHeaderView.layer.cornerRadius = mainViewCornerRadius
        bottomView.layer.cornerRadius = mainViewCornerRadius
        bottomHeaderView.layer.cornerRadius = mainViewCornerRadius
        btnReplenish.layer.cornerRadius = 20.0
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        bottomBarHeight.constant = 60.0
        noticeTable.backgroundColor = UIColor.white
        replenishTableView.backgroundColor = UIColor.white
        itemTableView.backgroundColor = UIColor.white
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
        HttpRequest.getItemOptions(UDID: requestUDID, didFuncLoad: {result, error in
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
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    let tempOptions = data["options"] as! NSArray
                    
                    if !self.isFirst {
                        //QMUITips.hideAllTips()
                        self.replenishItemDetailObjectArrayList = []
                        self.listItems = []
                        if tempOptions.count > 0 {
                            for i in (0...tempOptions.count - 1) {
                                let tempArr:NSArray = tempOptions[i] as! NSArray
                                let itemName:String = tempArr[0] as! String
                                let unit:String = tempArr[1] as! String
                                let itemCode:String = tempArr[2] as! String
                                self.replenishItemDetailObjectArrayList.append(ReplenishModel(no: String(i), code: itemCode, name: itemName, unit: unit, expiredDate: "000", quantity: ""))
                                self.listItems.append(itemName)
                            }
                            self.currentCheckdItemNo = 0
                        }
                        self.getTempReplenishItem()
                    } else {
                        self.isFirst = false
                        self.replenishItemDetailObjectArrayList = []
                        self.listCategories = []
                        if tempOptions.count > 0{
                            for i in (0...tempOptions.count - 1) {
                                let tempArr:NSArray = tempOptions[i] as! NSArray
                                let name:String = tempArr[0] as! String
                                self.replenishItemDetailObjectArrayList.append(ReplenishModel(no: String(i), code: "", name: name, unit: "", expiredDate: "", quantity: ""))
                                
                                if self.selectedCategoryIndex == i {
                                    self.listCategories.append(OfferCategoryModel(no: i, name: name, status: true))
                                } else {
                                    self.listCategories.append(OfferCategoryModel(no: i, name: name, status: false))
                                }
                            }
                        }
                        self.currentCheckedCategoryNo = 0
                        self.currentCheckedCategoryName = self.listCategories[0].categoryName
                        self.sendRequestToServer(sqlNo: __OFFERS_REPLENISH_GET_CATEGORY_DETAIL, searchKey: self.currentCheckedCategoryName)
                    }
                    
                    //self.connectionSuccess()
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
    
    func getTempReplenishItem() {
        HttpRequest.getTempReplenishList(accountId: String(userID), machineId: MACHINE_ID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    self.itemViewArrayList = []
                    if responseData.count > 0{
                        for i in (0...responseData.count - 1) {
                            let itemData = responseData[i] as AnyObject
                            var temp: Dictionary = [String: Any]()
                            temp = itemData as! Dictionary
                            let id:String = temp["id"] as! String
                            let strQuantity:String = temp["quantity"] as! String
                            let strCode:String = temp["item_code"] as! String
                            let strName:String = temp["item_name"] as! String
                            let strUnit:String = temp["unit"] as! String
                            var strDate = "0000-00-00"
                            if !(temp["expired_date"] is NSNull) {
                                strDate = temp["expired_date"] as! String
                            }
                            self.itemViewArrayList.append(ItemModel(id: id, itemCode: strCode, itemName: strName, unit: strUnit, expiredDate: strDate, quantity: strQuantity))
                        }
                    }
                    self.connectionSuccess()
                   
                } else if responseCode == __RESULT_FAILED {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Get replenish items failed")
                }
            }
        })
    }
    
    func addNewItem(itemCode:String, itemName:String, quantity:String, unit:String, expiredDate:String) {
        HttpRequest.addNewItem(userId: userID, machineId: MACHINE_ID, code: itemCode, name: itemName, qty: quantity, unit: unit, expiredDate: expiredDate, didFuncLoad: {result, error in
            if error != nil {
                //QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    self.itemViewArrayList = []
                    if responseData.count > 0{
                        for i in (0...responseData.count - 1) {
                            let itemData = responseData[i] as AnyObject
                            var temp: Dictionary = [String: Any]()
                            temp = itemData as! Dictionary
                            let id:String = temp["id"] as! String
                            let strQuantity:String = temp["quantity"] as! String
                            let strCode:String = temp["item_code"] as! String
                            let strName:String = temp["item_name"] as! String
                            let strUnit:String = temp["unit"] as! String
                            var strDate = "0000-00-00"
                            if !(temp["expired_date"] is NSNull) {
                                strDate = temp["expired_date"] as! String
                            }
                            self.itemViewArrayList.append(ItemModel(id: id, itemCode: strCode, itemName: strName, unit: strUnit, expiredDate: strDate, quantity: strQuantity))
                        }
                    }
                    
                    self.replenishTableView.reloadData()
                } else if responseCode == __RESULT_FAILED {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Get replenish items failed")
                }
            }
        })
    }
    
    func deleteItem(itemId:String) {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.deleteSelectedItem(userId: userID, machineId: MACHINE_ID, itemId:itemId, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error")
            } else {
                QMUITips.hideAllTips()
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as! NSArray
                    self.itemViewArrayList = []
                    if responseData.count > 0{
                        for i in (0...responseData.count - 1) {
                            let itemData = responseData[i] as AnyObject
                            var temp: Dictionary = [String: Any]()
                            temp = itemData as! Dictionary
                            let id:String = temp["id"] as! String
                            let strQuantity:String = temp["quantity"] as! String
                            let strCode:String = temp["item_code"] as! String
                            let strName:String = temp["item_name"] as! String
                            let strUnit:String = temp["unit"] as! String
                            var strDate:String = ""
                            if !(temp["expired_date"] is NSNull) {
                                strDate = temp["expired_date"] as! String
                            }
                            self.itemViewArrayList.append(ItemModel(id: id, itemCode: strCode, itemName: strName, unit: strUnit, expiredDate: strDate, quantity: strQuantity))
                        }
                    }
                    
                    self.replenishTableView.reloadData()
                } else if responseCode == __RESULT_FAILED {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Get replenish items failed")
                }
            }
        })
    }
    
    func saveReplenishItems(sqlNo:String) {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.saveItemReplenish(machineId: MACHINE_ID, userEmail: userEmail, sqlNo: sqlNo, statusId: String(__DATA_REQUESTED), userId: userID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    QMUITips.hideAllTips()
                    self.itemViewArrayList = []
                    self.replenishTableView.reloadData()
                    self.showDialog(title: "Warning", message: "Items successfully replenished")
                } else if responseCode == __RESULT_FAILED {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Item save failed")
                }
            }
        })
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
       
        timer.invalidate()
        counter = 0
        itemViewCategoryArrayList = []
        if replenishItemDetailObjectArrayList.count > 0 {
            for i in (0...replenishItemDetailObjectArrayList.count - 1) {
                itemViewCategoryArrayList.append(ItemModel(id: replenishItemDetailObjectArrayList[i].itemNo, itemCode: replenishItemDetailObjectArrayList[i].itemCode, itemName: replenishItemDetailObjectArrayList[i].itemName, unit: replenishItemDetailObjectArrayList[i].unit, expiredDate: replenishItemDetailObjectArrayList[i].expiredDate, quantity: replenishItemDetailObjectArrayList[i].quantity))
            }
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
        noticeTable.reloadData()
        itemTableView.reloadData()
        categoryCollectionView.reloadData()
        replenishTableView.reloadData()
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
//                   if self.isInsertItems {
//                        self.isInsertItems = false
//                        self.saveReplenishItems(sqlNo: String(__OFFERS_REPLENISH_SAVE))
//                    }

             case .cancel:
                   print("cancel")

             case .destructive:
                   print("destructive")


       }}))
       self.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmDialog(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            self.saveReplenishItems(sqlNo: String(__OFFERS_REPLENISH_SAVE))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
             print("Handle Canel logic here")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemTableView {
            return itemViewCategoryArrayList.count
        } else if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return itemViewArrayList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == itemTableView {
            let item = itemViewCategoryArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as! ItemTableViewCell
            cell.set(model: item)
            cell.selectionStyle = .none
            cell.edtQty.delegate = self
            cell.edtQty.keyboardType = .numberPad
            cell.delegate = self
            return cell
        } else if tableView == noticeTable {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplenishNoticeTableViewCell") as! ReplenishNoticeTableViewCell
            cell.set(model: notice)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
           let replenish = itemViewArrayList[indexPath.row]
           let cell = tableView.dequeueReusableCell(withIdentifier: "ReplenishTableViewCell") as! ReplenishTableViewCell
           cell.set(model: replenish)
            cell.delegate = self
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
            if let cell = tableView.cellForRow(at: indexPath){
                cell.backgroundColor = UIColor.init(red: 107/255, green: 220/255, blue: 86/255, alpha: 0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(listCategories.count)
        return listCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = listCategories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReplenishCategoryCollectionViewCell", for: indexPath) as! ReplenishCategoryCollectionViewCell
        cell.set(model: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            var selectedCategoryName = __DEFAULT_STRING
            if indexPath.row != 0 {
                selectedCategoryName = listCategories[indexPath.row].categoryName
            }
            selectedCategoryIndex = indexPath.row
            for i in (0...listCategories.count - 1) {
                listCategories[i].selectedStatus = false
            }
            listCategories[selectedCategoryIndex].selectedStatus = true
            //categoryCollectionView.reloadData()
            bottomBarHeight.constant = 60.0
            sendRequestToServer(sqlNo: __OFFERS_REPLENISH_GET_CATEGORY_DETAIL, searchKey: selectedCategoryName)
        }
    }
}

extension ReplenishmentViewController:ItemTableViewCellDelegate {
    func addItem(itemCode: String, itemName: String, quantity: String, unit: String, expireDate: String) {
        addNewItem(itemCode: itemCode, itemName: itemName, quantity: quantity, unit: unit, expiredDate: expireDate)
    }
    
    func errorMessage(type: Int) {
        if type == QUANTITY_EMPTY {
            showDialog(title: "Warning", message: "Please input quantity")
        } else if type == EXPIRED_DATE_EMPTY {
            showDialog(title: "Warning", message: "Please select expired date")
        }
    }
    
}

extension ReplenishmentViewController:ReplenishTableViewCellDelegate {
    func deleteReplenishItem(id: String) {
        deleteItem(itemId: id)
    }
}

extension ReplenishmentViewController:ReplenishNoticeTableViewCellDelegate {
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

extension ReplenishmentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
           return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}

extension ReplenishmentViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension ReplenishmentViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}

private extension ReplenishmentViewController {
    func setupPullToRefresh() {
        replenishTableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount = PageSize
                self?.replenishTableView.endRefreshing(at: .top)
            }
        }
        
//        replenishTableView.addPullToRefresh(PullToRefresh(position: .bottom)) { [weak self] in
//            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//            DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                self?.dataSourceCount += PageSize
//                self?.replenishTableView.reloadData()
//                self?.replenishTableView.endRefreshing(at: .bottom)
//            }
//        }
    }
}
