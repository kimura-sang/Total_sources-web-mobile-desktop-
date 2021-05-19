//
//  BranchModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class BranchModel {
    var no:String
    var shopName:String
    var status:Bool
    var branchName:String
    var machineId:String
    init(no:String, shopName:String, status:Bool, branchName:String, machineId:String) {
        self.no = no
        self.shopName = shopName
        self.status = status
        self.branchName = branchName
        self.machineId = machineId
    }
}
