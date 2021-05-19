//
//  DateCollectionViewCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/23.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var lblCategory: UILabel!

    func set(model:ReportDateModel) {
        wrapView.layer.cornerRadius = 17.0
        wrapView.layer.borderWidth = 1.0
        wrapView.layer.borderColor = UIColor.white.cgColor
        lblCategory.text =  model.selectedCategory
        if model.selectedStatus {
           wrapView.backgroundColor = UIColor.init(displayP3Red: 140/255, green: 199/255, blue: 217/255, alpha: 1)
           
        } else {
           wrapView.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 162/255, blue: 188/255, alpha: 1)
        }
    }
}
