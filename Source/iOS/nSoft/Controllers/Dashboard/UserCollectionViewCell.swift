//
//  UserCollectionViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    func set(model:DashUserModel) {
        statusView.layer.cornerRadius = 6.0
        lblName.text = model.name
        imgUser.layer.cornerRadius = 17.5
        imgUser.layer.borderColor = UIColor.lightGray.cgColor
        imgUser.layer.borderWidth = 1.0
        if model.status == strStaffLogIn {
            statusView.backgroundColor = UIColor.init(red: 112/255, green: 173/255, blue: 71/255, alpha: 1)
        } else if model.status == strStaffLogOut {
            statusView.backgroundColor = UIColor.init(red: 232/255, green: 57/255, blue: 47/255, alpha: 1)
        } else {
            statusView.backgroundColor = UIColor.init(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        }
    }
    
}
