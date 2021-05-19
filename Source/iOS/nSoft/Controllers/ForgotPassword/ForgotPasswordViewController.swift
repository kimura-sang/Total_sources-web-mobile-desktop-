//
//  ForgotPasswordViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import SkyFloatingLabelTextField
import Motion

class ForgotPasswordViewController: UIViewController {
    var pageStatus = 0
    var isClickShowPassword = false
    var isClickShowConfirmPassword = false
    @IBOutlet weak var edtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var edtVerificationCode: SkyFloatingLabelTextField!
    @IBOutlet weak var edtNewPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var edtConfirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var btnSendEmail: UIButton!
    @IBOutlet weak var btnSendVerificationCOde: UIButton!
    @IBOutlet weak var btnSetPassword: UIButton!
    @IBOutlet weak var btnConfirmPassword: UIButton!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var btnPassword: UIButton!
    @IBAction func toggleConfirmPassword(_ sender: Any) {
        if isClickShowConfirmPassword {
            edtConfirmPassword.isSecureTextEntry = true
            btnConfirmPassword.setImage(UIImage(named: "hidden_password"), for: .normal)
        } else {
            edtConfirmPassword.isSecureTextEntry = false
            btnConfirmPassword.setImage(UIImage(named: "show_password"), for: .normal)
        }
        isClickShowConfirmPassword = !isClickShowConfirmPassword
    }
    
    @IBAction func togglePassword(_ sender: Any) {
        if isClickShowPassword {
            edtNewPassword.isSecureTextEntry = true
            btnPassword.setImage(UIImage(named: "hidden_password"), for: .normal)
        } else {
            edtNewPassword.isSecureTextEntry = false
            btnPassword.setImage(UIImage(named: "show_password"), for: .normal)
        }
        isClickShowPassword = !isClickShowPassword
    }
    @IBAction func sendVerification(_ sender: Any) {
        sendVCode()
    }
    @IBAction func sendEmail(_ sender: Any) {
        sendEmailForChangePassword()
    }
    @IBAction func tryChangePassword(_ sender: Any) {
        changePassword()
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    func initUI() {
        btnSendEmail.layer.cornerRadius = 20.0
        btnSendVerificationCOde.layer.cornerRadius = 20.0
        alphaView.layer.cornerRadius = mainViewCornerRadius
        btnSetPassword.layer.cornerRadius = 20.0
        emailView.isHidden = false
        verificationView.isHidden = true
        passwordView.isHidden = true
        edtNewPassword.setRightPaddingPoints(20.0)
        edtConfirmPassword.setRightPaddingPoints(20.0)
    }
    

    func sendEmailForChangePassword() {
        if edtEmail.text == "" {
            self.showDialog(title: "Warning", message: "Please input email")
        } else if !edtEmail.text!.isValidEmail() {
            self.showDialog(title: "Warning", message: "Please input correct email address")
        } else {
            QMUITips.showLoading(" Loading ", in: self.view)
            HttpRequest.sendEmailForChangePassword(email: edtEmail.text!, didFuncLoad: { result, error in
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
                        
                    } else if(responseCode == __RESULT_EMAIL_INCORRECT) {
                        QMUITips.hideAllTips()
                        self.showDialog(title: "Warning", message: "Your email is incorrect")
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
    
    
    func sendVCode() {
        self.pageStatus = 2
        if edtVerificationCode.text == "" {
            self.showDialog(title: "Warning", message: "Please input verification code")
        } else {
            QMUITips.showLoading(" Loading ", in: self.view)
            HttpRequest.sendVCodeForChangePassword(userId: userID, code: edtVerificationCode.text!, didFuncLoad: { result, error in
                if error != nil {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Networrk Error")
                } else {
                    var resultDicData: Dictionary = [String: Any]()
                    resultDicData = result as! Dictionary
                    let responseCode = resultDicData["code"] as! Int
                    if responseCode == __RESULT_SUCCESS {
                        QMUITips.hideAllTips()
                        self.emailView.isHidden = true
                        self.verificationView.isHidden = true
                        self.passwordView.isHidden = false
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
    
    func changePassword() {
        self.pageStatus = 3
           if edtNewPassword.text == "" {
               self.showDialog(title: "Warning", message: "Please input new password")
           } else if edtConfirmPassword.text == "" {
                self.showDialog(title: "Warning", message: "Please input confirm password")
           } else if edtConfirmPassword.text != edtNewPassword.text {
                self.showDialog(title: "Warning", message: "Please input correct password")
           } else {
               let newPassword = edtNewPassword.text
               QMUITips.showLoading(" Loading ", in: self.view)
            HttpRequest.changePassword(userId: userID, password: (newPassword?.md5())!, didFuncLoad: { result, error in
                   if error != nil {
                       QMUITips.hideAllTips()
                       self.showDialog(title: "Warning", message: "Networrk Error")
                   } else {
                       var resultDicData: Dictionary = [String: Any]()
                       resultDicData = result as! Dictionary
                       let responseCode = resultDicData["code"] as! Int
                       if responseCode == __RESULT_SUCCESS {
                        
                           QMUITips.hideAllTips()
                           self.pageStatus = 4
                           self.showDialog(title: "", message: "Password changed successfully")
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
                        self.emailView.isHidden = false
                        self.verificationView.isHidden = true
                        self.passwordView.isHidden = true
                    }
                    if self.pageStatus == 1 {
                        self.emailView.isHidden = true
                        self.verificationView.isHidden = false
                        self.passwordView.isHidden = true
                    } else if self.pageStatus == 2 {
                        self.emailView.isHidden = true
                        self.verificationView.isHidden = false
                        self.passwordView.isHidden = true
                }
                    else if self.pageStatus == 3 {
                        self.emailView.isHidden = true
                        self.verificationView.isHidden = true
                        self.passwordView.isHidden = false
                    } else if self.pageStatus == 4 {
                        self.dismiss(animated: true, completion: nil)
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

extension ForgotPasswordViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension ForgotPasswordViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
