//
//  TransactionTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/12.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblOperationId: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(model: TransactionModel) {
        lblUserName.text = model.userName
        lblOperationId.text = model.operationId
        lblAmount.text = self.getDecimalFromString(strNumber: model.amount)
    }
    
    func getDecimalFromString(strNumber:String) -> String {
        let correctAmount = Double(strNumber)!
        let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
        return formattedDouble
    }

}
