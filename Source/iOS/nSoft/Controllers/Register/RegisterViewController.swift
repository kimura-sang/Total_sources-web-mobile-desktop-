//
//  RegisterViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import Google
import GoogleSignIn
import CommonCrypto
import QMUIKit
import Motion

class RegisterViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate  {
     
    @IBOutlet weak var edtFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var edtSecondName: SkyFloatingLabelTextField!
    @IBOutlet weak var edtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var edtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var edtConfirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnConfirmPassword: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var alphaView: UIView!
    var isClickShowPassword = false
    var isClickShowConfirmPassword = false
    var isRegisterSuccess = false
    var isSocialRegisterSuccess = false
    
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
            edtPassword.isSecureTextEntry = true
            btnPassword.setImage(UIImage(named: "hidden_password"), for: .normal)
        } else {
            edtPassword.isSecureTextEntry = false
            btnPassword.setImage(UIImage(named: "show_password"), for: .normal)
        }
        isClickShowPassword = !isClickShowPassword
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareView()
        prepareTransition()
        initUI()
    }
    func initUI(){
        edtFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor])
        edtSecondName.attributedPlaceholder = NSAttributedString(string: "Lsat Name", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor])
        edtEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor])
        edtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor])
        edtConfirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm password", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor])
        
        btnRegister.layer.cornerRadius = 20.0
        alphaView.layer.cornerRadius = mainViewCornerRadius
        edtPassword.setRightPaddingPoints(25.0)
        edtConfirmPassword.setRightPaddingPoints(25.0)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tryRegister(_ sender: Any) {
        if edtFirstName.text == "" {
            self.showDialog(title: "Warning", message: "Please input first name")
        } else if edtSecondName.text == "" {
            self.showDialog(title: "Warning", message: "Please input last name")
        } else if edtEmail.text == "" {
            self.showDialog(title: "Warning", message: "Please input email")
        } else if edtPassword.text == "" {
            self.showDialog(title: "Warning", message: "Please input password")
        } else if edtConfirmPassword.text == "" {
            self.showDialog(title: "Warning", message: "Please input confirm passwrod")
        } else if !edtEmail.text!.isValidEmail() {
            showDialog(title: "Warning", message: "Please input correct email address")
        } else if edtPassword.text != edtConfirmPassword.text {
            self.showDialog(title: "Warning", message: "Please input correct password.")
        } else {
            register(firstName: edtFirstName.text!, lastName: edtSecondName.text!, email: edtEmail.text!, password: edtPassword.text!.md5())
        }
    }
    func register(firstName:String, lastName:String, email:String, password:String){
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.tryRegister(firstName: firstName, lastName: lastName, email: email, password: password, didFuncLoad: {result, error in
            if error != nil {
                QMUITips.hideAllTips()
                self.showDialog(title: "Warning", message: "Networrk Error")
            } else {
                var resultDicData: Dictionary = [String: Any]()
                resultDicData = result as! Dictionary
                let responseCode = resultDicData["code"] as! Int
                if responseCode == __RESULT_SUCCESS {
                    QMUITips.hideAllTips()
                   
                    self.isRegisterSuccess = true
                    self.showDialog(title: "", message: "Please wait for account activation, or call nSofts for activation")
                    
                } else if(responseCode == __RESULT_EMAIL_DUPLICATED) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "This email already exist")
                } else if(responseCode == __RESULT_FAILED) {
                    QMUITips.hideAllTips()
                    self.showDialog(title: "Warning", message: "Register Failed")
                }
            }
        })
    }
    
    func trySocialRegister(id:String, firstName:String, lastName:String, email:String, photoUrl:String, type:Int){
        QMUITips.showLoading(" Loading ", in: self.view)
        HttpRequest.tryRegisterWithSocial(firstName: firstName, lastName: lastName, email: email, photoUrl: photoUrl, sdkId: id, type: type, didFuncLoad: {result, error in
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
                            if userEmail == "" {
                                self.isSocialRegisterSuccess = true
                            } else {
                                self.isRegisterSuccess = true
                            }
                           
                           self.showDialog(title: "", message: "Please wait for account activation, or call nSofts for activation")
                           
                       } else if(responseCode == __RESULT_EMAIL_DUPLICATED) {
                           QMUITips.hideAllTips()
                           self.showDialog(title: "Warning", message: "This account already exist")
                       } else if(responseCode == __RESULT_FAILED) {
                           QMUITips.hideAllTips()
                           self.showDialog(title: "Warning", message: "Register Failed")
                       }
                   }
               })
    }
    
    @IBAction func tryRegisterFromGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func tryRegisterFromFB(_ sender: Any) {
        let manager = LoginManager()
        manager.logIn(permissions: [.publicProfile, .email], viewController: self, completion: {(result) in
            switch result{
            case .success(let grantedPermissions, let decliendPermissions, let accessToken):
                self.getProfileFromFB(token: accessToken.tokenString)
                print("Success")
            case .cancelled:
                print("Cancelled")
            case .failed(_):
                print("Failed")
            }
        })
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
            self.trySocialRegister(id: id, firstName: firstName, lastName: lastName, email: email, photoUrl: facebookProfileUrl, type: sdkFacebook)
           }
       })
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
            trySocialRegister(id: userId!, firstName: givenName!, lastName: familyName!, email: email!, photoUrl: photoUrl!, type: sdkGoogle)
            // ...
          } else {
            print("error")
          }
   }
    
  
    
    func showDialog(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
             switch action.style{
             case .default:
                   print("default")
                   if self.isRegisterSuccess {
                       self.dismiss(animated: true, completion: nil)
                   } else if self.isSocialRegisterSuccess {
                      let moveController = self.storyboard?.instantiateViewController(withIdentifier: "EmailBindingViewController") as! EmailBindingViewController
                    if #available(iOS 13.0, *) {
                        moveController.modalPresentationStyle = .fullScreen
                    }
                      self.present(moveController, animated: true, completion: nil)
                   }
             case .cancel:
                   print("cancel")

             case .destructive:
                   print("destructive")


        }}))
        self.present(alert, animated: true, completion: nil)
    }
}

extension RegisterViewController {
    fileprivate func prepareView() {
        isMotionEnabled = true
    }
    
    fileprivate func prepareTransition() {
        transitionFade()
    }
}

extension RegisterViewController {
    fileprivate func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
}
