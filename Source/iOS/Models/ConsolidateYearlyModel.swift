//
//  ConsolidateYearlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ConsolidateYearlyModel {
    var shopName:String
    var shopBranch:String
    var year:String
    var amount:String
    init(name:String, branch:String, year:String, amount:String) {
        self.shopName = name
        self.shopBranch = branch
        self.year = year
        self.amount = amount
    }
}
