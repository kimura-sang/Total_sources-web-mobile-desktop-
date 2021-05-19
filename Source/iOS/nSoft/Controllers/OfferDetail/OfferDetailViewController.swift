//
//  OfferDetailViewController.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion

class OfferDetailViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var offerDetails:[OfferDetailModel] = []
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    
    @IBOutlet weak var lblCannotConnectMessage: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var edtPrice: UITextField!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var offerDetailTableView: UITableView!
    @IBOutlet weak var wrapTableView: UIView!
    @IBOutlet weak var cannotConnectView: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareView()
        prepareTransition()
        initUI()
        sendRequestToServer(sqlNo: __OFFERS_GET_DETAIL, searchKey: currentOfferCode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBackFromNoticeDetail {
            isBackFromNoticeDetail = false
            sendNoticeRequest(sqlNo: __NOTICE_GET, searchKey: __EMPTY_STRING)
        }
    }
    
    func initUI(){
        noticeTable.backgroundColor = UIColor.white
        offerDetailTableView.backgroundColor = UIColor.white
        topView.layer.cornerRadius = mainViewCornerRadius
        mainView.layer.cornerRadius = mainViewCornerRadius
        lblDescription.text = currentOfferDescription
        lblCode.text = currentOfferCode
        lblCategory.text = currentOfferCategory
        
        if currentOfferPrice != "" {
            let correctAmount = Double(currentOfferPrice)!
            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
            edtPrice.text = String(formattedDouble)
        } else {
            edtPrice.text = currentOfferPrice
        }
        
        btnSave.layer.cornerRadius = 17.0
        wrapTableView.layer.borderWidth = 1.0
        wrapTableView.layer.borderColor = UIColor.init(red: 163/255, green: 161/255, blue: 161/255, alpha: 1).cgColor
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        bottomBarHeight.constant = 60.0
    }
    
    @IBAction func saveOfferDetails(_ sender: Any) {
        if edtPrice.text == "" {
            self.showDialog(title: "Warning", message: "Please input price")
        } else {
            sendRequestToServer(sqlNo: __OFFERS_SAVE_DETAIL, searchKey: edtPrice.text! + "_" + currentOfferCode)
        }
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
                        if sqlNo == __OFFERS_SAVE_DETAIL {
                            QMUITips.hideAllTips()
                            self.showDialog(title: "", message: "Offer price saved successfully")
                        } else if sqlNo == __OFFERS_GET_DETAIL {
                          let responseData = resultDicData["data"] as AnyObject
                          var data: Dictionary = [String: Any]()
                          data = responseData as! Dictionary
                           self.requestUDID = data["uuid"] as! String
                           self.startConnectTimer()
                        }
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
        offerDetailTableView.reloadData()
    }
    
    func getRequestData() {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.getOfferDetailData(UDID: requestUDID, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.stopTimer()
                self.cannotConnectView.isHidden = false
                self.showDialog(title: "Warning", message: "Network error!")
            } else {
                self.offerDetails = []
                
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    let tempContent = data["content"] as! NSArray
                    
                    if tempContent.count != 0 {
                        for i in (0...tempContent.count - 1) {
                            let tempArr:NSArray = tempContent[i] as! NSArray
                            let description:String = tempArr[1] as! String
                            let count:String = tempArr[2] as! String
                            let unit:String = tempArr[3] as! String
                            self.offerDetails.append(OfferDetailModel(no: String(i + 1), description: description, count: count, unit: unit))
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

extension OfferDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
            return noticeArrayList.count
        } else {
            return offerDetails.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTable {
           let notice = noticeArrayList[indexPath.row]
           let cell = tableView.dequeueReusableCell(withIdentifier: "OfferDetailNoticeTableViewCell") as! OfferDetailNoticeTableViewCell
           cell.set(model: notice)
           cell.selectionStyle = .none
           cell.delegate = self
           return cell
        } else {
            let offerDetail = offerDetails[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfferDetailTableViewCell") as! OfferDetailTableViewCell
            cell.set(model: offerDetail)
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

extension OfferDetailViewController:OfferDetailNoticeTableViewCellDelegate {
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
extension OfferDetailViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension OfferDetailViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
