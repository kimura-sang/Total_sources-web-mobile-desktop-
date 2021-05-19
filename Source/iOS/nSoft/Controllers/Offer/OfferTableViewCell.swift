//
//  OfferTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/14.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class OfferTableViewCell: UITableViewCell {
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(model:OfferModel) {
        lblName.text = model.code
        lblDate.text = model.description
        lblAmount.text = model.price
        if model.price != "" {
            let correctAmount = Double(model.price)!
            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
            lblAmount.text = String(formattedDouble)
        } else {
            lblAmount.text = model.price
        }
        if model.kind == "Item" {
            imgLogo.image = UIImage(named: "icon_item")
        } else if model.kind == "Service" {
            imgLogo.image = UIImage(named: "icon_service")
        } else {
            imgLogo.image = UIImage(named: "icon_package")
        }
    }
}
