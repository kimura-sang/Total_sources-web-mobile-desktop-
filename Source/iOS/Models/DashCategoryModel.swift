//
//  DashCategoryModel.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class DashCategoryModel {
    var categoryName:String
    var categoryNo:Int
    var selectedStatus:Bool
    init(no:Int, name:String, status:Bool) {
        self.categoryNo = no
        self.categoryName = name
        self.selectedStatus = status
    }
}
