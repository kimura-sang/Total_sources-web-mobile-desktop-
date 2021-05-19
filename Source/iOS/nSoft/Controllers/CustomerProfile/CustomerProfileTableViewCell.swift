//
//  CustomerProfileTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class CustomerProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var imgTransaction: UIImageView!
    @IBOutlet weak var lblTransactionNumber: UILabel!
    @IBOutlet weak var lblTransactionDate: UILabel!
    @IBOutlet weak var lblTransactionAmount: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(model:CustomerTransactionModel) {
        lblTransactionNumber.text = model.operationId
        lblTransactionDate.text = model.dateTime
        
        if model.amount != "" {
            let correctAmount = Double(model.amount)!
            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
            lblTransactionAmount.text = String(formattedDouble)
        } else {
            lblTransactionAmount.text = model.amount
        }
        
        
        if !model.status {
            if model.no % 2 == 1 {
                statusView.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            } else {
                statusView.backgroundColor = UIColor.white
            }
            
            imgTransaction.image = UIImage(named: "ok_copy_icon")
            lblTransactionAmount.textColor = UIColor.black
            lblTransactionDate.textColor = UIColor.black
            lblTransactionNumber.textColor = UIColor.black
        } else {
            statusView.backgroundColor = UIColor.init(red: 249/255, green: 129/255, blue: 130/255, alpha: 1)
            imgTransaction.image = UIImage(named: "block_copy_icon")
            lblTransactionAmount.textColor = UIColor.white
            lblTransactionDate.textColor = UIColor.white
            lblTransactionNumber.textColor = UIColor.white
        }
    }
}
