//
//  ConsolidateChartModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/26.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
import UIKit

class ConsolidateChartModel {
    var shopName:String
    var shopBranch:String
    var no:String
    var barChartObjects:[BarChartModel]
    var color:UIColor
    var selectedStatus:Bool
    init(name:String, branch:String, no:String, barChartObjects:[BarChartModel], color:UIColor, status:Bool) {
        self.shopName = name
        self.shopBranch = branch
        self.no = no
        self.barChartObjects = barChartObjects
        self.color = color
        self.selectedStatus = status
    }
}
