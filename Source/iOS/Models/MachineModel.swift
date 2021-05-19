//
//  MachineModel.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class MachineModel {
    var no:String
    var id:String
    var name:String
    var status:String
    var kind:String
    var remainTime:String
    var registerTime:String
    init(no:String, id:String, name:String, status:String, kind:String, remainTime:String, registerTime:String) {
        self.no = no
        self.id = id
        self.name = name
        self.status =  status
        self.kind = kind
        self.remainTime = remainTime
        self.registerTime = registerTime
    }
}
