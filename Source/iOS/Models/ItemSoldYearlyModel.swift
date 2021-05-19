//
//  ItemSoldYearlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ItemSoldYearlyModel {
    var itemName:String
    var year:String
    var amount:String
    var itemCount:Int
    init(name:String, year:String, amount:String, count:Int) {
        self.itemName = name
        self.year = year
        self.amount = amount
        self.itemCount = count
    }
}
