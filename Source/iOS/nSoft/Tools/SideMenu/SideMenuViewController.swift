//
//  SideMenuViewController.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

protocol SideMenuViewControllerDelegate: class{
    func closeController()
}

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = menuItems[indexPath.row]
       
        let cellView = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
        cellView.set(imageName: menu[0], menuName: menu[2])
        return cellView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMenuIndex = indexPath.row
        if let cell = tableView.cellForRow(at: indexPath){
            let menuImage = cell.viewWithTag(11) as? UIImageView
            menuImage?.image = UIImage(named: menuItems[indexPath.row][1])
        }
        
        isClickMenu = true
        if selectedMenuIndex == 8 {
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
        }
        
        dismiss(animated: true, completion: {
        })
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let menuImage = cell.viewWithTag(11) as? UIImageView
            menuImage?.image = UIImage(named: menuItems[indexPath.row][0])
        }
    }
    
    @IBAction func goUserInfo(_ sender: Any) {
        isClickMenuHeader = true
        
        dismiss(animated: true, completion: {
        })
    }
    @IBOutlet weak var menuTableView: UITableView!
    //@IBOutlet weak var imgUserPhoto: UIImageView!
    var delegate:SideMenuViewControllerDelegate?

    @IBOutlet weak var btnUserImg: UIButton!
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userPhotoUrl != "" {
            imgUser.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "staff_user.png"))

        }
        
//        Alamofire.request( method: .GET, parameters: nil, encoding: ParameterEncoding.URL).response {
//            (request, response, data, error) -> Void in
//            if  let imageData = data as? NSData,
//                let image = UIImage(data: imageData) {
//                    self.imgUser.setImage(image, forState: .Normal)
//            }
//        }
        

//        let imageData: NSData = NSData(contentsOf: NSURL(string: userPhotoUrl) as! URL)!
//        self.imgUser.image = UIImage(data: imageData as Data)!
        
        wrapView.layer.cornerRadius = 42.5
        wrapView.layer.borderWidth = 2.0
        wrapView.layer.borderColor = UIColor(red: 59/255, green: 47/255, blue: 44/255, alpha: 1).cgColor
        lblUserName.text = userName
        self.menuTableView.backgroundColor = UIColor.white
        let rowToSelect:NSIndexPath = NSIndexPath(row: selectedMenuIndex, section: 0);
        self.menuTableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
}
