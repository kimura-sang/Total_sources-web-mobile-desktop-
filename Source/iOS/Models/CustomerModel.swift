//
//  CustomerModel.swift
//  nSoft
//
//  Created by king on 2019/12/12.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class CustomerModel {
    let id:String
    let firstName:String
    let lastName:String
    let phoneNumber:String
    let amount:String
    let customerTime:String
    let dayNumber:Int
    init(id:String, firstName:String, lastName:String, amount:String, phoneNumber:String, customerTime:String, dayNum:Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.amount = amount
        self.phoneNumber = phoneNumber
        self.customerTime = customerTime
        self.dayNumber = dayNum
    }
}
