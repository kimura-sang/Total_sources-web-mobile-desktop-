//
//  CustomerProfileViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion
import MessageUI
import PullToRefresh
private let PageSize = 20

class CustomerProfileViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate var dataSourceCount = PageSize
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var customerTransactions:[CustomerTransactionModel] = []
    var customerName = ""
    var customerAddress = ""
    var customerMobile = ""
    var customerEmail = ""
    var customerBalance = ""
    var noticeArrayList:[NoticeModel] = []
    var isNoticeRequest = false
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var imgCustomer: UIImageView!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblCustomerName2: UILabel!
    @IBOutlet weak var lblCustomerAddress: UILabel!
    @IBOutlet weak var lblCustomerMobile: UILabel!
    @IBOutlet weak var lblCustomerEmail: UILabel!
    @IBOutlet weak var cannotConnectView: UIView!
    @IBOutlet weak var lblCustomerBalance: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var customerProfileTable: UITableView!
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
    
    @IBAction func previousProfile(_ sender: Any) {
        sendRequestToServer(sqlNo: __CUSTOMERS_PREV_DETAIL)
    }
    @IBAction func nextProfile(_ sender: Any) {
        sendRequestToServer(sqlNo: __CUSTOMERS_NEXT_DETAIL)
    }
    
    @IBAction func tryConnectAgain(_ sender: Any) {
        self.isNoticeRequest = false
        QMUITips.showLoading(" Loading ", in: self.view)
        cannotConnectView.isHidden = true
        startConnectTimer()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
           let controller = MFMessageComposeViewController()
           controller.body = ""
           controller.recipients = [customerMobile]
           controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func callCustomer(_ sender: Any) {
        if let url = NSURL(string: "tel://\(customerMobile)"),   UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    deinit {
        customerProfileTable.removeAllPullToRefresh()
    }
    @IBAction fileprivate func startRefreshing() {
        customerProfileTable.startRefreshing(at: .top)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        initUI()
        
        sendRequestToServer(sqlNo: __CUSTOMERS_SELECTED_DETAIL)
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
        refreshControl.backgroundColor = UIColor.init(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        refreshControl.addTarget(self, action: #selector(requestInventoryData), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func requestInventoryData() {
        let deadline = DispatchTime.now() + .milliseconds(800)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    func initUI(){
        if #available(iOS 10.0, *) {
            customerProfileTable.refreshControl = refresher
        } else {
            customerProfileTable.addSubview(refresher)
        }
        
        imgCustomer.layer.cornerRadius = 45.0
        imgCustomer.layer.borderWidth = 2.0
        imgCustomer.layer.borderColor = profileBorderColor
        if isRegularStatus {
            imgStatus.image = UIImage(named: "regular_icon")
        } else {
            imgStatus.image = UIImage(named: "premium_icon")
        }
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblCannotConnectMessage.text = "Cannot connect to " + SHOP_NAME + " " + SHOP_BRANCH
        bottomBarHeight.constant = 60.0
        noticeTable.backgroundColor = UIColor.white
        customerProfileTable.backgroundColor = UIColor.white
    }
    
    func sendRequestToServer(sqlNo:Int) {
       QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.requestUDIDWithSearchKey(machineId: MACHINE_ID, userID: userID, uniqueID: userUniqueID, requestBy: userEmail, sqlNo: sqlNo, statusID: __DATA_REQUESTED, searchKey: selectedCustomerID, didFuncLoad: { result, error in
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
    func stopTimer () {
        timer.invalidate()
        counter = 0
    }
    
    func startConnectTimer() {
       timer.invalidate()
       counter = 0
       timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getCustomer), userInfo: nil, repeats: true)
    }

    @objc func getCustomer() {
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
        HttpRequest.getCustomerProfileData(UDID: requestUDID, didFuncLoad: {result, error in
           if error != nil {
               QMUITips.hideAllTips()
                self.stopTimer()
               self.cannotConnectView.isHidden = false
               self.showDialog(title: "Warning", message: "Network error!")
           } else {
               self.customerTransactions = []
               var resultDicData: Dictionary = [String: Any]()
               resultDicData = result as! Dictionary
               let responseCode = resultDicData["code"] as! Int
               if responseCode == __RESULT_SUCCESS {
                   let responseData = resultDicData["data"] as AnyObject
                   var data: Dictionary = [String: Any]()
                   data = responseData as! Dictionary
                   let tempDetail = data["detail"] as! NSArray
                   let tempTransaction = data["transaction"] as! NSArray
                if tempDetail.count != 0 {
                       let tempArr = tempDetail[0] as! NSArray
                       selectedCustomerID = tempArr[0] as! String
                       self.customerName = (tempArr[1] as! String) + " " + (tempArr[2] as! String)
                       self.customerAddress = tempArr[4] as! String
                       self.customerEmail = tempArr[6] as! String
                       self.customerMobile = tempArr[5] as! String
                } else {
                    self.customerName = __DEFAULT_STRING
                    self.customerAddress = __DEFAULT_STRING
                    self.customerEmail = __DEFAULT_STRING
                    self.customerMobile = __DEFAULT_STRING
                }
                    
                if tempTransaction.count != 0 {
                    for i in (0...tempTransaction.count - 1) {
                        let tempArr = tempTransaction[i] as! NSArray
                        let id = tempArr[1] as! String
                        let dateTime = tempArr[0] as! String
                        let amount = tempArr[2] as! String
                        let statusFlag = tempArr[3] as! String
                        var status = false
                        if statusFlag != "" {
                            status = true
                        }
                        
                        self.customerTransactions.append(CustomerTransactionModel(no: i, id: id, dateTime: dateTime, amount: amount, status: status))
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

        timer.invalidate()
        counter = 0
        lblCustomerName.text = customerName
        lblCustomerName2.text = customerName
        lblCustomerAddress.text = customerAddress
        lblCustomerMobile.text = customerMobile
        if customerMobile != "" {
            btnCall.isHidden = false
            btnMessage.isHidden = false
        } else {
            btnCall.isHidden = true
            btnMessage.isHidden = true
        }
        lblCustomerEmail.text = customerEmail
        if customerBalance != "" {
            let correctAmount = Double(customerBalance)!
            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
            lblCustomerBalance.text = String(formattedDouble)
        } else {
            lblCustomerBalance.text = customerBalance
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
//        if customerTransactions.count > PageSize {
//            dataSourceCount = PageSize
//        } else {
//            dataSourceCount = customerTransactions.count
//        }
        customerProfileTable.reloadData()
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

extension CustomerProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTable {
           return noticeArrayList.count
        } else {
            return customerTransactions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if tableView == noticeTable {
             let notice = noticeArrayList[indexPath.row]
             let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerProfileNoticeTableViewCell") as! CustomerProfileNoticeTableViewCell
             cell.set(model: notice)
             cell.selectionStyle = .none
             cell.delegate = self
             return cell
          } else {
              let customerTransaction = customerTransactions[indexPath.row]
              let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerProfileTableViewCell") as! CustomerProfileTableViewCell
              cell.set(model: customerTransaction)
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

extension CustomerProfileViewController:CustomerProfileNoticeTableViewCellDelegate {
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
extension CustomerProfileViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension CustomerProfileViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}

private extension CustomerProfileViewController {
    
    func setupPullToRefresh() {
        customerProfileTable.addPullToRefresh(PullToRefresh()) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount = PageSize
                self?.customerProfileTable.endRefreshing(at: .top)
            }
        }
        
        customerProfileTable.addPullToRefresh(PullToRefresh(position: .bottom)) { [weak self] in
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self?.dataSourceCount += PageSize
                self?.customerProfileTable.reloadData()
                self?.customerProfileTable.endRefreshing(at: .bottom)
            }
        }
    }
}
