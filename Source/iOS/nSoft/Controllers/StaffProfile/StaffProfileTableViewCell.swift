//
//  StaffProfileTableViewCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/22.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class StaffProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var amountWrapView: UIView!
    @IBOutlet weak var timeWrapView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblTimeOut: UILabel!
    @IBOutlet weak var lblTimeIn: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var wrapView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        amountWrapView.layer.cornerRadius = 17.5
        amountWrapView.layer.borderWidth = 2.0
        amountWrapView.layer.borderColor = UIColor.init(red: 44/255, green: 79/255, blue: 135/255, alpha: 1).cgColor
        timeWrapView.layer.cornerRadius = 5.0
        timeWrapView.layer.borderWidth = 1.0
        timeWrapView.layer.borderColor = UIColor.init(red: 44/255, green: 79/255, blue: 135/255, alpha: 1).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func set(model:StaffTransactionModel) {
        lblAmount.text = model.no
        lblDate.text = model.transactionDate
        lblTimeIn.text = model.timeIn
        lblTimeOut.text = model.timeOut
    }
}
