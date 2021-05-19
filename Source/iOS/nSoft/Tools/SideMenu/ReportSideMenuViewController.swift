//
//  ReportSideMenuViewController.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
import SDWebImage


class ReportSideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnUserImg: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userPhotoUrl != "" {
                imgUser.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "staff_user.png"))
        
            }
        
        wrapView.layer.cornerRadius = 42.5
        wrapView.layer.borderWidth = 2.0
        wrapView.layer.borderColor = UIColor(red: 59/255, green: 47/255, blue: 44/255, alpha: 1).cgColor
        lblUserName.text = userName
        self.menuTable.backgroundColor = UIColor.white
        let rowToSelect:NSIndexPath = NSIndexPath(row: selectedReportMenuIndex, section: 0);
        self.menuTable.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
    }
    @IBAction func goUserInfo(_ sender: Any) {
        isClickMenuHeader = true
        
        dismiss(animated: true, completion: {
        })
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = reportMenuItems[indexPath.row]
       
        let cellView = tableView.dequeueReusableCell(withIdentifier: "ReportSideMenuCell", for: indexPath) as! ReportSideMenuCell
        cellView.set(imageName: menu[0], menuName: menu[2])
        return cellView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReportMenuIndex = indexPath.row
        if let cell = tableView.cellForRow(at: indexPath){
            let menuImage = cell.viewWithTag(11) as? UIImageView
            menuImage?.image = UIImage(named: reportMenuItems[indexPath.row][1])
        }
        
        isClickReportMenu = true
        
        dismiss(animated: true, completion: {
        })
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let menuImage = cell.viewWithTag(11) as? UIImageView
            menuImage?.image = UIImage(named: reportMenuItems[indexPath.row][0])
        }
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
