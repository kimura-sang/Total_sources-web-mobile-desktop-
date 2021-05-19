//
//  ItemSoldModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ItemSoldDailyModel {
    var itemName:String
    var dateTime:String
    var weekDay:String
    var day:String
    var amount:String
    var itemCount:Int
    init(name:String, dateTime:String, weekDay:String, day:String, amount:String, count:Int) {
        self.itemName = name
        self.dateTime = dateTime
        self.weekDay = weekDay
        self.day = day
        self.amount = amount
        self.itemCount = count
    }
}
