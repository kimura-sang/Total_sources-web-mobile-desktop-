//
//  MachineCollectionViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class MachineCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var wrapStatusView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    func set(model: MachineModel, status:String) {
        wrapStatusView.layer.cornerRadius = 7.0
        wrapStatusView.layer.borderWidth = 1.0
        wrapStatusView.layer.borderColor = UIColor.init(displayP3Red: 211/255, green: 211/255, blue: 211/255, alpha: 1).cgColor
        lblCount.text = model.no
        lblStatus.text = status
        if model.status == "AVAILABLE" {
            imgLogo.image = UIImage(named: "icon_machine_available")
        }
    }
}
