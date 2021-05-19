//
//  CategoryCollectionViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var lblCategoryName: UILabel!
    func set(model: DashCategoryModel) {
        wrapView.layer.cornerRadius = 17.0
        wrapView.layer.borderWidth = 1.0
        wrapView.layer.borderColor = UIColor.white.cgColor
        lblCategoryName.text =  model.categoryName
        if model.selectedStatus {
            wrapView.backgroundColor = UIColor.init(displayP3Red: 140/255, green: 199/255, blue: 217/255, alpha: 1)
            
        } else {
            wrapView.backgroundColor = topViewColor
        }
    }
}
