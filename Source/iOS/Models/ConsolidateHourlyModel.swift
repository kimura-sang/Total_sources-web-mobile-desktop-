//
//  ConsolidateHourlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ConsolidateHourlyModel {
    var shopName:String
    var shopBranch:String
    var no:String
    var dateTime:String
    var weekDay:String
    var numberTime:String
    var amount:String
    init(name:String, branch:String, no:String, dateTime:String, weekDay:String, numberTime:String, amount:String) {
        self.shopName = name
        self.shopBranch = branch
        self.dateTime = dateTime
        self.weekDay = weekDay
        self.no = no
        self.numberTime = numberTime
        self.amount = amount
    }
    
}
