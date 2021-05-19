//
//  ConsolidateDailyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ConsolidateDailyModel {
    var shopName:String
    var shopBranch:String
    var no:String
    var dateTime:String
    var month:String
    var day:String
    var amount:String
    init(name:String, branch:String, no:String, dateTime:String, month:String, day:String, amount:String) {
        self.shopName = name
        self.shopBranch = branch
        self.no = no
        self.dateTime = dateTime
        self.month = month
        self.day = day
        self.amount = amount
    }
}
