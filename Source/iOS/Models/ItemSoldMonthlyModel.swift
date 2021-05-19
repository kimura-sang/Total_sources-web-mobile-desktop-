//
//  ItemSoldMonthlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ItemSoldMonthlyModel {
    var monthNo:Int
    var itemName:String
    var monthName:String
    var amount:String
    var itemCount:Int
    init(no:Int, name:String, month:String, amount:String, count:Int) {
        self.monthNo = no
        self.itemName = name
        self.monthName = month
        self.amount = amount
        self.itemCount = count
    }
}
