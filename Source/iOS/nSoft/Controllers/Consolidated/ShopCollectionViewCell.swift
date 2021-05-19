//
//  ShopCollectionViewCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopBranch: UILabel!
    @IBOutlet weak var wrapView: UIView!
    
    func set(model:BranchModel) {
        wrapView.layer.cornerRadius = 10.0
        lblShopName.text = model.branchName
        lblShopBranch.text = model.shopName
        if model.status {
            wrapView.layer.borderWidth = 2
            wrapView.layer.borderColor = UIColor.green.cgColor
        } else {
            wrapView.layer.borderWidth = 2
            wrapView.layer.borderColor = UIColor.gray.cgColor
        }
        wrapView.backgroundColor = UIColor.init(red: 0, green: 162/255, blue: 188/255, alpha: 1)
    }
}
