//
//  ConsolidateWeeklyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ConsolidateWeeklyModel {
    var shopName:String
    var shopBranch:String
    var year:String
    var weekNo:String
    var amount:String
    var monthName:String
    var monthNo:String
    init(name:String, branch:String, year:String, weekNo:String, amount:String, monthName:String, monthNo:String) {
        self.shopName = name
        self.shopBranch = branch
        self.year = year
        self.weekNo = weekNo
        self.monthName = monthName
        self.monthNo = monthNo
        self.amount = amount
    }
}
