//
//  ReplenishCategoryCollectionViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class ReplenishCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    func set(model:OfferCategoryModel) {
        lblCategoryName.text = model.categoryName
        wrapView.layer.cornerRadius = 17.0
        wrapView.layer.borderWidth = 1.0
        wrapView.layer.borderColor = UIColor.white.cgColor
        if model.selectedStatus {
            wrapView.backgroundColor = UIColor.init(displayP3Red: 140/255, green: 199/255, blue: 217/255, alpha: 1)
        } else {
           wrapView.backgroundColor = UIColor.init(displayP3Red: 0, green: 162/255, blue: 188/255, alpha: 1)
        }
    }
    
    func setBounds(bounds: CGRect) {
        super.bounds = bounds
        self.contentView.frame = bounds
    }
}
