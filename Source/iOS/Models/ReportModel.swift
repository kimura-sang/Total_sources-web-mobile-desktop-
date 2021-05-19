//
//  ReportModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/23.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class ReportModel {
    var no:String
    var title1:String
    var title2:String
    var amount:Int
    init(no:String, title1:String, title2:String, amount:Int) {
        self.no = no
        self.title1 = title1
        self.amount = amount
        self.title2 = title2
    }
}
