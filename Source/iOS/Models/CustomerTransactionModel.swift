//
//  CustomerTransactionModel.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class CustomerTransactionModel {
    var no:Int
    var operationId:String
    var dateTime:String
    var amount:String
    var status:Bool
    init(no:Int, id:String, dateTime:String, amount:String, status:Bool){
        self.no = no
        self.operationId = id
        self.dateTime = dateTime
        self.amount = amount
        self.status = status
    }
}
