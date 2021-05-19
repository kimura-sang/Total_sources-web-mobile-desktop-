//
//  ItemSoldChartModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
import UIKit

class ItemSoldChartModel {
    var itemName:String
    var no:String
    var barChartArrays:[BarChartModel]
    var color:UIColor
    var selectedStatus:Bool
    init(name:String, no:String, chartArray:[BarChartModel], color:UIColor, status:Bool) {
        self.itemName = name
        self.no = no
        self.barChartArrays = chartArray
        self.color = color
        self.selectedStatus = status
    }
}
