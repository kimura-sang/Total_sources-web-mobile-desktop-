//
//  OfferDetailModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/22.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class OfferDetailModel {
    var no:String
    var description:String
    var count:String
    var unit:String
    init(no:String, description:String, count:String, unit:String) {
        self.no = no
        self.description = description
        self.count = count
        self.unit = unit
    }
}
