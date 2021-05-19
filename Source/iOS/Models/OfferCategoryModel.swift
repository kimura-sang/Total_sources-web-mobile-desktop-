//
//  OfferCategoryModel.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class OfferCategoryModel {
    var categoryNo:Int
    var categoryName:String
    var selectedStatus:Bool
    init(no:Int, name:String, status:Bool) {
        self.categoryNo = no
        self.categoryName = name
        self.selectedStatus = status
    }
}
