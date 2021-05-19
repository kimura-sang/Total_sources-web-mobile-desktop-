//
//  StaffModel.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class StaffModel {
    var id:String
    var name:String
    var role:String
    var shiftNo:String
    var timeIn:String
    var timeOut:String
    init(id:String, name:String, role:String, shiftNo:String, timeIn:String, timeOut:String) {
        self.id = id
        self.name = name
        self.role = role
        self.shiftNo = shiftNo
        self.timeIn = timeIn
        self.timeOut = timeOut
    }
}
