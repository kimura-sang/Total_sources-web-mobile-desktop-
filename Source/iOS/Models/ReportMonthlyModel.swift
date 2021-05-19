//
//  ReportMonthlyModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/23.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ReportMonthlyModel {
    var year:Int
    var monthName:String
    var monthNo:Int
    var amount:Int
    init(year:Int, monthName:String, monthNo:Int, amount:Int) {
        self.year = year
        self.monthName = monthName
        self.monthNo = monthNo
        self.amount = amount
    }
}
