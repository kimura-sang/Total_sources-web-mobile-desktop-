//
//  EmailBindingViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/28.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import QMUIKit

class EmailBindingViewController: UIViewController {
    var pageStatus = 0
    @IBOutlet weak var edtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var btnSendEmail: UIButton!
    @IBOutlet weak var EmailView: UIView!
    @IBOutlet weak var btnSendVerificationCode: UIButton!
    @IBOutlet weak var VerificationView: UIView!
    @IBOutlet weak var edtVCode: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnSendEmail.layer.cornerRadius = 20.0
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trySendEmail(_ sender: Any) {
       if edtEmail.text == "" {
            self.showDialog(title: "Warning", message: "Please input email")
        } else if !edtEmail.text!.isValidEmail() {
            self.showDialog(title: "Warning", message: "Please input correct email address")
        } else {
            QMUITips.showLoading(" Loading ", in: self.view)
            HttpRequest.sendEmailForSDKBinding(userId: userID, email: edtEmail.text!, didFuncLoad: { result, error in
                if error != nil {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Networrk Error")
                } else {
                    var resultDicData: Dictionary = [String: Any]()
                    resultDicData = result as! Dictionary
                    let responseCode = resultDicData["code"] as! Int
                    if responseCode == __RESULT_SUCCESS {
                        QMUITips.hideAllTips()
                        self.pageStatus = 1
                        let responseData = resultDicData["data"] as AnyObject
                        var data: Dictionary = [String: Any]()
                        data = responseData as! Dictionary
                        userID = data["userId"] as! String
                        
                        self.showDialog(title: "Warning", message: "Send email successfully")
                        
                    } else if(responseCode == __RESULT_EMAIL_DUPLICATED) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Your email already exist")
                    } else if(responseCode == __RESULT_SEND_EMAIL_FAILED) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Eamil sending failed")
                    } else if(responseCode == __RESULT_FAILED) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Failed")
                    }
                }
            })
        }
    }
    
    @IBAction func trySendVerificationCode(_ sender: Any) {
        if edtVCode.text == "" {
            self.showDialog(title: "Warning", message: "Please input verification code")
        } else {
            QMUITips.showLoading(" Loading ", in: self.view)
            HttpRequest.sendVerificationCodeForBinding(userId: userID, code: edtVCode.text!, didFuncLoad: { result, error in
                if error != nil {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Networrk Error")
                } else {
                    var resultDicData: Dictionary = [String: Any]()
                    resultDicData = result as! Dictionary
                    let responseCode = resultDicData["code"] as! Int
                    if responseCode == __RESULT_SUCCESS {
                        QMUITips.hideAllTips()
                        self.pageStatus = 2
                        self.showDialog(title: "Warning", message: "Email binding success")
                    } else if(responseCode == __RESULT_VERIFICATION_CODE_USED) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Verification code already used")
                    } else if(responseCode == __RESULT_VERIFICATION_CODE_INCORRECT) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Verification code is incorrect")
                    } else if(responseCode == __RESULT_FAILED) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Failed")
                    }
                }
            })
        }
    }
    
    func showDialog(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              switch action.style{
              case .default:
                    print("default")
                    if self.pageStatus == 0 {
                        self.EmailView.isHidden = false
                        self.VerificationView.isHidden = true
                    }
                    if self.pageStatus == 1 {
                        self.EmailView.isHidden = true
                        self.VerificationView.isHidden = false
                    } else if self.pageStatus == 2 {
                        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        if #available(iOS 13.0, *) {
                            moveController.modalPresentationStyle = .fullScreen
                        }
                        self.present(moveController, animated: true, completion: nil)
                    }
              case .cancel:
                    print("cancel")
                    self.dismiss(animated: true, completion: nil)

              case .destructive:
                    print("destructive")
                    self.dismiss(animated: true, completion: nil)


        }}))
        self.present(alert, animated: true, completion: nil)
    }
}
