//
//  StaffProfileModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/22.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class StaffTransactionModel {
    var transactionDate:String
    var no:String
    var timeIn:String
    var timeOut:String
    init(transactionDate:String, no:String, timeIn:String, timeOut:String) {
        self.transactionDate = transactionDate
        self.no = no
        self.timeIn = timeIn
        self.timeOut = timeOut
    }
}
