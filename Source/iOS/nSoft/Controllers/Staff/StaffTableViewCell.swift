//
//  StaffTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class StaffTableViewCell: UITableViewCell {
    @IBOutlet weak var imgStaff: UIImageView!
    @IBOutlet weak var lblStaffName: UILabel!
    @IBOutlet weak var lblStaffRole: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var lblStaffNo: UILabel!
    @IBOutlet weak var staffNumView: UIView!
    @IBOutlet weak var lblTimeIn: UILabel!
    @IBOutlet weak var lblTimeOut: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusView.layer.cornerRadius = 5.0
        imgStaff.layer.cornerRadius = 20
        imgStaff.layer.borderWidth = 1.0
        imgStaff.layer.borderColor = UIColor.lightGray.cgColor
        staffNumView.layer.cornerRadius = 17.5
        staffNumView.layer.borderWidth = 1.0
        staffNumView.layer.borderColor = UIColor(red: 44/255, green: 79/255, blue: 135/255, alpha: 1).cgColor
        timeView.layer.cornerRadius = 5.0
        timeView.layer.borderWidth = 1.0
        timeView.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(model:StaffModel) {
        lblStaffName.text = model.name
        lblStaffRole.text = model.role
        lblTimeIn.text = model.timeIn
        lblTimeOut.text = model.timeOut
        lblStaffNo.text = model.shiftNo
        
        if model.timeIn == "" && model.timeOut == "" {
            statusView.backgroundColor = UIColor.init(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        } else if model.timeIn != "" && model.timeOut == ""{
            statusView.backgroundColor = UIColor.init(red: 112/255, green: 173/255, blue: 71/255, alpha: 1)
        } else {
            statusView.backgroundColor = UIColor.init(red: 232/255, green: 57/255, blue: 47/255, alpha: 1)
        }
    }
}
