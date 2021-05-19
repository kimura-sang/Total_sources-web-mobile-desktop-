//
//  OfferCategoryCollectionViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/14.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class OfferCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var lblCategory: UILabel!
    
    func set(model:OfferCategoryModel) {
        wrapView.layer.cornerRadius = 17.0
        wrapView.layer.borderWidth = 1.0
        wrapView.layer.borderColor = UIColor.white.cgColor
        lblCategory.text =  model.categoryName
        if model.selectedStatus {
            wrapView.backgroundColor = UIColor.init(displayP3Red: 140/255, green: 199/255, blue: 217/255, alpha: 1)
            
        } else {
            wrapView.backgroundColor = UIColor.init(displayP3Red: 0, green: 162/255, blue: 188/255, alpha: 1)
        }
    }
}
