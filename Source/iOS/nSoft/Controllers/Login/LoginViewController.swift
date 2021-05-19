//
//  LoginViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import QMUIKit
import SideMenu
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import Google
import GoogleSignIn
import CommonCrypto
import Motion

class LoginViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var edtUserName: UITextField!
    @IBOutlet weak var edtUserPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var alphaView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareView()
        prepareTransition()
        initUI()
        if defaultSettings.object(forKey: "IS_LOGOUT") != nil {
            let logoutStatus = defaultSettings.object(forKey: "IS_LOGOUT") as! String
            if logoutStatus != "LOGOUT" {
                if defaultSettings.object(forKey: "SDK_TYPE") != nil {
                    let sdkType = defaultSettings.object(forKey: "SDK_TYPE") as! String
                    if sdkType == "1" || sdkType == "2" {
                        let sdkType = defaultSettings.object(forKey: "SDK_TYPE") as! String
                        if Int(sdkType) == sdkFacebook {
                            let manager = LoginManager()
                            manager.logIn(permissions: [.publicProfile], viewController: self, completion: {(result) in
                                switch result{
                                case .success(let grantedPermissions, let decliendPermissions, let accessToken):
                                    print("Success")
                                    self.getProfileFromFB(token: accessToken.tokenString)
                                case .cancelled:
                                    print("Cancelled")
                                case .failed(_):
                                    print("Failed")
                                }
                            })
                        } else if Int(sdkType) == sdkGoogle {
                            GIDSignIn.sharedInstance().delegate = self
                            GIDSignIn.sharedInstance().uiDelegate = self
                            GIDSignIn.sharedInstance().signIn()
                        }
                    } else {
                        if defaultSettings.object(forKey: "USER_EMAIL") != nil {
                            if (defaultSettings.object(forKey: "USER_EMAIL") as! String) != "" {
                                let userName = defaultSettings.object(forKey: "USER_EMAIL") as! String
                                let userPassword = defaultSettings.object(forKey: "USER_PASSWORD") as! String
                                //edtUserName.text = userName
                                //edtUserPassword.text = userPassword
                                self.login(email: userName, password: userPassword)
                            }
                        }
                    }
                } else {
                    if defaultSettings.object(forKey: "USER_EMAIL") != nil {
                        if (defaultSettings.object(forKey: "USER_EMAIL") as! String) != "" {
                            let userName = defaultSettings.object(forKey: "USER_EMAIL") as! String
                            let userPassword = defaultSettings.object(forKey: "USER_PASSWORD") as! String
                            //edtUserName.text = userName
                            //edtUserPassword.text = userPassword
                            self.login(email: userName, password: userPassword)
                        }
                    }
                }
            }
        }
    }
    
    func initUI(){
        selectedMenuIndex = 0
        btnLogin.layer.cornerRadius = 20.0
        
        alphaView.layer.cornerRadius = mainViewCornerRadius
    }
    func login(email:String, password:String) {
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.tryLogin(email: email, password: password , didFuncLoad: { result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Networrk Error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    QMUITips.hideAllTips()
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    userID = data["id"] as! String
                    userEmail = data["email"] as! String
                    userName = (data["first_name"] as! String) + " " + (data["last_name"] as! String)
                    userExpiredDate = data["expired_date"] as! String
                    userOwnerLevel = Int(data["owner_level"] as! String)!

                    if !(data["photo_url"] is NSNull) {
                        userPhotoUrl = data["photo_url"] as! String
                    }
                    
                    userPassword = data["password"] as! String
                    userUniqueID = data["unique_id"] as! String
                    
                    if defaultSettings.object(forKey: "MACHINE_ID") != nil && defaultSettings.object(forKey: "USER_EMAIL") != nil {
                        let userMail = defaultSettings.object(forKey: "USER_EMAIL") as! String
                        if userEmail == userMail {
                            MACHINE_ID = defaultSettings.object(forKey: "MACHINE_ID") as! String
                            SHOP_NAME = defaultSettings.object(forKey: "SHOP_NAME") as! String
                            SHOP_BRANCH = defaultSettings.object(forKey: "SHOP_BRANCH") as! String
                        }
                    }
                    defaultSettings.set("", forKey: "SDK_TYPE")
                    defaultSettings.set("LOGIN", forKey: "IS_LOGOUT")
                    defaultSettings.set(userEmail, forKey: "USER_EMAIL")
                    defaultSettings.set(userPassword, forKey: "USER_PASSWORD")
                    //self.dismiss(animated: true, completion: nil)
                    let moveController = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                    if #available(iOS 13.0, *) {
                        moveController.modalPresentationStyle = .fullScreen
                    }
                    self.present(moveController, animated: true, completion: nil)
                    
                } else if(responseCode == __RESULT_OVER_EXPIRED) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Please call nsofts for subscription")
                } else if(responseCode == __RESULT_FAILED) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Login Failed")
                } else if(responseCode == __RESULT_EMAIL_PASSWORD_INCORRECT) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Email or password is incorrect")
                }
            }
        })
    }
    @IBAction func tryLogin(_ sender: Any) {
        if edtUserName.text == "" {
            showDialog(title: "Warning", message: "Please input user name")
        } else if edtUserPassword.text == "" {
            showDialog(title: "Warning", message: "Please input password")
        } else if !edtUserName.text!.isValidEmail() {
            showDialog(title: "Warning", message: "Please input correct email address")
        } else {
            self.login(email: edtUserName.text!, password: (edtUserPassword.text?.md5())!)
        }
    }
    
    func getProfileFromFB(token:String){
       GraphRequest(graphPath: "me", parameters: ["fields": "id,name,first_name,last_name,email"]).start(completionHandler: {(connection, result, error) -> Void in

           if(error != nil) {
               print("Some error occurred.");
           } else {
               print(result!)
               var data: Dictionary = [String: Any]()
               data = result as! Dictionary
               let id = data["id"] as! String
               let firstName = data["first_name"] as! String
               let lastName = data["last_name"] as! String
               let email = data["email"] as! String
               var facebookProfileUrl = "http://graph.facebook.com/\(id)/picture?type=large"
            self.trySocialLogin(email: id, photoUrl: facebookProfileUrl, sdkType: sdkFacebook)
           }
       })
    }
    
    func trySocialLogin(email:String, photoUrl:String, sdkType:Int) {
        HttpRequest.trySocalLogin(email: email, photoUrl: photoUrl, sdkType: sdkType, didFuncLoad: { result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Networrk Error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    QMUITips.hideAllTips()
                    let responseData = resultDicData["data"] as AnyObject
                    var data: Dictionary = [String: Any]()
                    data = responseData as! Dictionary
                    userID = data["id"] as! String
                    
                    if sdkType == sdkFacebook {
                        userFacebookId = data["facebook_id"] as! String
                    } else if sdkType == sdkGoogle {
                        userGoogleId = data["google_id"] as! String
                    }
                    userEmailBindingStatus = data["email_binding_status"] as! String
                    if userEmailBindingStatus == "1" {
                        userEmail = data["email"] as! String
                        userName = (data["first_name"] as! String) + " " + (data["last_name"] as! String)
                        userExpiredDate = data["expired_date"] as! String
                        userOwnerLevel = Int(data["owner_level"] as! String)!
                        userPassword = data["password"] as! String
                        userUniqueID = data["unique_id"] as! String
                        if !(data["photo_url"] is NSNull) {
                            userPhotoUrl = data["photo_url"] as! String
                        }
                        
                        if defaultSettings.object(forKey: "MACHINE_ID") != nil && defaultSettings.object(forKey: "USER_EMAIL") != nil {
                            let userMail = defaultSettings.object(forKey: "USER_EMAIL") as! String
                            if userEmail == userMail {
                                MACHINE_ID = defaultSettings.object(forKey: "MACHINE_ID") as! String
                                SHOP_NAME = defaultSettings.object(forKey: "SHOP_NAME") as! String
                                SHOP_BRANCH = defaultSettings.object(forKey: "SHOP_BRANCH") as! String
                            }
                        }
                        defaultSettings.set("LOGIN", forKey: "IS_LOGOUT")
                        defaultSettings.set(String(sdkType), forKey: "SDK_TYPE")
                        defaultSettings.set(email, forKey: "SDK_ID")
                        defaultSettings.set(userEmail, forKey: "USER_EMAIL")
                        defaultSettings.set(userPassword, forKey: "USER_PASSWORD")
                        //self.dismiss(animated: true, completion: nil)
                        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                        if #available(iOS 13.0, *) {
                            moveController.modalPresentationStyle = .fullScreen
                        }
                        self.present(moveController, animated: true, completion: nil)
                    } else {
                        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "EmailBindingViewController") as! EmailBindingViewController
                        if #available(iOS 13.0, *) {
                            moveController.modalPresentationStyle = .fullScreen
                        }
                        self.present(moveController, animated: true, completion: nil)
                    }
                    
                } else if(responseCode == __RESULT_OVER_EXPIRED) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Please call nsofts for subscription")
                } else if(responseCode == __RESULT_FAILED) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Login Failed")
                } else if(responseCode == __RESULT_EMAIL_PASSWORD_INCORRECT) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "This account doesn't exist")
                }
            }
        })
    }
    
    @IBAction func tryLoginWithFb(_ sender: Any) {
        let manager = LoginManager()
        manager.logIn(permissions: [.publicProfile], viewController: self, completion: {(result) in
            switch result{
            case .success(let grantedPermissions, let decliendPermissions, let accessToken):
                print("Success")
                self.getProfileFromFB(token: accessToken.tokenString)
            case .cancelled:
                print("Cancelled")
            case .failed(_):
                print("Failed")
            }
        })
    }
    
    @IBAction func tryLoginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginButtonCompleteLogin(_ loginButton: FBLoginButton, result: LoginResult) {
        switch result {
        case .failed(let _):
            print("Error")
        case .cancelled:
            print("Cancelled")
        case .success(let grantedPermissions, let decliendPermissions, let accessToken):
            print("Success")
        default:
            print("Default")
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User Logged out")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let email = user.profile.email
            let familyName = user.profile.familyName
            let photoUrl = user.profile.imageURL(withDimension: 100)?.absoluteString
            
            self.trySocialLogin(email: userId!, photoUrl: photoUrl!, sdkType: sdkGoogle)
            // ...
        } else {
            print("error")
        }
    }
    
    @IBAction func goToForgotPassword(_ sender: Any) {
        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        if #available(iOS 13.0, *) {
            moveController.modalPresentationStyle = .fullScreen
        }
        self.present(moveController, animated: true, completion: nil)
    }
    
    @IBAction func goToRegister(_ sender: Any) {
        let moveController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        if #available(iOS 13.0, *) {
            moveController.modalPresentationStyle = .fullScreen
        }
        self.present(moveController, animated: true, completion: nil)
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

extension LoginViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension LoginViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
