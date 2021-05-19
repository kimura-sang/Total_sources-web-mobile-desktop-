//
//  CustomerTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/12.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

protocol CustomerTableViewCellDelegate {
    func sendMessage(phoneNumber:String)
    func callCustomer(phoneNumber:String)
}
class CustomerTableViewCell: UITableViewCell {
    @IBOutlet weak var imgCustomer: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lblValueView: UIView!
    @IBOutlet weak var lblValue: UILabel!
    var phoneNumber = ""
    var delegate:CustomerTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCustomer.layer.cornerRadius = 20
        imgCustomer.layer.borderWidth = 1.0
        imgCustomer.layer.borderColor = UIColor.lightGray.cgColor
        lblValueView.layer.cornerRadius = 17.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func trySendMessage(_ sender: Any) {
        delegate?.sendMessage(phoneNumber: phoneNumber)
    }
    
    @IBAction func tryCallCustomer(_ sender: Any) {
        delegate?.callCustomer(phoneNumber: phoneNumber)
    }
    func set(model:CustomerModel) {
        phoneNumber = model.id
        lblName.text = model.firstName + " " + model.lastName
        lblPhone.text = model.id
        if model.amount != "" {
            lblAmount.text = self.getDecimalFromString(strNumber: model.amount)
        }
        lblValue.text = String(model.dayNumber)
        if model.dayNumber < 9 {
            lblValueView.backgroundColor = UIColor(red: 181/255, green: 230/255, blue: 29/255, alpha: 1)
        } else if model.dayNumber < 17 {
            lblValueView.backgroundColor = UIColor(red: 251/255, green: 218/255, blue: 53/255, alpha: 1)
        } else {
            lblValueView.backgroundColor = UIColor(red: 255/255, green: 104/255, blue: 6/255, alpha: 1)
        }
        
    }

    func getDecimalFromString(strNumber:String) -> String {
        let correctAmount = Double(strNumber)!
        let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
        return formattedDouble
    }
}
