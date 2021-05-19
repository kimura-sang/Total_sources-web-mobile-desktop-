//
//  OfferModel.swift
//  nSoft
//
//  Created by king on 2019/12/15.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
class OfferModel {
    var code:String
    var category:String
    var kind:String
    var description:String
    var price:String
    var cost:String
    var vatType:String
    init(code:String, category:String, kind:String, description:String, price:String, cost:String, varType:String) {
        self.code = code
        self.category = category
        self.kind = kind
        self.description = description
        self.price = price
        self.cost = cost
        self.vatType = varType
    }
}
