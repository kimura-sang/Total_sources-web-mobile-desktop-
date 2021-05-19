//
//  DashInventoryModel.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class DashInventoryModel {
    var name:String
    var unit:String
    var first:String
    var second:String
    var third:String
    var criticalStatus:Bool
    init(name:String, unit:String, first:String, second:String, third:String, criticalStatus:Bool) {
        self.name = name
        self.unit = unit
        self.first = first
        self.second = second
        self.third = third
        self.criticalStatus = criticalStatus
    }
}
