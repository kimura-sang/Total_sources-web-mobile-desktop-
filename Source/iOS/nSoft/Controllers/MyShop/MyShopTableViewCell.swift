//
//  MyShopTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/11.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class MyShopTableViewCell: UITableViewCell {
    @IBOutlet weak var imgShop: UIImageView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblBranch: UILabel!
    @IBOutlet weak var statusView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor.init(red: 107/255, green: 220/255, blue: 86/255, alpha: 1)
            imgShop.image = UIImage(named: "icon_home_white")
            contentView.tintColor = UIColor.white
            lblShopName.textColor = UIColor.white
            lblBranch.textColor = UIColor.white
            lblAmount.textColor = UIColor.white
            //statusView.backgroundColor = UIColor.init(red: 101/255, green: 163/255, blue: 62/255, alpha: 1)
        } else {
            contentView.backgroundColor = UIColor.white
            lblShopName.textColor = UIColor.black
            lblBranch.textColor = UIColor.init(displayP3Red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
            lblAmount.textColor = UIColor.init(displayP3Red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
            imgShop?.image = UIImage(named: "home_clor_icon")
            //statusView.backgroundColor = UIColor.init(red: 183/255, green: 183/255, blue: 183/255, alpha: 1)
        }
        // Configure the view for the selected state
    }
    func set(shop:ShopModel) {
        statusView.layer.cornerRadius = 7.5
        if shop.onlineStatus != 1 {
            statusView.backgroundColor = UIColor.init(red: 183/255, green: 183/255, blue: 183/255, alpha: 1)
            lblAmount.text = String("0.00")
        } else {
            statusView.backgroundColor = UIColor.init(red: 101/255, green: 163/255, blue: 62/255, alpha: 1)
            let correctAmount = Double(shop.shopAmount)!
            let formattedDouble = String(format: "%.02f", locale: Locale.current, correctAmount)
            lblAmount.text = String(formattedDouble)
            
        }
        lblShopName.text = shop.shopName
        lblBranch.text = shop.shopBranch      
        
        
    }

}
