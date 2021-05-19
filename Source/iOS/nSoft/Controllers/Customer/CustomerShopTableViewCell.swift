//
//  CustomerShopTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/17.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class CustomerShopTableViewCell: UITableViewCell {

    @IBOutlet weak var imgShop: UIImageView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblBranch: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor.green
            contentView.tintColor = UIColor.white
            lblShopName.textColor = UIColor.white
            lblBranch.textColor = UIColor.white
            lblAmount.textColor = UIColor.white
        } else {
            contentView.backgroundColor = UIColor.white
            lblShopName.textColor = UIColor.black
            lblBranch.textColor = UIColor.init(displayP3Red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
            lblAmount.textColor = UIColor.init(displayP3Red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
        }
        // Configure the view for the selected state
    }
    func set(shop:ShopModel) {
        lblShopName.text = shop.shopName
        lblBranch.text = shop.shopBranch
        lblAmount.text = shop.shopAmount
    }
}
