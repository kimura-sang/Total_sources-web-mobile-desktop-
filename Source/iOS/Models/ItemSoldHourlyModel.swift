//
//  ItemSoldHourlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ItemSoldHourlyModel {
    var itemName:String
    var dateTime1:String
    var weekDay:String
    var dateTime2:String
    var amount:String
    var itemCount:Int
    init(name:String, time1:String, weekday:String, time2:String, amount:String, count:Int) {
        self.itemName = name
        self.dateTime1 = time1
        self.weekDay = weekday
        self.dateTime2 = time2
        self.amount = amount
        self.itemCount = count
    }
}
