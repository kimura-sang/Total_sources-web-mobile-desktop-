//
//  ItemModel.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ItemModel {
    var itemId:String
    var itemCode:String
    var itemName:String
    var itemUnit:String
    var expiredDate:String
    var itemQty:String
    init(id:String, itemCode:String, itemName:String, unit:String, expiredDate:String, quantity:String) {
        self.itemId = id
        self.itemName = itemName
        self.itemCode = itemCode
        self.itemUnit = unit
        self.expiredDate = expiredDate
        self.itemQty = quantity
    }
}
