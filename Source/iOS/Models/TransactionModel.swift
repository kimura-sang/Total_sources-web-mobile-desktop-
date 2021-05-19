//
//  TransactionModel.swift
//  nSoft
//
//  Created by king on 2019/12/12.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class TransactionModel {
    let id:String
    let userName:String
    let photoUrl:String
    let operationId:String
    let amount:String
    init(id:String, name:String, photo:String, operation:String, amount:String) {
        self.id = id
        self.userName = name
        self.photoUrl = photo
        self.operationId = operation
        self.amount = amount
    }
}
