//
//  DashUserModel.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class  DashUserModel {
    var name:String
    var role:String
    var status:String
    var timeIn:String
    var timeOut:String
    init(name:String, role:String, status:String, timeIn:String, timeOut:String) {
        self.name = name
        self.role = role
        self.status = status
        self.timeIn = timeIn
        self.timeOut = timeOut
    }
}
