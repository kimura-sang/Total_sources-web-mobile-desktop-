//
//  OfferDetailTableViewCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/22.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class OfferDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblUnit: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func set(model:OfferDetailModel) {
        lblNo.text = model.no
        lblDescription.text = model.description
        lblCount.text = model.count
        lblUnit.text = model.unit
    }
}
