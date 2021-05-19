//
//  NoticeDetailViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import Motion

class NoticeDetailViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var requestUDID = ""
    var isFirst = true
    var isClickHiddenBtn = false
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgNoticeType: UIImageView!
    @IBOutlet weak var contenView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var tvNoticeContent: UITextView!
    @IBOutlet weak var lblNoticeTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        updateNoticeAsViewed()
    }
    func updateNoticeAsViewed() {
        if currentNoticeViewStatus != "True" {
            isFirst = true
            sendNoticeRequest(sqlNo: __NOTICE_VIEWED, searchKey: currentNoticeNo)
        } else {
            isFirst = false
        }
    }
    func initUI() {
        self.mainView.layer.cornerRadius = 10.0
        self.btnYes.layer.cornerRadius = 10.0
        self.btnNo.layer.cornerRadius = 10.0
        self.btnHide.layer.cornerRadius = 10.0
        self.contenView.layer.borderWidth = 1.0
        self.contenView.layer.borderColor = UIColor.init(red: 243/255, green: 243/255, blue: 243/255, alpha: 1).cgColor
      
        lblShopName.text = SHOP_NAME
        lblShopBranch.text = SHOP_BRANCH
        lblNoticeTitle.text = currentNoticeTitle
        tvNoticeContent.text = currentNoticeContent
        tvNoticeContent.isEditable = false
        if currentNoticeViewStatus != "True" {
            lblNoticeTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        if currentNoticeType == __NOTICE_REQUEST {
            imgNoticeType.image = UIImage(named: "icon_notice_question")
            if currentNoticeActionStatus != "True" {
                actionView.isHidden = false
                btnHide.isHidden = true
            } else {
                actionView.isHidden = true
                btnHide.isHidden = false
            }
        } else if currentNoticeType == __NOTICE_NOTICE {
            actionView.isHidden = true
            btnHide.isHidden = false
            imgNoticeType.image = UIImage(named: "icon_notice_bell")
        } else if currentNoticeType == __NOTICE_MESSAGE {
            actionView.isHidden = true
            btnHide.isHidden = false
            imgNoticeType.image = UIImage(named: "icon_notice_post")
        } else if currentNoticeType == __NOTICE_WARNING {
            actionView.isHidden = true
            btnHide.isHidden = false
            imgNoticeType.image = UIImage(named: "icon_notice_remark")
        }
        
    }
    
    @IBAction func tryDisagree(_ sender: Any) {
        sendNoticeRequest(sqlNo: __NOTICE_ACTED, searchKey: currentNoticeNo + "_0")
    }
    
    @IBAction func tryAgree(_ sender: Any) {
        sendNoticeRequest(sqlNo: __NOTICE_ACTED, searchKey: currentNoticeNo + "_1")
    }
    
    @IBAction func tryHide(_ sender: Any) {
        isClickHiddenBtn = true
        sendNoticeRequest(sqlNo: __NOTICE_ACTED, searchKey: currentNoticeNo)
    }
    
    @IBAction func goBack(_ sender: Any) {
        isBackFromNoticeDetail = true
        self.dismiss(animated: true, completion: nil)
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
    
    func getNoticeData() {
        HttpRequest.getNoticeData(UDID: requestUDID, didFuncLoad: {result, error in
           if error != nil {
               self.stopTimer()
               QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Network error!")
           } else {
               var resultDicData: Dictionary = [String: Any]()
               resultDicData = result as! Dictionary
               let responseCode = resultDicData["code"] as! Int
               if responseCode == __RESULT_SUCCESS {
                   
                self.connectionSuccess()
                //self.showDialog(title: "", message: "Network error!")
           } else {
              if self.counter >=  __SERVER_CONNECTION_COUNT {
                 QMUITips.hideAllTips()
                self.stopTimer()
             }
            }
         }
      })
    }
    
    func connectionSuccess() {
        QMUITips.hideAllTips()
        
        timer.invalidate()
        counter = 0
        if !isFirst {
            if currentNoticeType == __NOTICE_REQUEST {
                if isClickHiddenBtn {
                    self.btnHide.isHidden = true
                    self.actionView.isHidden = true
                } else {
                    self.actionView.isHidden = true
                    self.btnHide.isHidden = false
                }
            } else {
               btnHide.isHidden = true
               actionView.isHidden = true
            }
        } else {
            isFirst = false
        }
       
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


extension NoticeDetailViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension NoticeDetailViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
