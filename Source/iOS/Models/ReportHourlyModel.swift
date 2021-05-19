//
//  ReportHourlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/23.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class ReportHourlyModel {
    var no:String
    var reportDateTime:String
    var weekDay:String
    var day:Int
    var amount:Int
    init(no:String, reportDateTime:String, weekDay:String, day:Int, amount:Int) {
        self.no = no
        self.reportDateTime = reportDateTime
        self.weekDay = weekDay
        self.day = day
        self.amount = amount
    }
}
