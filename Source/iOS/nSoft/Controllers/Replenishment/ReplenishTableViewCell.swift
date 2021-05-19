//
//  ReplenishTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit
protocol ReplenishTableViewCellDelegate {
    func deleteReplenishItem(id:String)
}
class ReplenishTableViewCell: UITableViewCell {
    @IBOutlet weak var lblItemId: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    var delegate:ReplenishTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func deleteItem(_ sender: Any) {
        delegate?.deleteReplenishItem(id: lblItemId.text!)
    }
    
    func set(model:ItemModel) {
        lblItemId.text = model.itemId
        lblName.text = model.itemName
        lblExpiryDate.text = model.expiredDate
//        if model.itemQty != "" {
//            let correctAmount = Double(model.itemQty)!
//            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
        lblAmount.text = model.itemQty + model.itemUnit
        //}
    }
}
