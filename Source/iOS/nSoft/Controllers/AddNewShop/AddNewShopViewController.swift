//
//  AddNewShopViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion

class AddNewShopViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
         reader.stopScanning()

           dismiss(animated: true) { [weak self] in
//             let alert = UIAlertController(
//               title: "QRCodeReader",
//               message: String (format:"%@ (of type %@)", result.value, result.metadataType),
//               preferredStyle: .alert
//             )
//             alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//
//             self?.present(alert, animated: true, completion: nil)
            let resultArr = result.value as! String
            let data = resultArr.split(separator: ",")
            if data.count == 3 {
                let machineID:String = String(data[2])
                self!.edtMachine.text = machineID
                self!.edtShopName.text = String(data[1])
                self!.edtBranch.text = String(data[0])
            } else {
                self?.showDialog(title: "Warning", message: "This is invalid code")
            }
           
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
         reader.stopScanning()

           dismiss(animated: true, completion: nil)
    }
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var requestNoticeUDID = ""
    var noticeArrayList:[NoticeModel] = []
    var isClickHiddenBtn = false
    var isClickActionBtn = false
    var selectedNoticeNo = ""
    var isAddSuccess = false
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var noticeTable: UITableView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var edtBranch: UITextField!
    @IBOutlet weak var edtShopName: UITextField!
    @IBOutlet weak var edtMachineID: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var edtMachine: UITextView!
    @IBOutlet weak var btnAddShop: UIButton!
    
    lazy var reader: QRCodeReader = QRCodeReader()
     lazy var readerVC: QRCodeReaderViewController = {
       let builder = QRCodeReaderViewControllerBuilder {
         $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
         $0.showTorchButton         = true
         $0.preferredStatusBarStyle = .lightContent
         $0.showOverlayView         = true
         $0.rectOfInterest          = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.5)
         
         $0.reader.stopScanningWhenCodeIsFound = false
       }
       
       return QRCodeReaderViewController(builder: builder)
     }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareTransition()
        // Do any additional setup after loading the view.
        isBackFromAddShop = true
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func initUI(){
        lblShopName.backgroundColor = UIColor.white
        mainView.layer.cornerRadius = mainViewCornerRadius
        btnAddShop.layer.cornerRadius = 23.0
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        self.bottomBarHeight.constant = 60
        noticeTable.backgroundColor = UIColor.white
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func showQRScanner(_ sender: Any) {
        guard checkScanPermissions() else { return }

        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self

        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
          if let result = result {
            print("Completion with result: \(result.value) of type \(result.metadataType)")
          }
        }

        present(readerVC, animated: true, completion: nil)
    }
    
    func showDialog(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              switch action.style{
              case .default:
                    print("default")
                    if self.isAddSuccess {
                        self.isAddSuccess = false
                        self.dismiss(animated: true, completion: nil)
                    }
              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")


        }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tryAddNewShop(_ sender: Any) {
        var branch = edtBranch.text
        if edtMachine.text == "" {
            self.showDialog(title: "Warning", message: "Please input machine id")
        } else if edtShopName.text == "" {
            self.showDialog(title: "Warning", message: "Please input shop name")
        } else {
            if edtBranch.text == "" {
                branch = __EMPTY_STRING
            }
            QMUITips.showLoading("Loading", in: self.view)
            HttpRequest.addNewShop(shopName: edtShopName.text!, machineID: edtMachine.text!, branch: branch!, userId: userID, didFuncLoad: { result, error in
                       if error != nil {
                           QMUITips.hideAllTips()
                           self.showDialog(title: "Warning", message: "Networrk Error")
                       } else {
                           var resultDicData: Dictionary = [String: Any]()
                           resultDicData = result as! Dictionary
                           let responseCode = resultDicData["code"] as! Int
                           if responseCode == __RESULT_SUCCESS {
                               QMUITips.hideAllTips()
                               self.isAddSuccess = true
                               self.showDialog(title: "", message: "New shop successfully added")
                           } else if(responseCode == __RESULT_MACHINE_ID_EXIST) {
                               QMUITips.hideAllTips()
                               self.showDialog(title: "Warning", message: "This machine id already exist")
                           } else if(responseCode == __RESULT_FAILED) {
                               QMUITips.hideAllTips()
                               self.showDialog(title: "Warning", message: "Shop adding is failed")
                           }
                           
                       }
             })
        }
    }
    
    
    private func checkScanPermissions() -> Bool {
      do {
        return try QRCodeReader.supportsMetadataObjectTypes()
      } catch let error as NSError {
        let alert: UIAlertController

        switch error.code {
        case -11852:
          alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

          alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
            DispatchQueue.main.async {
              if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
              }
            }
          }))

          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        default:
          alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }

        present(alert, animated: true, completion: nil)

        return false
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
    func stopTimer() {
        timer.invalidate()
        counter = 0
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
}
extension AddNewShopViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return noticeArrayList.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let notice = noticeArrayList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddShopNoticeTableViewCell") as! AddShopNoticeTableViewCell
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
extension AddNewShopViewController:AddShopNoticeTableViewCellDelegate {
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

extension AddNewShopViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension AddNewShopViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
