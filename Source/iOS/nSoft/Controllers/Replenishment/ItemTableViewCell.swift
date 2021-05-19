//
//  ItemTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

protocol ItemTableViewCellDelegate {
    func addItem(itemCode:String, itemName:String, quantity:String, unit:String, expireDate:String)
    func errorMessage(type:Int)
}
class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var lblItemId: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var edtQty: UITextField!
    @IBOutlet weak var dateWrapView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    var delegate:ItemTableViewCellDelegate?
    @IBAction func addNewItem(_ sender: Any) {
        if edtQty.text == "" {
            delegate?.errorMessage(type: QUANTITY_EMPTY)
        } else {
            //delegate?.errorMessage(type: EXPIRED_DATE_EMPTY)
            var expiredDate:String = __EMPTY_STRING
            if lblDate.text != "expiry" {
                expiredDate = lblDate.text!
            }
            delegate?.addItem(itemCode: lblCode.text!, itemName:lblName.text!, quantity: edtQty.text!, unit: lblUnit.text!, expireDate: expiredDate)
        }
    }
    @IBAction func addDate(_ sender: Any) {
        RPicker.selectDate { (selectedDate) in
            // TODO: Your implementation for date
            let date = Date()
            let selectedExpiredDate = selectedDate.dateString("yyyy-MM-dd")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "UTC") // set locale to reliable US_POSIX as Locale
            let expiredDate = dateFormatter.date(from: selectedExpiredDate)!
            if date > expiredDate {
                
            } else {
                self.lblDate.text = selectedExpiredDate
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateWrapView.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    func set(model:ItemModel) {
        lblItemId.text = model.itemId
        lblName.text = model.itemName
        lblCode.text = model.itemCode
        lblUnit.text = model.itemUnit
        
    }

}
