//
//  ShopModel.swift
//  nSoft
//
//  Created by king on 2019/12/11.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ShopModel {
    let shopId:String
    let shopName:String
    let shopBranch:String
    let shopMachineId:String
    let shopAmount:String
    let onlineStatus:Int
    init(id:String, name:String, branch:String, machineId:String, amount:String, onlineStatus:Int) {
        self.shopId = id
        self.shopName = name
        self.shopBranch = branch
        self.shopMachineId = machineId
        self.shopAmount = amount
        self.onlineStatus = onlineStatus
    }
}
