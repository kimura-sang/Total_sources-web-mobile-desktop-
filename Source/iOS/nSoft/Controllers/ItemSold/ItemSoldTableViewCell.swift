//
//  ItemSoldTableViewCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class ItemSoldTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func set(model:ReportModel) {
        lblTime.text = model.title1
        if String(model.amount) != "" {
           let correctAmount = Double(String(model.amount))!
           let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
           lblAmount.text = String(formattedDouble)
        } else {
            lblAmount.text = String(model.amount)
        }
    }

}
