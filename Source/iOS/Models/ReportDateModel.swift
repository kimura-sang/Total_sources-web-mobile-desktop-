//
//  ReportDateModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/23.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ReportDateModel {
    var selectedStatus:Bool
    var selectedCategory:String
    init(category:String, status:Bool) {
        self.selectedStatus = status
        self.selectedCategory = category
    }
}
