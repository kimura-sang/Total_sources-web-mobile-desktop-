//
//  ReplenishModel.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ReplenishModel {
    var itemNo:String
    var itemName:String
    var itemCode:String
    var unit:String
    var expiredDate:String
    var quantity:String
    init(no:String, code:String, name:String, unit:String, expiredDate:String, quantity:String) {
        self.itemNo = no
        self.itemName = name
        self.itemCode = code
        self.unit = unit
        self.expiredDate = expiredDate
        self.quantity = quantity
    }
}
