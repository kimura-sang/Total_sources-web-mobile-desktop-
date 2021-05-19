//
//  ReportDailyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/23.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ReportDailyModel {
    var no:String
    var weekDay:String
    var month:String
    var weekNo:String
    var day:Int
    var amount:Int
    init(no:String, weekDay:String, month:String, weekNo:String, day:Int, amount:Int) {
        self.no = no
        self.weekDay = weekDay
        self.month = month
        self.weekNo = weekNo
        self.day = day
        self.amount = amount
    }
}
