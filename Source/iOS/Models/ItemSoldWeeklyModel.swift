//
//  ItemSoldWeeklyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ItemSoldWeeklyModel {
    var itemName:String
    var monthName:String
    var week:Int
    var amount:String
    var itemCount:Int
    init(name:String, month:String, week:Int, amount:String, count:Int) {
        self.itemName = name
        self.monthName = month
        self.week = week
        self.amount = amount
        self.itemCount = count
    }
}
